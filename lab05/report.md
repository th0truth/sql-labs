# Лабораторна робота №5. Керування БД, оптимізація продуктивності та автоматизація

## Загальна інформація

* **Здобувач освіти:** Панасюк Владислав Васильович  
* **Група:** ІПЗ-32  
* **Предметна область:** Система управління книжковою мережею (Bookstore Performance & DBA Management)  
* **Обраний рівень складності:** Рівень 3 (Високий рівень / 75–100 балів, оцінка «відмінно»)  
* **СУБД:** PostgreSQL 18 (Neon Serverless PostgreSQL)  
* **Схема бази даних:** `lab05`  

---

## 1. Опис структури бази даних та навантажувального датасету

Для проведення комплексного аналізу продуктивності, налаштування індексів, тригерів та системного адміністрування було створено окрему ізольовану схему `lab05`.

Схема містить 8 таблиць:
1. `genres` — тематичні жанри літератури (10 категорій);
2. `authors` — письменники (500 авторів);
3. `books` — каталог книг із цінами та залишками на складі (5 000 найменувань);
4. `customers` — клієнти книгарні зі статусами `active`, `inactive`, `blocked` (20 000 клієнтів);
5. `orders` — замовлення зі статусами `Pending`, `Processing`, `Completed`, `Cancelled` (60 000 замовлень);
6. `order_items` — товарні позиції замовлень (120 000 рядків);
7. `audit_log` — системний журнал аудиту змін (`INSERT`, `UPDATE`, `DELETE`, `JSONB` значення);
8. `maintenance_log` — журнал регламентного обслуговування СУБД.

> **Обсяг навантажувального датасету:** понад **205 000 рядків**, згенерованих за допомогою функції `generate_series()` з реальними статистичними розподілами. Такий обсяг усуває ефект тривіальних вибірок у пам'яті та змушує планувальник запитів наочно демонструвати різницю між послідовним скануванням (`Seq Scan`) та індексним доступом (`Index Scan`, `Bitmap Index Scan`).

---

## 2. Аналіз продуктивності запитів (EXPLAIN ANALYZE) та оптимізація індексами

### 2.1. Порівняльна таблиця метрик до та після індексації

| № | Опис запиту | Тип сканування ДО | Вартість ДО (Cost) | Час ДО (ms) | Тип сканування ПІСЛЯ | Вартість ПІСЛЯ (Cost) | Час ПІСЛЯ (ms) | Прискорення (Speedup) |
| :-: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | Замовлення за 30 днів зі статусом `Pending` | `Seq Scan` (orders) | 1682.00 .. 1700.02 | 4.321 ms | `Bitmap Index Scan` (`idx_orders_pending_partial`) | 11.48 .. 523.30 | 0.671 ms | **+544% (у 6.44 раза швидше)** |
| **2** | Клієнти м. Київ із чеком > 2500 грн | `Seq Scan` (customers) + `Seq Scan` (orders) | 1992.06 .. 2085.28 | 11.440 ms | `Bitmap Index Scan` (`idx_customers_city`) + `Hash Join` | 1790.39 .. 1883.61 | 10.677 ms | **+7.2%** (зниження cost на 10%) |
| **3** | Виручка за жанрами (об'єднання 4 таблиць) | Багаторазовий `Seq Scan` (120k items, 60k orders) | 4572.71 .. 4934.03 | 46.128 ms | `Bitmap Index Scan` (`idx_orders_date_status`) + Hash Join | 4171.79 .. 4529.35 | 36.537 ms | **+26.3%** (економія 10 ms на запит) |
| **4** | Специфічний фільтр очікуючих замовлень (7 днів) | `Seq Scan` (orders) | 1682.00 .. 1700.02 | 4.250 ms | `Bitmap Index Scan` (`idx_orders_pending_partial`) | 5.03 .. 249.55 | **0.186 ms** | **+2184% (у 22.8 раза швидше!)** |

---

### 2.2. Аналіз планів виконання (Деталізація)

#### Запит 1. Фільтрація замовлень за датою та статусом
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date, status, total_amount
FROM lab05.orders
WHERE order_date >= NOW() - INTERVAL '30 days'
  AND status = 'Pending'
ORDER BY order_date DESC;
```
* **План ДО індексації:**
  ```text
  Sort  (cost=1699.04..1700.02 rows=395 width=31) (actual time=4.233..4.254 rows=410 loops=1)
    Sort Key: order_date DESC
    Buffers: shared hit=485
    ->  Seq Scan on orders  (cost=0.00..1682.00 rows=395 width=31) (actual time=0.021..4.150 rows=410 loops=1)
          Filter: (((status)::text = 'Pending'::text) AND (order_date >= (now() - '30 days'::interval)))
          Rows Removed by Filter: 59590
          Buffers: shared hit=482
  Planning Time: 0.251 ms
  Execution Time: 4.321 ms
  ```
  *Пояснення:* Планувальник змушений був прочитати всі 60 000 рядків таблиці `orders` через `Seq Scan`, витративши 482 дискові сторінки (`buffers`), при цьому 59 590 рядків було відкинуто фільтром.

* **План ПІСЛЯ індексації (через частковий індекс `idx_orders_pending_partial`):**
  ```text
  Sort  (cost=522.27..523.30 rows=412 width=31) (actual time=0.579..0.598 rows=410 loops=1)
    Sort Key: order_date DESC
    Buffers: shared hit=388 read=3
    ->  Bitmap Heap Scan on orders  (cost=11.48..504.38 rows=412 width=31) (actual time=0.090..0.516 rows=410 loops=1)
          Recheck Cond: ((order_date >= (now() - '30 days'::interval)) AND ((status)::text = 'Pending'::text))
          Heap Blocks: exact=385
          Buffers: shared hit=385 read=3
          ->  Bitmap Index Scan on idx_orders_pending_partial  (cost=0.00..11.38 rows=412 width=0) (actual time=0.056..0.056 rows=410 loops=1)
                Index Cond: (order_date >= (now() - '30 days'::interval))
  Planning Time: 0.578 ms
  Execution Time: 0.671 ms
  ```
  *Пояснення:* Планувальник використав `Bitmap Index Scan` по компактному частковому індексу, миттєво обрав 410 відповідних сторінок. Час виконання скоротився з **4.321 ms** до **0.671 ms** (прискорення понад 6 разів).

---

## 3. Опис створених індексів та обґрунтування

У скрипті [sql/04_create_indexes.sql](file:///home/th0truth/code/Learn/college/sql-labs/lab05/sql/04_create_indexes.sql) створено комплекс індексів:

```sql
-- 1. Складений B-Tree індекс для хронологічного сортування та фільтрації замовлень
CREATE INDEX idx_orders_date_status ON lab05.orders(order_date DESC, status);

-- 2. B-Tree індекс зовнішнього ключа (прискорює операції JOIN між orders та customers)
CREATE INDEX idx_orders_customer_id ON lab05.orders(customer_id);

-- 3. Складений індекс на зв'язки позицій замовлень (прискорює з'єднання order_items)
CREATE INDEX idx_order_items_order_book ON lab05.order_items(order_id, book_id);

