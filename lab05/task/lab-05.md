# Лабораторна робота 05 Керування БД, оптимізація продуктивності та автоматизація

## 🎯 Мета роботи

Навчитися аналізувати та оптимізувати продуктивність баз даних через створення індексів та аналіз планів виконання запитів, опанувати механізми автоматизації за допомогою тригерів та представлень, освоїти базові операції адміністрування СУБД, включаючи керування правами доступу та резервне копіювання.

## ✅ Завдання

### Рівень 1

Використовуючи створену в попередніх роботах базу даних:

1. Проаналізувати продуктивність трьох складних запитів за допомогою команди `EXPLAIN ANALYZE`.
2. Створити три індекси для оптимізації найбільш повільних запитів та перевірити покращення продуктивності.
3. Створити два представлення (VIEW) для спрощення доступу до часто використовуваних запитів.
4. Розробити тригер для автоматичного логування операцій вставки або оновлення в одній з таблиць.
5. Створити нового користувача з обмеженими правами доступу до певних таблиць.

### Рівень 2

Додатково до рівня 1:

1. Створити складне представлення з можливістю оновлення через правила (RULES).
2. Реалізувати тригер для валідації даних перед вставкою з відхиленням некоректних значень.
3. Розробити систему логування змін з окремою таблицею audit_log, яка зберігає:
    - тип операції (INSERT, UPDATE, DELETE)
    - назву таблиці
    - часову мітку
    - користувача, який виконав операцію
    - старі та нові значення (для UPDATE)
4. Створити часткові індекси для оптимізації запитів з WHERE умовами.
5. Виконати резервне копіювання бази даних командою `pg_dump` та відновлення з резервної копії.

### Рівень 3

Додатково до рівня 2:

1. Створити матеріалізоване представлення (MATERIALIZED VIEW) з агрегованими даними та налаштувати його автоматичне оновлення через тригери.
2. Реалізувати каскадні тригери для підтримки складної бізнес-логіки між таблицями.
3. Розробити систему ролей з ієрархією прав доступу (адміністратор, модератор, звичайний користувач).
4. Створити збережену процедуру для автоматизованої оптимізації бази даних (оновлення статистики, перебудова індексів).
5. Розробити скрипт для автоматизованого моніторингу продуктивності з виведенням статистики використання індексів та найповільніших запитів.


## 🖥️ Програмне забезпечення