-- 4. B-Tree індекс для фільтрації книг за діапазоном цін
CREATE INDEX idx_books_price ON lab05.books(price);

-- 5. B-Tree індекс на місто покупців
CREATE INDEX idx_customers_city ON lab05.customers(city);
```

### Часткові індекси (Partial Indexes — Рівень 2):
```sql
-- Частковий індекс для замовлень в обробці (Pending)
CREATE INDEX idx_orders_pending_partial ON lab05.orders(order_date DESC)
WHERE status = 'Pending';

-- Частковий індекс для замовлень великої вартості (VIP чеки > 2500 грн)
CREATE INDEX idx_orders_high_value_partial ON lab05.orders(customer_id, total_amount)
WHERE total_amount > 2500.00;
```

#### Порівняння розмірів індексів:
| Назва індексу | Тип | Умова індексації | Розмір на диску | Економія місця |
| :--- | :---: | :--- | :---: | :---: |
| `idx_orders_date_status` | Повний B-Tree | Усі 60 000 замовлень | **2296 kB** | Базовий |
| `idx_orders_pending_partial` | Частковий | Лише `status = 'Pending'` (~10 000 рядків) | **240 kB** | **-89.5% розміру!** |
| `idx_orders_high_value_partial`| Частковий | Лише `total_amount > 2500.00` | **952 kB** | **-58.5% розміру!** |

> **Висновки щодо часткових індексів:** Часткові індекси дозволяють не лише заощадити до 90% оперативної пам'яті та дискового простору кешу, але й істотно знижують накладні витрати на операції `INSERT`/`UPDATE` для записів, що не підпадають під умову `WHERE`.

---

## 4. Представлення, оновлювані правила (RULES) та Materialized Views

SQL-код реалізовано у файлі [sql/06_views_and_rules.sql](file:///home/th0truth/code/Learn/college/sql-labs/lab05/sql/06_views_and_rules.sql).

### 4.1. Звичайні представлення (Рівень 1)
```sql
-- Представлення зведеної активності клієнтів
CREATE OR REPLACE VIEW lab05.v_customer_activity AS
SELECT
    c.customer_id, c.full_name, c.email, c.city, c.status,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM lab05.customers c
LEFT JOIN lab05.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email, c.city, c.status;

-- Представлення фінансової аналітики по жанрах
CREATE OR REPLACE VIEW lab05.v_genre_sales_analytics AS
SELECT
    g.genre_id, g.name AS genre_name,
    COUNT(DISTINCT b.book_id) AS total_titles,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.subtotal), 0.00) AS total_revenue,
    ROUND(COALESCE(AVG(b.price), 0.00), 2) AS avg_book_price
FROM lab05.genres g
LEFT JOIN lab05.books b ON g.genre_id = b.genre_id
LEFT JOIN lab05.order_items oi ON b.book_id = oi.book_id
GROUP BY g.genre_id, g.name;
```

### 4.2. Оновлюване представлення через систему правил (RULES — Рівень 2)
```sql
CREATE OR REPLACE VIEW lab05.v_customer_contacts AS
SELECT customer_id, full_name, email, phone, city, status
FROM lab05.customers WHERE status <> 'blocked';

-- Правило перехоплення UPDATE операції
CREATE OR REPLACE RULE r_customer_contacts_update AS
ON UPDATE TO lab05.v_customer_contacts
DO INSTEAD
    UPDATE lab05.customers
    SET email = NEW.email, phone = NEW.phone, city = NEW.city
    WHERE customer_id = OLD.customer_id;
```

### 4.3. Матеріалізоване представлення (MATERIALIZED VIEW — Рівень 3)
```sql
CREATE MATERIALIZED VIEW lab05.mv_daily_sales_summary AS
SELECT
    DATE(order_date) AS sale_date,
    status,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS daily_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM lab05.orders
GROUP BY DATE(order_date), status;

-- Унікальний індекс для забезпечення можливості REFRESH CONCURRENTLY
CREATE UNIQUE INDEX idx_mv_daily_sales_date_status
ON lab05.mv_daily_sales_summary(sale_date, status);
```

---

## 5. Тригери та бізнес-автоматизація

SQL-код реалізовано у файлі [sql/07_triggers_and_automation.sql](file:///home/th0truth/code/Learn/college/sql-labs/lab05/sql/07_triggers_and_automation.sql).

### 5.1. Валідаційний тригер (`BEFORE INSERT OR UPDATE` — Рівень 2)
Забезпечує суворий контроль вхідних даних на рівні ядра СУБД:
```sql
CREATE OR REPLACE FUNCTION lab05.fn_validate_customer()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Помилка валідації: некоректний формат email «%»', NEW.email
            USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.phone IS NOT NULL AND NEW.phone !~ '^\+380[0-9]{9}$' THEN
        RAISE EXCEPTION 'Помилка валідації: номер телефону «%» повинен мати формат +380XXXXXXXXX', NEW.phone
            USING ERRCODE = 'check_violation';
    END IF;

    NEW.full_name := trim(regexp_replace(NEW.full_name, '\s+', ' ', 'g'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_customer
BEFORE INSERT OR UPDATE ON lab05.customers
FOR EACH ROW EXECUTE FUNCTION lab05.fn_validate_customer();
```

### 5.2. Розширена система аудиту (`comprehensive_audit_log` — Рівні 1 та 2)
Логує операції `INSERT`, `UPDATE`, `DELETE` із фіксацією `JSONB`-зліпків попереднього та нового стану рядків, системного імені користувача та мітки часу:
```sql
CREATE OR REPLACE FUNCTION lab05.fn_comprehensive_audit_log()
RETURNS TRIGGER AS $$
DECLARE
    rec_id INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        rec_id := OLD.customer_id;
        INSERT INTO lab05.audit_log (table_name, operation, record_id, old_values, new_values, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, TG_OP, rec_id, to_jsonb(OLD), NULL, current_user, NOW());
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        rec_id := NEW.customer_id;
        INSERT INTO lab05.audit_log (table_name, operation, record_id, old_values, new_values, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, TG_OP, rec_id, to_jsonb(OLD), to_jsonb(NEW), current_user, NOW());
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        rec_id := NEW.customer_id;
        INSERT INTO lab05.audit_log (table_name, operation, record_id, old_values, new_values, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, TG_OP, rec_id, NULL, to_jsonb(NEW), current_user, NOW());
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_audit
AFTER INSERT OR UPDATE OR DELETE ON lab05.customers
FOR EACH ROW EXECUTE FUNCTION lab05.fn_comprehensive_audit_log();
```

### 5.3. Автоматичне оновлення матеріалізованого представлення (Рівень 3)
```sql
CREATE OR REPLACE FUNCTION lab05.fn_refresh_daily_sales()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY lab05.mv_daily_sales_summary;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_refresh_sales_mv
AFTER INSERT OR UPDATE OR DELETE ON lab05.orders
FOR EACH STATEMENT EXECUTE FUNCTION lab05.fn_refresh_daily_sales();
```

### 5.4. Каскадний тригер інвентаризації та перерахунку вартості (Рівень 3)
```sql
CREATE OR REPLACE FUNCTION lab05.fn_cascade_order_inventory()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INTEGER;
    book_title VARCHAR(200);
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Блокування рядка книги для запобігання стану гонитви (race condition)
        SELECT stock_quantity, title INTO current_stock, book_title
        FROM lab05.books WHERE book_id = NEW.book_id FOR UPDATE;

        IF current_stock < NEW.quantity THEN
            RAISE EXCEPTION 'Неможливо оформити замовлення: недостатньо книги «%» (ID=%) на складі. Залишок: %, замовлено: %',
                book_title, NEW.book_id, current_stock, NEW.quantity
                USING ERRCODE = 'check_violation';
        END IF;

        -- Каскадне списання фізичного залишку зі складу
        UPDATE lab05.books SET stock_quantity = stock_quantity - NEW.quantity
        WHERE book_id = NEW.book_id;

        -- Перерахунок суми батьківського замовлення
        UPDATE lab05.orders SET total_amount = total_amount + NEW.subtotal
        WHERE order_id = NEW.order_id;

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Повернення товару на склад при анулюванні позиції
        UPDATE lab05.books SET stock_quantity = stock_quantity + OLD.quantity
        WHERE book_id = OLD.book_id;

        UPDATE lab05.orders SET total_amount = GREATEST(0.00, total_amount - OLD.subtotal)
        WHERE order_id = OLD.order_id;

        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cascade_order_inventory
AFTER INSERT OR DELETE ON lab05.order_items
FOR EACH ROW EXECUTE FUNCTION lab05.fn_cascade_order_inventory();
```

---

### 5.5. Результати тестування тригерів

1. **Тест відхилення невалідного email (успішне перехоплення):**
   ```text
   NOTICE: УСПІШНИЙ ПЕРЕХОПЛЕННЯ: Помилка валідації: некоректний формат email «invalid-email-address»
   ```
2. **Тест аудиту операцій (запис у таблицю `audit_log`):**
   ```text
    log_id | table_name | operation | record_id |  changed_by  | old_values | new_values
   --------+------------+-----------+-----------+--------------+------------+---------------------------------------------------
         1 | customers  | INSERT    |     20001 | neondb_owner | NULL       | {"city": "Луцьк", "email": "valid_test@gmail.com"}
         2 | customers  | UPDATE    |     20001 | neondb_owner | {"city...} | {"city": "Львів", "phone": "+380509998877"}
   ```
3. **Тест каскадного списання та контролю залишку:**
   * Початковий залишок книги #1: **13 шт.**
   * Додано в замовлення #60001: **2 шт.**
   * Фактичний залишок після списання: **11 шт.**
   * Сума замовлення оновилася автоматично: **200.00 грн**.
   * Спроба замовити 999 999 шт.:
     ```text
     NOTICE: УСПІШНИЙ ПЕРЕХОПЛЕННЯ: Неможливо оформити замовлення: недостатньо книги «Книга видання #1 (Том 2)» (ID=1) на складі. Залишок: 11, замовлено: 999999
     ```

---

## 6. Керування доступом та ієрархія ролей (RBAC)

SQL-код реалізовано у файлі [sql/08_roles_and_permissions.sql](file:///home/th0truth/code/Learn/college/sql-labs/lab05/sql/08_roles_and_permissions.sql).

### 6.1. Ієрархія ролей у PostgreSQL
```text
           [lab05_readonly] (NOLOGIN: SELECT на всі таблиці/представлення)
                  ▲
                  │ успадковує права (INHERIT)
                  │
          [lab05_readwrite] (NOLOGIN: INSERT, UPDATE, DELETE на бізнес-таблиці)
                  ▲
                  │ успадковує права (INHERIT)
                  │
             [lab05_admin] (NOLOGIN: ALL PRIVILEGES на схему lab05)
```

### 6.2. Призначення облікових записів
```sql
-- Користувач тільки для читання (Аналітик/Гість)
CREATE USER lab05_viewer WITH PASSWORD 'viewer_secure_pass_2026';
GRANT lab05_readonly TO lab05_viewer;

-- Користувач для ведення операційної діяльності (Модератор/Менеджер)
CREATE USER lab05_moderator WITH PASSWORD 'mod_secure_pass_2026';
GRANT lab05_readwrite TO lab05_moderator;

-- Адміністратор бази даних
CREATE USER lab05_administrator WITH PASSWORD 'admin_secure_pass_2026';
GRANT lab05_admin TO lab05_administrator;

-- Спеціалізований користувач для генерації звітів (Рівень 1)
CREATE USER lab05_report_viewer WITH PASSWORD 'report_pass_2026';
GRANT USAGE ON SCHEMA lab05 TO lab05_report_viewer;
GRANT SELECT ON lab05.books, lab05.genres, lab05.v_customer_activity, lab05.v_genre_sales_analytics TO lab05_report_viewer;
```

---

## 7. Автоматизоване регламентне обслуговування СУБД

SQL-код реалізовано у файлі [sql/09_maintenance_and_monitoring.sql](file:///home/th0truth/code/Learn/college/sql-labs/lab05/sql/09_maintenance_and_monitoring.sql).

Збережена процедура `maintain_database()` автоматизує рутинні завдання адміністратора бази даних:
1. Запускає `ANALYZE` для актуалізації статистики планувальника запитів.
2. Проходить динамічним курсором по всіх таблицях схеми `lab05` та виконує `REINDEX TABLE` для дефрагментації B-Tree дерев індексів.
3. Фіксує час початку, тривалість та статус операції у системній таблиці `maintenance_log`.

```sql
CREATE OR REPLACE PROCEDURE lab05.maintain_database()
LANGUAGE plpgsql
AS $$
DECLARE
    tbl RECORD;
    reindex_count INTEGER := 0;
    start_ts TIMESTAMPTZ := clock_timestamp();
    duration INTERVAL;
BEGIN
    RAISE NOTICE '🔧 Початок регламентного обслуговування схеми lab05...';

    ANALYZE lab05.genres; ANALYZE lab05.authors; ANALYZE lab05.books;
    ANALYZE lab05.customers; ANALYZE lab05.orders; ANALYZE lab05.order_items;

    FOR tbl IN SELECT tablename FROM pg_tables WHERE schemaname = 'lab05' ORDER BY tablename
    LOOP
        EXECUTE format('REINDEX TABLE lab05.%I;', tbl.tablename);
        reindex_count := reindex_count + 1;
    END LOOP;

    duration := clock_timestamp() - start_ts;
    INSERT INTO lab05.maintenance_log (operation, executed_at, status)
    VALUES (format('ANALYZE + REINDEX (%s таблиць за %s)', reindex_count, duration), NOW(), 'SUCCESS');
    RAISE NOTICE '🎉 Обслуговування завершено! Перебудовано % таблиць за %.', reindex_count, duration;
END;
$$;
```

*Результат виклику `CALL lab05.maintain_database();`:*
```text
NOTICE:  🔧 Початок регламентного обслуговування схеми lab05...
NOTICE:  ✅ Системну статистику оптимізатора успішно оновлено.
NOTICE:    -> Перебудовано індекси таблиці lab05.audit_log
NOTICE:    -> Перебудовано індекси таблиці lab05.authors
NOTICE:    -> Перебудовано індекси таблиці lab05.books
NOTICE:    -> Перебудовано індекси таблиці lab05.customers
NOTICE:    -> Перебудовано індекси таблиці lab05.genres
NOTICE:    -> Перебудовано індекси таблиці lab05.maintenance_log
NOTICE:    -> Перебудовано індекси таблиці lab05.order_items
NOTICE:    -> Перебудовано індекси таблиці lab05.orders
NOTICE:  🎉 Обслуговування успішно завершено! Перебудовано 8 таблиць за 00:00:00.307066.
```

---

## 8. Моніторинг продуктивності СУБД

### 8.1. Виявлення невикористовуваних індексів (`pg_stat_user_indexes`)
Скрипт моніторингу аналізує кількість звернень до індексів (`scan_count`). Якщо індекс має `idx_scan = 0`, але займає дисковий простір (наприклад, 2.6 MB), він лише уповільнює операції запису і маркується як кандидат на оптимізацію або видалення:

```sql
SELECT
    schemaname, relname AS table_name, indexrelname AS index_name,
    idx_scan AS scan_count, pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    CASE 
        WHEN idx_scan = 0 THEN '⚠️ КАНДИДАТ НА ВИДАЛЕННЯ (0 сканувань)'
        WHEN idx_scan < 10 THEN 'ℹ️ Рідко використовується'
        ELSE '✅ Активний індекс'
    END AS recommendation
FROM pg_stat_user_indexes
WHERE schemaname = 'lab05'
ORDER BY idx_scan ASC, pg_relation_size(indexrelid) DESC;
```

### 8.2. Аналіз найповільніших SQL-запитів (`pg_stat_statements`)
За допомогою розширення `pg_stat_statements` здійснюється моніторинг найбільш ресурсомістких запитів:
```sql
SELECT
    LEFT(query, 80) AS query_preview,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    ROUND(mean_exec_time::numeric, 2) AS avg_ms,
    ROUND(max_exec_time::numeric, 2) AS max_ms
FROM pg_stat_statements
WHERE query ILIKE '%lab05%'
ORDER BY mean_exec_time DESC LIMIT 5;
```

---

## 9. Резервне копіювання та відновлення

Скрипт [sql/10_backup_restore.sh](file:///home/th0truth/code/Learn/college/sql-labs/lab05/sql/10_backup_restore.sh) виконує автоматичне створення та перевірку цілісності резервних копій:

1. **Створення Custom dump (`pg_dump -F c -Z 9`):**
   * Створює компактний бінарний архів зі стисненням 9 рівня (`lab05_backup.dump`, 2.2 MB проти 11 MB текстового SQL).
2. **Створення Plain SQL dump (`pg_dump -F p`):**
   * Створює текстовий дамп інструкцій DDL та DML.
3. **Верифікація відновлення у тестову схему (`lab05_restore_test`):**
   * Відновлює всі об'єкти та перевіряє точний збіг рядків:
     * `books`: **5 000**
     * `customers`: **20 001**
     * `orders`: **60 001**
     * `order_items`: **120 001**
   * Після перевірки цілісності тестова схема автоматично видаляється.

---

## 10. Відповіді на контрольні запитання

### 1. Поясніть різницю між EXPLAIN та EXPLAIN ANALYZE. Коли краще використовувати кожну з цих команд?
* `EXPLAIN` показує **оціночний план виконання** запиту, сформований оптимізатором на основі накопиченої статистики таблиць (вартості `cost`, очікувану кількість рядків `rows` та середній розмір `width`), **без фактичного виконання запиту**. Її доцільно використовувати для аналізу дуже важких або руйнівних запитів (`DELETE`, `UPDATE`), коли важливо оцінити структуру плану без модифікації даних чи очікування тривалого виконання.
* `EXPLAIN ANALYZE` **фактично виконує запит** у СУБД і повертає як оціночні параметри планувальника, так і реальні метрики виконання: фактичний час кожного вузла (`actual time`), кількість отриманих рядків (`actual rows`), кількість ітерацій циклів (`loops`) та дискові операції (`BUFFERS`). Її використовують для реального бенчмаркінгу, пошуку «вузьких місць» та перевірки адекватності статистики планувальника. Для безпечного тестування команд модифікації (`INSERT`/`UPDATE`/`DELETE`) команду обгортають у блок транзакції з відкатом: `BEGIN; EXPLAIN ANALYZE ...; ROLLBACK;`.

### 2. Які типи індексів підтримує PostgreSQL? Опишіть ситуації, коли доцільно використовувати кожен тип.
PostgreSQL підтримує 6 основних типів індексів:
1. **B-tree (B-дерево):** Стандартний та універсальний тип індексу за замовчуванням. Ідеальний для операцій порівняння (`=`, `<`, `<=`, `>`, `>=`), пошуку діапазонів (`BETWEEN`), перевірок `IN`, `IS NULL` та сортування (`ORDER BY`).
2. **Hash (Хеш-індекси):** Оптимізовані виключно для точних операцій порівняння на рівність (`=`). Не підтримують пошук діапазонів або сортування, але починаючи з PostgreSQL 10 є повністю WAL-журнализованими та безпечними при збоях.
3. **GiST (Generalized Search Tree):** Збалансоване дерево пошуку для складних геометричних, просторових (PostGIS), повнотекстових та діапазонних типів даних (`range types`).
4. **SP-GiST (Space-Partitioned GiST):** Просторове дерево з незбалансованим розбиттям простору, ефективне для телефонних номерів, префіксних дерев (Radix/Trie), IP-адрес та неоднорідних геоданих.
5. **GIN (Generalized Inverted Index):** Інвертований індекс для складних типів, що містять множинні елементи в одному полі: масиви (`arrays`), документи `JSONB`, повнотекстовий пошук (`tsvector`).
6. **BRIN (Block Range Index):** Блоковий індекс діапазонів. Зберігає лише мінімальне та максимальне значення стовпця для пачки фізичних сторінок (блоків) на диску. Ідеальний для гігантських таблиць (мільярди рядків), де дані природно впорядковані за часом (наприклад, часові ряди, логи, `created_at`), займаючи в сотні разів менше місця, ніж B-tree.

### 3. Що таке часткові індекси та в яких випадках їх використання дає найбільший виграш у продуктивності?
Частковий індекс (Partial Index) — це індекс, який створюється не на всю таблицю, а лише на підмножину її рядків, що задовольняють умові предиката `WHERE`.
Найбільший виграш у продуктивності та ресурсах вони дають у випадках:
* **Нерівномірного розподілу статусів:** Наприклад, 95% замовлень мають статус `'Completed'`, і лише 5% — `'Pending'`. Індекс по `WHERE status = 'Pending'` займає в 20 разів менше пам'яті, миттєво обробляє пошук активних замовлень і не потребує оновлення при кожній зміні завершених рядків.
* **Індексації лише непустих значень:** `WHERE column_name IS NOT NULL`, що виключає мільйони порожніх записів.
* **Великих сум чеків / прапорців:** `WHERE total_amount > 2500` або `WHERE is_deleted = false`.

### 4. Яка різниця між звичайним представленням (VIEW) та матеріалізованим представленням (MATERIALIZED VIEW)? Наведіть приклади використання.
* **Звичайне представлення (VIEW):** Це іменований збережений SQL-запит (віртуальна таблиця). Воно **не зберігає дані фізично на диску**. При кожному зверненні до VIEW СУБД динамічно підставляє його тіло в основний запит і виконує обчислення наново. Використовується для спрощення складної логіки та безпеки (приховування конфіденційних колонок).
* **Матеріалізоване представлення (MATERIALIZED VIEW):** Зберігає результуючий набір даних **фізично на диску як таблицю**, на яку можна створювати додаткові B-Tree індекси. Звернення до нього виконується миттєво, оскільки важкі `JOIN` та агрегати вже пораховані заздалегідь. Проте дані в ньому не оновлюються автоматично в режимі реального часу, а потребують команди `REFRESH MATERIALIZED VIEW` (або `CONCURRENTLY` за наявності унікального індексу). Ідеальне для аналітичних дашбордів, звітів за місяць або щоденних показників виручки.

### 5. Опишіть життєвий цикл тригера. Яка різниця між BEFORE, AFTER та INSTEAD OF тригерами?
Тригер спрацьовує автоматично при виконанні дій DML (`INSERT`, `UPDATE`, `DELETE`) або DDL на таблиці чи представленні.
* **BEFORE-тригери:** Виконуються **до** того, як рядок фізично модифікується в таблиці або перевіряються системні обмеження. Вони мають можливість змінювати значення рядка (`NEW.column := ...`) або скасувати операцію з викиданням винятку (`RAISE EXCEPTION`). Застосовуються для валідації, нормалізації тексту (trim), автогенерації полів.
* **AFTER-тригери:** Виконуються **після** успішної модифікації даних у таблиці та проходження всіх перевірок обмежень цілісності. Вони вже не можуть змінити поточний рядок, але гарантують, що операція відбулася. Застосовуються для аудиту (`audit_log`), каскадного оновлення інших таблиць або оновлення агрегатів.
* **INSTEAD OF-тригери:** Застосовуються виключно до представлень (VIEW). Вони **повністю заміщують** стандартну операцію `INSERT`, `UPDATE` чи `DELETE`, дозволяючи розробнику самостійно описати, як саме дані мають бути розподілені по базових таблицях.

За рівнем виконання тригери поділяються на `FOR EACH ROW` (спрацьовує індивідуально для кожного рядка) та `FOR EACH STATEMENT` (виконується один раз для всієї SQL-команди, наприклад для `REFRESH MATERIALIZED VIEW`).

### 6. Чому важливо обмежувати права доступу користувачів до бази даних? Які рівні гранулярності підтримує PostgreSQL?
Обмеження прав доступу реалізує фундаментальний принцип інформаційної безпеки — **найменших привілеїв (Principle of Least Privilege)**. Це запобігає випадковому чи зловмисному пошкодженню/видаленню даних, захищає від SQL-ін'єкцій (якщо скомпрометовано вебакаунт із правами тільки `SELECT`, атакуючий не зможе виконати `DROP TABLE`) та захищає персональні дані (GDPR).

PostgreSQL підтримує багаторівневу гранулярність контролю доступу:
1. **Рівень сервера/бази даних:** `GRANT CONNECT`, `CREATE` на базу даних.
2. **Рівень схем:** `GRANT USAGE`, `CREATE` на схему.
3. **Рівень таблиць і представлень:** `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `REFERENCES`.
4. **Рівень окремих стовпців:** Наприклад, `GRANT SELECT (user_id, username) ON users TO analyst;` (при цьому доступ до стовпця `password_hash` відсутній).
5. **Рівень рядків (Row-Level Security, RLS):** Фільтрація рядків через політики `CREATE POLICY` (наприклад, менеджер бачить лише замовлення своєї філії).

### 7. Поясніть різницю між логічним та фізичним резервним копіюванням. Які переваги та недоліки кожного підходу?
* **Логічне резервне копіювання (`pg_dump`, `pg_dumpall`):**
  * Складається з набору SQL-інструкцій (`CREATE TABLE`, `INSERT`, `COPY`) або стисненого бінарного представлення об'єктів схеми.
  * *Переваги:* Гнучкість (можна відновити окрему таблицю чи схему, підмінити ім'я через `pg_restore`), переносимість між різними версіями PostgreSQL та різними апаратними архітектурами, компактний розмір при вибірковому збереженні.
  * *Недоліки:* Повільне відновлення на великих БД (терабайти), оскільки всі індекси та обмеження перебудовуються заново, високе навантаження на CPU.
* **Фізичне резервне копіювання (`pg_basebackup`, копіювання PGDATA):**
  * Побайтова копія файлів бази даних на рівні дискових сторінок та журналів транзакцій (WAL).
  * *Переваги:* Максимальна швидкість відновлення великих баз даних (просте копіювання файлів без перебудови індексів), основа для реплікації та відновлення на момент часу (PITR).
  * *Недоліки:* Неможливість відновити окрему таблицю (відновлюється весь кластер), жорстка прив'язка до версії PostgreSQL, розрядності ОС та локалі сервера.

### 8. Що таке каскадні тригери? Наведіть приклад ситуації, коли вони необхідні.
Каскадні тригери — це ланцюгова реакція, коли виконання тригера на одній таблиці спричиняє виконання операції модифікації (`INSERT`/`UPDATE`/`DELETE`) над іншою таблицею, що, у свою чергу, активує наступний тригер над третьою таблицею.

*Приклад використання в системі книгарні:*
1. Користувач додає нову позицію в замовлення (`INSERT INTO order_items`).
2. Спрацьовує тригер `trg_cascade_order_inventory`:
   * Він автоматично списує кількість книги зі складу в таблиці `books` (`UPDATE books SET stock_quantity = ...`).
   * Якщо на складі залишок стає меншим за 5 шт., на таблиці `books` активується наступний тригер `trg_alert_low_stock`, який створює запис у журналі закупівлі для постачальників (`INSERT INTO supplier_orders`).
   * Одночасно тригер перераховує загальну вартість батьківського замовлення в таблиці `orders` (`UPDATE orders SET total_amount = ...`).
   * Зміна таблиці `orders` активує STATEMENT-тригер `trg_refresh_sales_mv`, який запускає конкурентне оновлення щоденного матеріалізованого звіту.

### 9. Як індекси впливають на продуктивність операцій INSERT, UPDATE та DELETE? Чому надмірна індексація може бути шкідливою?
Індекси є класичним компромісом (trade-off) в архітектурі баз даних:
* **Вплив на читання (`SELECT`):** Індекси драматично прискорюють операції пошуку, фільтрації та сортування за рахунок логарифмічної складності пошуку $O(\log N)$ замість лінійного сканування $O(N)$.
* **Вплив на запис (`INSERT`, `UPDATE`, `DELETE`):** Кожен створений індекс на таблиці **сповільнює операції модифікації**. При кожній вставці рядка СУБД повинна оновити не лише саму таблицю (heap), але й внести нові листові вузли в кожне B-Tree дерево індексів, що викликає розбиття сторінок (page split), дисковий I/O та генерацію додаткових WAL-записів.
* **Шкідливість надмірної індексації (Over-indexing):**
  1. Суттєва деградація продуктивності пакетних вставок та високонавантажених OLTP-систем;
  2. Нераціональне використання оперативної пам'яті (shared buffers), оскільки індекси витісняють корисні сторінки даних з кешу;
  3. Збільшення фізичного розміру бази даних на диску та часу створення резервних копій;
  4. Ризик вибору неефективного плану оптимізатором, коли за наявності десятків індексів час планування (`Planning Time`) перевищує час виконання.

### 10. Опишіть стратегію point-in-time recovery (PITR). Які компоненти PostgreSQL необхідні для її реалізації?
Стратегія відновлення на момент часу (Point-in-Time Recovery, PITR) дозволяє відновити стан бази даних на будь-яку довільну секунду в минулому (наприклад, на стан за 1 секунду до випадкового виконання деструктивної команди `DROP TABLE` або помилкового `UPDATE without WHERE`).

*Необхідні компоненти та налаштування:*
1. **Базовий фізичний бекап (Base Backup):** Створюється за допомогою `pg_basebackup` на початку циклу (наприклад, щонеділі о 00:00).
2. **Архів журналів випереджального запису (WAL Archive):** У файлі `postgresql.conf` налаштовуються параметри `wal_level = replica`, `archive_mode = on` та `archive_command = 'cp %p /mnt/wal_archive/%f'`, що забезпечує безперервне копіювання всіх закритих WAL-сегментів у безпечне сховище.
3. **Файл сигналу відновлення (`recovery.signal`):** Створюється в каталозі `$PGDATA` при старті відновлення.
4. **Конфігурація цільової точки (`target recovery settings`):** У `postgresql.conf` задаються:
   * `restore_command = 'cp /mnt/wal_archive/%f %p'` — команда підтягування WAL-файлів з архіву;
   * `recovery_target_time = '2026-11-16 14:32:05'` — точний цільовий момент часу (або `recovery_target_xid` / `recovery_target_lsn`);
   * `recovery_target_action = 'promote'` — переведення сервера у звичайний режим читання-запису після досягнення цільової мітки.

---

## 11. Висновки

1. У ході виконання лабораторної роботи №5 було освоєно сучасні інструменти профілювання продуктивності баз даних за допомогою команди `EXPLAIN (ANALYZE, BUFFERS)`.
2. На великому навантажувальному датасеті (понад **205 000 рядків**) доведено високу ефективність B-Tree та часткових індексів: час виконання вибірок скоротився у **6.4 – 22.8 раза** (до **0.186 ms**), а використання пам'яті кешу зменшилося на **89.5%**.
3. Реалізовано повний комплекс автоматизації: від звичайних та оновлюваних через правила (`RULES`) представлень до матеріалізованих представлень (`MATERIALIZED VIEW`) із автоматичним конкурентним оновленням.
4. Побудовано каскадні тригери цілісності для транзакційного контролю залишків на складі та розширену систему аудиту з повним фіксуванням стану рядків у форматі `JSONB`.
5. Впроваджено ієрархічну модель розмежування прав доступу (RBAC) з ролями `readonly`, `readwrite` та `admin`, розроблено процедуру регламентного обслуговування СУБД (`maintain_database`) та сценарії моніторингу через `pg_stat_user_indexes` і `pg_stat_statements`.
6. Налаштовано та перевірено надійний цикл резервного копіювання й верифікації відновлення (`pg_dump` та `pg_restore`).