- [PostgreSQL](https://www.postgresql.org) (актуальна підтримувана версія, рекомендовано 16 або новіша)
- pgAdmin або DBeaver (за бажанням)

## 👥 Форма виконання роботи

Форма виконання роботи **індивідуальна**.

## 📝 Критерії оцінювання


### Рівень 1 - Обовʼязковий мінімум

- Виконано аналіз продуктивності трьох запитів з використанням EXPLAIN ANALYZE (8 балів).
- Створено три коректних індекси з перевіркою покращення продуктивності (10 балів).
- Реалізовано два представлення для спрощення складних запитів (8 балів).
- Створено функціонуючий тригер для логування операцій (10 балів).
- Налаштовано користувача з правильно обмеженими правами доступу (8 балів).

**Мінімальний поріг для рівня 1: 35 балів (оцінка "задовільно")**

### Рівень 2 - Додаткова функціональність

Усі завдання рівня 1 плюс:

- Створено представлення з можливістю оновлення через правила (5 балів).
- Реалізовано тригер валідації з коректною обробкою помилок (8 балів).
- Розроблено повноцінну систему логування всіх типів операцій (8 балів).
- Створено часткові індекси з аналізом їх ефективності (4 бали).
- Виконано резервне копіювання та успішне відновлення бази даних (5 балів).

**Діапазон для рівня 2: 50-74 бали (оцінка "добре")**

### Рівень 3 - Творче розширення

Усі завдання рівня 2 плюс:

- Створено матеріалізоване представлення з автоматичним оновленням (6 балів).
- Реалізовано каскадні тригери для складної бізнес-логіки (6 балів).
- Розроблено ієрархію ролей з детальною системою прав (6 балів).
- Створено збережену процедуру для автоматизованого обслуговування (4 бали).
- Розроблено скрипти моніторингу з аналізом використання індексів (4 бали).

**Діапазон для рівня 3: 75-100 балів (оцінка "відмінно")**


## ⏰ Політика щодо дедлайнів

При порушенні встановленого терміну здачі лабораторної роботи максимальна можлива оцінка становить "добре", незалежно від якості виконаної роботи. Винятки можливі лише за поважних причин, підтверджених документально.

## 📚 Теоретичні відомості


### Аналіз продуктивності запитів

PostgreSQL надає потужний інструментарій для аналізу виконання запитів через команду `EXPLAIN`, яка показує план виконання запиту без його фактичного виконання, та `EXPLAIN ANALYZE`, яка виконує запит і повертає реальний час виконання. Для докладнішої картини використовуйте `EXPLAIN (ANALYZE, BUFFERS)` — вона додатково показує кількість прочитаних сторінок (у PostgreSQL 18 і новіших `BUFFERS` виводиться за замовчуванням разом з `ANALYZE`).

!!! warning "Увага"
    `EXPLAIN ANALYZE` **справді виконує** запит. Якщо ви аналізуєте `INSERT`, `UPDATE` або `DELETE`, обгортайте команду в транзакцію з відкатом: `BEGIN; EXPLAIN ANALYZE ...; ROLLBACK;`.

Основні типи сканування таблиць:

- **Sequential Scan** — послідовне читання всіх рядків таблиці, використовується коли немає підходящих індексів або таблиця мала.
- **Index Scan** — використання індексу для вибірки конкретних рядків, ефективне для невеликої кількості результатів.
- **Index Only Scan** — найшвидший варіант, коли всі необхідні дані містяться безпосередньо в індексі.
- **Bitmap Index Scan** — використовується для великої кількості рядків, створює bitmap відповідних сторінок.

Ключові метрики в результатах EXPLAIN:

- **cost** — оціночна вартість операції (стартова та загальна).
- **rows** — очікувана кількість рядків.
- **width** — середній розмір рядка в байтах.
- **actual time** — реальний час виконання (тільки в EXPLAIN ANALYZE).

### Індексація

Індекс це допоміжна структура даних, яка прискорює пошук записів у таблиці. PostgreSQL підтримує різні типи індексів:

**B-tree індекси** — стандартний тип, підходить для більшості випадків, ефективний для операцій порівняння та сортування.

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_date ON orders(order_date DESC);
```

**Часткові індекси** — індексують тільки ті рядки, що задовольняють певній умові, економлять місце та прискорюють запити з відповідними WHERE умовами.

```sql
CREATE INDEX idx_active_users ON users(username) WHERE status = 'active';
```

**Складені індекси** — індексують кілька стовпців одночасно, порядок стовпців важливий.

```sql
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
```

**Унікальні індекси** — гарантують унікальність значень, автоматично створюються для PRIMARY KEY та UNIQUE обмежень.

```sql
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);
```

Рекомендації щодо використання індексів:

- Створювати індекси на стовпцях, що часто використовуються в WHERE, JOIN, ORDER BY.
- Уникати надмірної індексації, оскільки кожен індекс уповільнює операції INSERT, UPDATE, DELETE.
- Регулярно оновлювати статистику командою `ANALYZE` для коректної роботи оптимізатора.
- Періодично перебудовувати індекси командою `REINDEX` для підтримки їх ефективності.

### Представлення (Views)

Представлення це віртуальна таблиця, визначена SQL запитом. Вони не зберігають дані фізично, а виконують запит кожного разу при зверненні.

**Переваги використання представлень:**

- Спрощення складних запитів через збереження їх як іменованих об'єктів.
- Забезпечення безпеки через обмеження доступу до певних стовпців або рядків.
- Логічна незалежність даних від фізичної структури таблиць.
- Стандартизація доступу до даних для різних користувачів.

```sql
CREATE VIEW active_users_with_orders AS
SELECT
    u.user_id,
    u.username,
    u.email,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.status = 'active'
GROUP BY u.user_id, u.username, u.email;
```

**Матеріалізовані представлення** зберігають результат запиту фізично, що значно прискорює доступ до агрегованих даних, але вимагає періодичного оновлення.

```sql
CREATE MATERIALIZED VIEW monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

-- Оновлення матеріалізованого представлення
REFRESH MATERIALIZED VIEW monthly_sales_summary;
```

### Тригери

Тригер це спеціальна збережена процедура, яка автоматично виконується при настанні певної події (INSERT, UPDATE, DELETE) на таблиці. Тригери використовуються для:

- Автоматичного логування змін у базі даних.
- Валідації даних перед їх збереженням.
- Підтримки складної бізнес-логіки та обмежень цілісності.
- Каскадного оновлення або видалення пов'язаних записів.
- Автоматичного заповнення обчислюваних полів.

Тригер складається з двох частин: функції тригера та самого тригера.

```sql
-- Функція тригера для логування
-- (структуру таблиці audit_log див. у кроці 5 ходу роботи)
CREATE OR REPLACE FUNCTION log_user_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, record_id, new_values, changed_by)
        VALUES ('users', 'INSERT', NEW.user_id, to_jsonb(NEW), current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_values, new_values, changed_by)
        VALUES ('users', 'UPDATE', NEW.user_id, to_jsonb(OLD), to_jsonb(NEW), current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Створення тригера
CREATE TRIGGER trg_user_changes
AFTER INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_changes();
```

Типи тригерів за часом виконання:

- **BEFORE** — виконується перед операцією, може змінити або відхилити дані.
- **AFTER** — виконується після успішного завершення операції.
- **INSTEAD OF** — замінює стандартну операцію, використовується для представлень.

Рівні виконання тригерів:

- **FOR EACH ROW** — виконується для кожного рядка, що змінюється.
- **FOR EACH STATEMENT** — виконується один раз для всієї операції.

### Керування користувачами та правами доступу

PostgreSQL має розвинену систему керування правами доступу на рівні баз даних, схем, таблиць та навіть стовпців.

Створення користувача:

```sql
CREATE USER analyst WITH PASSWORD 'secure_password';
CREATE USER developer WITH PASSWORD 'dev_pass' CREATEDB;
```

Надання прав доступу:

```sql
-- Право підключення до бази даних
GRANT CONNECT ON DATABASE company_db TO analyst;

-- Право використання схеми
GRANT USAGE ON SCHEMA public TO analyst;

-- Права на таблиці
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;
GRANT SELECT, INSERT, UPDATE ON users TO developer;
-- Права на окремі стовпці
GRANT SELECT (user_id, username) ON users TO analyst;

-- Права на послідовності (для SERIAL / IDENTITY)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO developer;
```

Команди `GRANT ... ON ALL TABLES` діють лише на вже наявні об'єкти. Щоб права поширювалися й на таблиці, створені пізніше, використовують `ALTER DEFAULT PRIVILEGES`:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO analyst;
```

Із PostgreSQL 14 також існують готові вбудовані ролі `pg_read_all_data` та `pg_write_all_data`. Паролі за замовчуванням зберігаються з алгоритмом SCRAM-SHA-256 (`password_encryption`); у навчальних прикладах використовуйте власні надійні паролі, а не наведені тут.

Відкликання прав:

```sql
REVOKE INSERT, UPDATE ON users FROM analyst;
REVOKE ALL PRIVILEGES ON DATABASE company_db FROM developer;
```

Ролі дозволяють групувати користувачів з однаковими правами:

```sql
-- Створення ролі
CREATE ROLE readonly;
GRANT CONNECT ON DATABASE company_db TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

-- Призначення ролі користувачу
GRANT readonly TO analyst;
```

### Резервне копіювання та відновлення

Регулярне створення резервних копій критично важливе для збереження даних. PostgreSQL надає кілька інструментів для резервного копіювання.

**Логічне резервне копіювання з pg_dump:**

```bash
# Копіювання всієї бази даних
pg_dump -U postgres -d company_db -F c -f backup_company.dump

# Копіювання в SQL формат
pg_dump -U postgres -d company_db -f backup_company.sql

# Копіювання окремої таблиці
pg_dump -U postgres -d company_db -t users -f backup_users.sql

# Копіювання з стисненням
pg_dump -U postgres -d company_db -F c -Z 9 -f backup_company.dump
```

Параметри pg_dump:

- `-F c` — custom format, дозволяє вибіркове відновлення.
- `-F p` — plain text SQL формат.
- `-Z` — рівень стиснення (0-9).
- `-t` — вказати конкретну таблицю.
- `-n` (`--schema`) — вказати конкретну схему.
- `-Z` також приймає вказівку алгоритму, наприклад `-Z zstd:5` або `-Z lz4` (PostgreSQL 16 і новіші).

**Відновлення з резервної копії:**

```bash
# Відновлення з custom format
pg_restore -U postgres -d company_db -F c backup_company.dump

# Відновлення з SQL файлу
psql -U postgres -d company_db -f backup_company.sql

# Відновлення конкретної таблиці
pg_restore -U postgres -d company_db -t users backup_company.dump

# Відновлення без створення власників
pg_restore -U postgres -d company_db --no-owner backup_company.dump
```

Стратегії резервного копіювання:

- **Повне копіювання** — створення повної копії бази даних регулярно (наприклад, щоденно).
- **Інкрементальне копіювання** — збереження тільки змін з моменту останнього копіювання. Це фізичне копіювання: `pg_dump` його не підтримує, натомість `pg_basebackup` у PostgreSQL 17 і новіших має режим `--incremental`.
- **Point-in-time recovery** — можливість відновити базу на конкретний момент часу. Потребує базової фізичної копії (`pg_basebackup`) та архіву WAL-журналів (`archive_mode`, `archive_command`); під час відновлення в `postgresql.conf` задають `restore_command` і `recovery_target_time`, а в каталозі даних створюють файл `recovery.signal`.

## ▶️ Хід роботи

### Крок 1. Підготовка середовища

Переконайтеся, що у вас встановлено PostgreSQL та є доступ до створеної раніше бази даних. Підключіться до бази даних через командний рядок або графічний інтерфейс (pgAdmin, DBeaver).

```bash
psql -U postgres -d company_db
```

### Крок 2. Аналіз продуктивності запитів

Виберіть три складних запити з попередніх лабораторних робіт або створіть нові. Проаналізуйте їх продуктивність за допомогою EXPLAIN ANALYZE.

!!! note "Обсяг даних"
    На таблицях із кількома десятками рядків оптимізатор майже завжди обирає Sequential Scan, і ефекту від індексів ви не побачите. Перед аналізом наповніть таблиці великою кількістю тестових даних (наприклад, 100 000 користувачів і 500 000 замовлень) і оновіть статистику. Приклад для таблиць із цієї лабораторної (адаптуйте назви та стовпці до своєї схеми):

    ```sql
    INSERT INTO users (username, email, status, created_at)
    SELECT 'user_' || g,
           'user_' || g || '@example.com',
           CASE WHEN g % 5 = 0 THEN 'inactive' ELSE 'active' END,
           NOW() - (random() * INTERVAL '1000 days')
    FROM generate_series(1, 100000) AS g;

    INSERT INTO orders (user_id, order_date, total_amount)
    SELECT (random() * 99999)::int + 1,
           NOW() - (random() * INTERVAL '1000 days'),
           round((random() * 5000)::numeric, 2)
    FROM generate_series(1, 500000);

    ANALYZE;
    ```

```sql
-- Приклад аналізу запиту
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    u.username,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.created_at > '2025-01-01'
GROUP BY u.user_id, u.username
HAVING COUNT(o.order_id) > 5
ORDER BY total_spent DESC;
```

Зверніть увагу на:

- Типи сканування таблиць (Sequential Scan, Index Scan).
- Час виконання кожного етапу.
- Кількість оброблених рядків.
- Загальний час виконання запиту.

Збережіть результати аналізу для порівняння після створення індексів.

### Крок 3. Створення індексів для оптимізації

На основі результатів аналізу визначте, які стовпці найчастіше використовуються у WHERE, JOIN, ORDER BY та GROUP BY. Створіть індекси для цих стовпців.

```sql
-- Індекс для стовпця з датою створення
CREATE INDEX idx_users_created_at ON users(created_at);

-- Індекс для стовпця зовнішнього ключа (використовується в JOIN)
-- PostgreSQL не створює його автоматично для FOREIGN KEY
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Індекс для сортування
CREATE INDEX idx_orders_amount ON orders(total_amount DESC);
```

Після створення індексів повторно виконайте EXPLAIN ANALYZE для тих самих запитів та порівняйте результати. Обчисліть відсоток покращення продуктивності.

### Крок 4. Створення представлень

Створіть два представлення для спрощення доступу до часто використовуваних запитів.

```sql
-- Просте представлення для активних користувачів
CREATE VIEW active_users AS
SELECT user_id, username, email, created_at
FROM users
WHERE status = 'active';

-- Складне представлення з агрегацією
CREATE VIEW user_statistics AS
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT o.order_id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;
```

Перевірте роботу представлень простими SELECT запитами:

```sql
SELECT * FROM active_users LIMIT 10;
SELECT * FROM user_statistics ORDER BY total_spent DESC LIMIT 10;
```

### Крок 5. Реалізація тригерів

Створіть таблицю для логування операцій, якщо її ще немає:

```sql
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT NOW()
);
```

Створіть функцію тригера та сам тригер для логування операцій INSERT або UPDATE:

```sql
-- Функція для логування вставки
CREATE OR REPLACE FUNCTION log_user_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, new_values, changed_by)
    VALUES ('users', TG_OP, NEW.user_id, row_to_json(NEW)::jsonb, current_user);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Тригер на вставку
CREATE TRIGGER trg_user_insert
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_insert();
```

Для валідації даних створіть BEFORE тригер:

```sql
-- Функція валідації email
CREATE OR REPLACE FUNCTION validate_user_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Тригер валідації
CREATE TRIGGER trg_validate_email
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION validate_user_email();
```

Протестуйте роботу тригерів:

```sql
-- Вставка коректного запису
INSERT INTO users (username, email, status)
VALUES ('test_user', 'test@example.com', 'active');

-- Спроба вставки некоректного email (має бути відхилена)
INSERT INTO users (username, email, status)
VALUES ('invalid_user', 'invalid-email', 'active');

-- Перевірка логів
SELECT * FROM audit_log ORDER BY changed_at DESC LIMIT 5;
```

### Крок 6. Керування користувачами та правами

Створіть нового користувача з обмеженими правами:

```sql
-- Створення користувача
CREATE USER report_viewer WITH PASSWORD 'secure_password';

-- Надання базових прав
GRANT CONNECT ON DATABASE company_db TO report_viewer;
GRANT USAGE ON SCHEMA public TO report_viewer;

-- Надання прав тільки на читання певних таблиць
GRANT SELECT ON users, orders TO report_viewer;

-- Надання доступу до представлень
GRANT SELECT ON user_statistics, active_users TO report_viewer;
```

Перевірте права доступу, підключившись під новим користувачем:

```bash
psql -U report_viewer -d company_db
```

Спробуйте виконати операції читання та запису для перевірки обмежень.

### Крок 7. Резервне копіювання

Створіть резервну копію бази даних:

```bash
# Повне копіювання бази даних
pg_dump -U postgres -d company_db -F c -f backup_$(date +%Y%m%d).dump

# Копіювання в SQL формат
pg_dump -U postgres -d company_db > backup_company.sql
```

Для тестування відновлення створіть тестову базу даних та відновіть в неї резервну копію:

```bash
# Створення тестової бази
createdb -U postgres test_restore

# Відновлення з резервної копії
pg_restore -U postgres -d test_restore backup_20260101.dump   # підставте назву свого файлу

# Або для SQL формату
psql -U postgres -d test_restore -f backup_company.sql
```

### Крок 8. Додаткові завдання для рівня 2

**Представлення з можливістю оновлення через правила (RULES):**

Прості представлення (одна таблиця, без агрегації) PostgreSQL робить оновлюваними автоматично. Правила потрібні, коли представлення складніше — наприклад, об'єднує кілька таблиць — і треба вручну визначити, що станеться при `UPDATE`.

```sql
CREATE VIEW user_contacts AS
SELECT user_id, username, email, status
FROM users
WHERE status <> 'deleted';

-- Правило: UPDATE через представлення змінює лише дозволені стовпці
CREATE RULE user_contacts_update AS
ON UPDATE TO user_contacts
DO INSTEAD
    UPDATE users
    SET email = NEW.email,
        status = NEW.status
    WHERE user_id = OLD.user_id;

-- Перевірка
UPDATE user_contacts SET email = 'new@example.com' WHERE user_id = 1;
```

!!! info "Правила чи тригери INSTEAD OF"
    Система правил (RULES) — застарілий механізм, який у документації PostgreSQL рекомендують замінювати тригерами `INSTEAD OF`. У цій роботі правила вивчаються для повноти уявлення про можливості СУБД; для нових проєктів надавайте перевагу тригерам.

**Часткові індекси:**

```sql
-- Індекс тільки для активних користувачів
CREATE INDEX idx_active_users_username ON users(username)
WHERE status = 'active';

-- Індекс для замовлень великої вартості
CREATE INDEX idx_big_orders ON orders(order_date, user_id)
WHERE total_amount > 1000;
```

!!! warning "Умова часткового індексу"
    Предикат `WHERE` має складатися лише з незмінних (IMMUTABLE) виразів. Умови з `CURRENT_DATE` чи `NOW()` (наприклад, «за останні 30 днів») створити не вдасться — PostgreSQL поверне помилку `functions in index predicate must be marked IMMUTABLE`. Після створення індексу перевірте через `EXPLAIN`, що запит із тією самою умовою `WHERE` його використовує.

**Розширена система логування:**

```sql
CREATE OR REPLACE FUNCTION comprehensive_audit_log()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_values, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, OLD.user_id, row_to_json(OLD)::jsonb, current_user);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_values, new_values, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.user_id, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, record_id, new_values, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.user_id, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_comprehensive_audit
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION comprehensive_audit_log();
```

!!! note "Зверніть увагу"
    - Перед створенням цього тригера видаліть простіший `trg_user_insert` (`DROP TRIGGER trg_user_insert ON users;`), інакше кожна вставка логуватиметься двічі.
    - Функція звертається до поля `user_id`, тому підходить лише для таблиць, що мають такий стовпець. Для універсальної версії можна передавати назву ключового стовпця через аргумент тригера (`TG_ARGV[0]`) або записувати весь рядок лише у `old_values`/`new_values`.

### Крок 9. Творче розширення для рівня 3

**Матеріалізоване представлення:**

```sql
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT
    DATE(order_date) as sale_date,
    COUNT(*) as order_count,
    SUM(total_amount) as daily_revenue,
    AVG(total_amount) as average_order
FROM orders
GROUP BY DATE(order_date);

-- Унікальний індекс: потрібен для REFRESH ... CONCURRENTLY та швидкого пошуку
CREATE UNIQUE INDEX idx_daily_sales_date ON daily_sales_summary(sale_date);
```

**Автоматичне оновлення матеріалізованого представлення:**

```sql
-- Функція оновлення матеріалізованого представлення
CREATE OR REPLACE FUNCTION refresh_daily_sales()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_summary;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Тригер для автоматичного оновлення
CREATE TRIGGER trg_refresh_sales
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_daily_sales();
```

!!! note "Про навантаження"
    Повне оновлення після кожного оператора змінення даних — навчальний приклад: на великих таблицях воно сильно сповільнює запис. У реальних системах представлення оновлюють за розкладом (наприклад, через розширення `pg_cron`) або підтримують інкрементально в таблиці-підсумку.

**Ієрархія ролей:**

```sql
-- Створення базових ролей
CREATE ROLE readonly NOLOGIN;
GRANT CONNECT ON DATABASE company_db TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

CREATE ROLE readwrite NOLOGIN;
GRANT readonly TO readwrite;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite;

CREATE ROLE admin NOLOGIN;
GRANT readwrite TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

-- Створення користувачів з ролями
CREATE USER viewer WITH PASSWORD 'view_pass';
GRANT readonly TO viewer;

CREATE USER moderator WITH PASSWORD 'mod_pass';
GRANT readwrite TO moderator;

CREATE USER administrator WITH PASSWORD 'admin_pass';
GRANT admin TO administrator;
```

**Збережена процедура для обслуговування:**

```sql
-- Таблиця журналу обслуговування
CREATE TABLE IF NOT EXISTS maintenance_log (
    log_id SERIAL PRIMARY KEY,
    operation TEXT NOT NULL,
    executed_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE maintain_database()
LANGUAGE plpgsql
AS $$
DECLARE
    tbl RECORD;
BEGIN
    -- Оновлення статистики оптимізатора
    ANALYZE;

    -- Перебудова індексів таблиць поточної схеми
    FOR tbl IN
        SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('REINDEX TABLE %I.%I', tbl.schemaname, tbl.tablename);
    END LOOP;

    -- Логування виконання
    INSERT INTO maintenance_log (operation) VALUES ('ANALYZE + REINDEX');

    RAISE NOTICE 'Database maintenance completed successfully';
END;
$$;

-- Виконання процедури
CALL maintain_database();
```

!!! warning "Чому тут немає VACUUM"
    Команди `VACUUM` та `REINDEX DATABASE` (а також `REINDEX ... CONCURRENTLY`) не можна виконувати всередині функції чи процедури — PostgreSQL повертає помилку, бо вони не працюють у блоці транзакції. Очищення мертвих кортежів зазвичай виконує фоновий процес autovacuum; за потреби `VACUUM` запускають окремо, наприклад утилітою `vacuumdb` у скрипті за розкладом.

**Моніторинг продуктивності:**

Для пошуку найповільніших запитів потрібне розширення `pg_stat_statements`. Додайте в `postgresql.conf` рядок `shared_preload_libraries = 'pg_stat_statements'`, перезапустіть сервер і виконайте в потрібній базі `CREATE EXTENSION pg_stat_statements;`.

```sql
-- Запит для аналізу використання індексів
-- (у поданні pg_stat_user_indexes стовпці називаються relname та indexrelname)
SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY relname, indexrelname;

-- Запит для пошуку найповільніших запитів
SELECT
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Крок 10. Документування результатів

Створіть звіт у форматі Markdown з наступною структурою:

1. Результати аналізу продуктивності до та після оптимізації.
2. Опис створених індексів з обґрунтуванням їх необхідності.
3. SQL код всіх створених представлень та тригерів.
4. Скріншоти або текстовий вивід перевірки роботи тригерів.
5. Документація системи прав доступу для різних ролей користувачів.
6. Висновки щодо покращення продуктивності та рекомендації.

[🔼 Здати лабораторну роботу](https://moodle.vcolnuft.volyn.ua/moodle/course/view.php?id=32#section-2)


## ❓ Контрольні запитання

1. Поясніть різницю між EXPLAIN та EXPLAIN ANALYZE. Коли краще використовувати кожну з цих команд?
2. Які типи індексів підтримує PostgreSQL? Опишіть ситуації, коли доцільно використовувати кожен тип.
3. Що таке часткові індекси та в яких випадках їх використання дає найбільший виграш у продуктивності?
4. Яка різниця між звичайним представленням (VIEW) та матеріалізованим представленням (MATERIALIZED VIEW)? Наведіть приклади використання.
5. Опишіть життєвий цикл тригера. Яка різниця між BEFORE, AFTER та INSTEAD OF тригерами?
6. Чому важливо обмежувати права доступу користувачів до бази даних? Які рівні гранулярності підтримує PostgreSQL?
7. Поясніть різницю між логічним та фізичним резервним копіюванням. Які переваги та недоліки кожного підходу?
8. Що таке каскадні тригери? Наведіть приклад ситуації, коли вони необхідні.
9. Як індекси впливають на продуктивність операцій INSERT, UPDATE та DELETE? Чому надмірна індексація може бути шкідливою?
10. Опишіть стратегію point-in-time recovery. Які компоненти PostgreSQL необхідні для її реалізації?
