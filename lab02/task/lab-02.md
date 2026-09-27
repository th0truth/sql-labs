# Лабораторна робота 02 Створення складних SQL запитів

## 🎯 Мета роботи

Набути практичних навичок створення складних SQL запитів для аналізу даних, опанувати техніки з'єднання таблиць, використання агрегатних функцій, групування даних та написання підзапитів для розв'язання аналітичних завдань у реляційних базах даних.

## ✅ Завдання

### Рівень 1

1. З'єднання таблиць
   - Створити запити з використанням INNER JOIN для отримання інформації з кількох пов'язаних таблиць
   - Використати LEFT JOIN для включення всіх записів з головної таблиці
   - Створити запит з множинними з'єднаннями (мінімум 3 таблиці)
2. Агрегатні функції
   - Використати функції COUNT, SUM, AVG, MIN, MAX для обчислення статистичних показників
   - Створити запити з GROUP BY для групування даних за різними критеріями
   - Застосувати HAVING для фільтрації груп за умовами
3. Базові підзапити
   - Створити підзапит у розділі WHERE для фільтрації записів
   - Використати підзапит у розділі SELECT для додавання обчислювальних полів
   - Реалізувати запит з використанням операторів IN та EXISTS

### Рівень 2

4. Складні з'єднання та аналіз
   - Створити запит з RIGHT JOIN та FULL OUTER JOIN
   - Реалізувати самоз'єднання (self-join) таблиці
   - Створити запит з умовним з'єднанням (з додатковими умовами в ON)
5. Вікні функції та аналітика
   - Використати ROW_NUMBER(), RANK(), DENSE_RANK() для ранжування
   - Застосувати LAG(), LEAD() для порівняння з попередніми/наступними записами
   - Створити запити з PARTITION BY для аналізу в розрізах

### Рівень 3

6. Оптимізація та складна аналітика
   - Створити матеріалізоване представлення (materialized view) для складних запитів
   - Реалізувати рекурсивний запит з використанням CTE (Common Table Expression)
   - Створити запит з динамічним SQL або збереженою процедурою для параметризованої аналітики


## 🖥️ Програмне забезпечення

- supabase [supabase.com](https://supabase.com) - хмарний сервіс для роботи з PostgreSQL.

## 👥 Форма виконання роботи

Форма виконання роботи **індивідуальна**.

## 📝 Критерії оцінювання

- середній рівень (оцінка "задовільно") - виконано завдання рівня 1. Допускаються незначні помилки у звіті. Під час захисту здобувач освіти демонструє базове розуміння технологій та здатність вирішувати стандартні завдання;
- достатній рівень (оцінка "добре") - виконано всі вимоги рівня 2. Під час захисту допускаються невеликі помилки та неповне розуміння деяких аспектів роботи технологій;
- високий рівень (оцінка "відмінно") - виконано завдання рівня 3. Під час захисту продемонстровано розуміння принципів роботи технологій, здобувач освіти може пояснити та обґрунтувати прийняті рішення, проявлено творчий підхід до виконання завдання.

## ⏰ Політика щодо дедлайнів

При порушенні встановленого терміну здачі лабораторної роботи максимальна можлива оцінка становить "добре", незалежно від якості виконаної роботи. Винятки можливі лише за поважних причин, підтверджених документально.

## 📚 Теоретичні відомості

## Теоретичні відомості

### З'єднання таблиць (JOIN) - основа роботи з реляційними базами даних

Уявіть, що у вас є дві адресні книги: одна з іменами та телефонами, друга з іменами та адресами. Щоб отримати повну інформацію про людину (ім'я, телефон, адреса), вам потрібно знайти відповідні записи в обох книгах за ім'ям. Саме це робить операція JOIN у базах даних.

#### Чому потрібні з'єднання?

Реляційні бази даних побудовані за принципом нормалізації - інформація розбита на окремі таблиці, щоб уникнути дублювання. Наприклад, замість того, щоб в таблиці "Замовлення" повторювати назву товару в кожному рядку, ми зберігаємо лише ID товару, а повну назву тримаємо в окремій таблиці "Товари".

```
Погана структура (ненормалізована):
ORDERS:
order_id | customer_name | product_name      | price
1        | Petrov        | iPhone 15         | 29999
2        | Petrov        | iPhone 15         | 29999  ← Дублювання!
3        | Ivanenko      | Samsung Galaxy    | 27999

Хороша структура (нормалізована):
ORDERS:              PRODUCTS:
order_id | product_id   product_id | product_name      | price
1        | 101          101        | iPhone 15         | 29999
2        | 101          102        | Samsung Galaxy    | 27999
3        | 102
```

#### Синтаксис з'єднань

**Загальний синтаксис:**

```sql
SELECT стовпці
FROM таблиця1 [псевдонім1]
[INNER|LEFT|RIGHT|FULL OUTER] JOIN таблиця2 [псевдонім2]
    ON умова_з'єднання
[WHERE умови_фільтрації]
[ORDER BY стовпці_сортування];
```

**Ключові елементи синтаксису:**

- `ON` - обов'язкова умова з'єднання (замість старого WHERE)
- Псевдоніми таблиць роблять код коротшим і читабельнішим
- Умова зазвичай порівнює первинний ключ з зовнішнім ключем

#### Типи з'єднань з детальними поясненнями

**INNER JOIN - "Тільки спільне"**

Повертає записи, які є в обох таблицях. Як перетин двох кіл у діаграмі Венна.

```sql
-- Повний синтаксис
SELECT p.product_name, c.category_name, p.unit_price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id;

-- Скорочений варіант (INNER можна опустити)
SELECT p.product_name, c.category_name, p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```

**Особливості INNER JOIN:**

- Виключає NULL значення автоматично
- Найшвидший тип з'єднання
- Якщо в одній з таблиць немає відповідності, рядок не потрапляє в результат

**LEFT JOIN (LEFT OUTER JOIN) - "Усе з лівої + відповідності з правої"**

```sql
-- Показати всіх клієнтів, навіть тих, хто не робив замовлень
SELECT c.contact_name, c.customer_type,
       COUNT(o.order_id) as order_count,
       COALESCE(SUM(o.freight), 0) as total_freight
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.contact_name, c.customer_type;
```

**Особливості LEFT JOIN:**

- Завжди включає ВСІ рядки з лівої (першої) таблиці
- Для рядків без відповідностей в правій таблиці заповнює NULL
- Використовуйте `COALESCE()` або `ISNULL()` для обробки NULL значень
- Корисний для знаходження "сиріт" - записів без зв'язків

**RIGHT JOIN - рідко використовується**

```sql
-- Показати всі категорії, навіть якщо в них немає товарів
SELECT c.category_name, COUNT(p.product_id) as product_count
FROM products p
RIGHT JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name;
```

**Примітка:** RIGHT JOIN зазвичай переписують як LEFT JOIN для кращої читабельності.

**FULL OUTER JOIN - рідко потрібен**

```sql
-- Показати всі категорії та всі товари
SELECT c.category_name, p.product_name
FROM categories c
FULL OUTER JOIN products p ON c.category_id = p.category_id;
```

#### Множинні з'єднання - поетапний підхід

```sql
-- Крок за кроком: замовлення → товари → категорії → постачальники
SELECT
    o.order_id,
    o.order_date,
    p.product_name,
    c.category_name,
    s.company_name as supplier,
    oi.quantity,
    oi.unit_price
FROM orders o                                          -- Початкова таблиця
    JOIN order_items oi ON o.order_id = oi.order_id  -- Крок 1: деталі замовлення
    JOIN products p ON oi.product_id = p.product_id   -- Крок 2: інформація про товар
    JOIN categories c ON p.category_id = c.category_id -- Крок 3: категорія
    JOIN suppliers s ON p.supplier_id = s.supplier_id  -- Крок 4: постачальник
WHERE o.order_date >= '2024-01-01';
```

**Порядок з'єднань має значення для продуктивності:**

1. Починайте з таблиці з найменшою кількістю рядків після фільтрації
2. З'єднуйте спочатку таблиці з найкращою селективністю
3. WHERE умови застосовуйте якомога раніше

### Агрегатні функції - підрахунок та аналіз

Агрегатні функції дозволяють "згорнути" багато рядків в одне підсумкове значення. Це як калькулятор для цілої колонки даних.

#### Основні функції з детальними поясненнями

**COUNT() - Рахуємо кількість**

```sql
-- Три різні варіанти COUNT
SELECT
    COUNT(*) as total_rows,           -- Всі рядки, включаючи NULL
    COUNT(product_name) as named_products,  -- Тільки не-NULL назви
    COUNT(DISTINCT category_id) as unique_categories -- Унікальні категорії
FROM products;
```

**Важливі особливості COUNT:**

- `COUNT(*)` рахує ВСІ рядки, навіть з NULL
- `COUNT(column)` ігнорує NULL значення
- `COUNT(DISTINCT column)` рахує тільки унікальні не-NULL значення

**SUM() - Сумування з нюансами**

```sql
-- Обережно з NULL!
SELECT
    SUM(unit_price) as total_price,                    -- NULL ігноруються
    SUM(unit_price * units_in_stock) as total_value,   -- NULL дає NULL
    SUM(COALESCE(unit_price, 0) * COALESCE(units_in_stock, 0)) as safe_total
FROM products;
```

**Особливості SUM:**

- Повертає NULL, якщо ВСІ значення NULL
- Ігнорує NULL, але якщо в виразі є NULL, результат буде NULL
- Працює тільки з числовими типами даних

**AVG() - Середнє арифметичне**

```sql
-- Різниця між AVG та ручним розрахунком
SELECT
    AVG(unit_price) as avg_by_function,
    SUM(unit_price) / COUNT(unit_price) as manual_avg,  -- Те саме
    SUM(unit_price) / COUNT(*) as avg_with_nulls        -- Інший результат!
FROM products;
```

**MIN() та MAX() - не тільки для чисел**

```sql
-- Працюють з різними типами даних
SELECT
    MIN(unit_price) as cheapest,
    MAX(unit_price) as most_expensive,
    MIN(product_name) as first_alphabetically,  -- 'A...'
    MAX(order_date) as latest_order             -- Найсвіжіше замовлення
FROM products, orders;
```

#### GROUP BY - Детальна семантика

GROUP BY розбиває дані на групи та застосовує агрегатні функції до кожної групи окремо.

**Як працює GROUP BY поетапно:**

1. **Етап сканування:** Читає всі рядки з таблиці
2. **Етап групування:** Розбиває рядки на групи за значеннями GROUP BY стовпців
3. **Етап агрегації:** Застосовує агрегатні функції до кожної групи
4. **Етап результату:** Повертає один рядок на групу

```sql
-- Детальний приклад з поясненнями
SELECT
    category_id,                    -- Обов'язково в GROUP BY
    COUNT(*) as product_count,      -- Агрегатна функція
    AVG(unit_price) as avg_price,   -- Агрегатна функція
    MIN(unit_price) as min_price,   -- Агрегатна функція
    MAX(unit_price) as max_price    -- Агрегатна функція
FROM products
WHERE discontinued = false         -- Фільтрація ДО групування
GROUP BY category_id               -- Групування за категорією
HAVING COUNT(*) > 3               -- Фільтрація ПІСЛЯ групування
ORDER BY avg_price DESC;          -- Сортування результату
```

**Суворе правило SELECT з GROUP BY:**

Після GROUP BY у SELECT можна використовувати ТІЛЬКИ:
- Стовпці з GROUP BY
- Агрегатні функції (COUNT, SUM, AVG, MIN, MAX)
- Константи
- Вирази з вищезазначених елементів

**Часті помилки:**

```sql
-- ПОМИЛКА! Неоднозначність
SELECT category_id, product_name, COUNT(*)  -- product_name не в GROUP BY!
FROM products
GROUP BY category_id;

-- ПРАВИЛЬНО: або додати в GROUP BY
SELECT category_id, product_name, COUNT(*)
FROM products
GROUP BY category_id, product_name;

-- АБО прибрати з SELECT
SELECT category_id, COUNT(*)
FROM products
GROUP BY category_id;
```

#### HAVING vs WHERE - критична різниця

```sql
SELECT category_id, AVG(unit_price) as avg_price, COUNT(*) as product_count
FROM products
WHERE unit_price > 100              -- Фільтрація рядків ДО групування
GROUP BY category_id
HAVING COUNT(*) > 5                 -- Фільтрація груп ПІСЛЯ групування
   AND AVG(unit_price) > 1000;      -- Можна використовувати агрегатні функції
```

**Ключові відмінності:**
- **WHERE:** виконується ДО GROUP BY, не може використовувати агрегатні функції
- **HAVING:** виконується ПІСЛЯ GROUP BY, може використовувати агрегатні функції
- **Продуктивність:** WHERE швидше, оскільки зменшує кількість рядків для групування

### Підзапити - запити всередині запитів

Підзапит - це SQL запит, написаний всередині іншого запиту.

#### Типи підзапитів за результатом

**1. Скалярний підзапит - повертає ОДНЕ значення**

```sql
-- Товари дорожчі за середню ціну
SELECT product_name, unit_price,
       (SELECT AVG(unit_price) FROM products) as avg_price  -- Скалярний підзапит
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);   -- Тут теж скалярний
```

**Особливості скалярних підзапитів:**

- Мусять повертати рівно один рядок і один стовпець
- Якщо повертають більше - помилка виконання
- Якщо повертають 0 рядків - результат NULL
- Можуть використовуватися всюди, де очікується значення

**2. Стовпцевий підзапит - повертає СПИСОК значень**

```sql
-- Товари з активних категорій
SELECT product_name, unit_price
FROM products
WHERE category_id IN (
    SELECT category_id
    FROM categories
    WHERE active = true
);  -- ↑ Стовпцевий підзапит - повертає список ID

-- Альтернативний синтаксис з ANY
SELECT product_name, unit_price
FROM products
WHERE category_id = ANY (
    SELECT category_id FROM categories WHERE active = true
);
```

**3. Табличний підзапит - повертає ТАБЛИЦЮ**

```sql
-- Використання в FROM - підзапит як віртуальна таблиця
SELECT category_stats.category_id,
       category_stats.avg_price,
       category_stats.product_count
FROM (
    SELECT category_id,
           AVG(unit_price) as avg_price,
           COUNT(*) as product_count
    FROM products
    GROUP BY category_id
) as category_stats              -- Обов'язковий псевдонім!
WHERE category_stats.avg_price > 1000;
```

#### Корельовані підзапити - складні, але потужні

Корельований підзапит "дивиться" на дані з зовнішнього запиту і виконується для кожного рядка.

```sql
-- Товари дорожчі за середню ціну у СВОЇЙ категорії
SELECT p1.product_name, p1.unit_price, p1.category_id,
       (SELECT AVG(p2.unit_price)
        FROM products p2
        WHERE p2.category_id = p1.category_id) as category_avg_price
FROM products p1
WHERE p1.unit_price > (
    SELECT AVG(p2.unit_price)
    FROM products p2
    WHERE p2.category_id = p1.category_id  -- ← Корелятивна умова!
);
```

**Як працює корельований підзапит:**

1. Зовнішній запит читає перший рядок
2. Підзапит виконується з використанням значень з цього рядка
3. Результат підзапиту використовується для фільтрації/обчислення
4. Процес повторюється для кожного рядка зовнішнього запиту

**Продуктивність:** Корельовані підзапити повільні, оскільки виконуються N разів (де N - кількість рядків у зовнішній таблиці).

#### Оператори для підзапитів

**EXISTS - перевірка існування**

```sql
-- Клієнти, які робили замовлення (ефективніше за IN)
SELECT customer_id, contact_name
FROM customers c
WHERE EXISTS (
    SELECT 1                    -- Не важливо що SELECT, важливо чи є рядки
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Клієнти БЕЗ замовлень
SELECT customer_id, contact_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

**IN vs EXISTS - коли що використовувати:**

```sql
-- IN краще для невеликих списків констант
SELECT * FROM products WHERE category_id IN (1, 2, 3);

-- EXISTS краще для великих підзапитів
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- Обережно з NULL в IN!
SELECT * FROM products WHERE category_id IN (1, 2, NULL); -- Може дати несподіваний результат
```

### Віконні функції - аналітика без групування

Віконні функції дозволяють робити складні обчислення, зберігаючи всі рядки в результаті. Це як GROUP BY, але без "схлопування" рядків.

#### Детальний синтаксис

```sql
function_name([arguments]) OVER (
    [PARTITION BY column1, column2, ...]     -- Розбиття на групи (необов'язково)
    [ORDER BY column3 [ASC|DESC], ...]       -- Сортування в групі (часто потрібно)
    [ROWS|RANGE BETWEEN frame_start AND frame_end] -- Вікно рядків (рідко)
)
```

**Компоненти OVER клаузули:**

- **PARTITION BY** - розбиває дані на групи (як GROUP BY, але без згортування)
- **ORDER BY** - визначає порядок рядків для ранжування та зміщення
- **Frame specification** - визначає які рядки включати в обчислення

#### Функції ранжування з нюансами

**ROW_NUMBER() - завжди унікальні номери**

```sql
-- Пронумерувати товари за ціною в кожній категорії
SELECT product_name, category_id, unit_price,
       ROW_NUMBER() OVER (
           PARTITION BY category_id
           ORDER BY unit_price DESC, product_name  -- Додатковий критерій для стабільності
       ) as row_num
FROM products;
```

**RANK() - ранги з пропусками**

```sql
-- Ранжування з прогалинами при однакових значеннях
SELECT product_name, unit_price,
       RANK() OVER (ORDER BY unit_price DESC) as price_rank
FROM products;
-- Результат: 1, 2, 2, 4, 5... (3-тя позиція пропущена)
```

**DENSE_RANK() - ранги без пропусків**

```sql
-- Ранжування без прогалин
SELECT product_name, unit_price,
       DENSE_RANK() OVER (ORDER BY unit_price DESC) as dense_rank
FROM products;
-- Результат: 1, 2, 2, 3, 4... (без пропусків)
```

**Практичне порівняння функцій ранжування:**

```sql
SELECT product_name, unit_price,
       ROW_NUMBER() OVER (ORDER BY unit_price DESC) as row_num,
       RANK() OVER (ORDER BY unit_price DESC) as rank_num,
       DENSE_RANK() OVER (ORDER BY unit_price DESC) as dense_rank
FROM products
ORDER BY unit_price DESC;

-- Для цін: 1000, 800, 800, 600
-- row_num:    1,   2,   3,   4
-- rank_num:   1,   2,   2,   4  ← пропуск 3
-- dense_rank: 1,   2,   2,   3  ← без пропуску
```

#### Функції зміщення - порівняння між рядками

**LAG() та LEAD() - дивимося назад та вперед**

```sql
-- Порівняння з попередніми та наступними значеннями
SELECT
    order_date,
    freight,
    LAG(freight, 1, 0) OVER (ORDER BY order_date) as prev_freight,
    LEAD(freight, 1, 0) OVER (ORDER BY order_date) as next_freight,
    freight - LAG(freight, 1, 0) OVER (ORDER BY order_date) as freight_change
FROM orders
ORDER BY order_date;
```

**Синтаксис LAG/LEAD:**

- `LAG(column, offset, default)` - offset рядків назад
- `LEAD(column, offset, default)` - offset рядків вперед
- `default` - значення, якщо немає попереднього/наступного рядка

**FIRST_VALUE() та LAST_VALUE() - межі вікна**

```sql
-- Порівняння з першим та останнім значенням у групі
SELECT product_name, category_id, unit_price,
       FIRST_VALUE(unit_price) OVER (
           PARTITION BY category_id
           ORDER BY unit_price DESC
       ) as highest_in_category,
       LAST_VALUE(unit_price) OVER (
           PARTITION BY category_id
           ORDER BY unit_price DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) as lowest_in_category
FROM products;
```

#### Агрегатні функції як віконні

```sql
-- Накопичувальні та ковзні обчислення
SELECT
    order_date,
    freight,
    -- Накопичувальна сума від початку
    SUM(freight) OVER (ORDER BY order_date) as running_total,
    -- Ковзне середнє за 3 попередні замовлення
    AVG(freight) OVER (
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_3,
    -- Відсоток від загальної суми
    freight * 100.0 / SUM(freight) OVER () as percent_of_total
FROM orders
ORDER BY order_date;
```

#### PARTITION BY vs GROUP BY - критична різниця

```sql
-- GROUP BY - схлопує рядки
SELECT category_id, AVG(unit_price) as avg_price
FROM products
GROUP BY category_id;
-- Результат: один рядок на категорію

-- PARTITION BY - зберігає всі рядки
SELECT product_name, category_id, unit_price,
       AVG(unit_price) OVER (PARTITION BY category_id) as category_avg
FROM products;
-- Результат: кожен товар + середня ціна його категорії
```

### Common Table Expressions (CTE) - структуровані підзапити

CTE дозволяє створити іменований тимчасовий результуючий набір, що існує тільки в рамках одного запиту.

#### Звичайні CTE - для читабельності

```sql
-- Замість важкочитаного вкладеного підзапиту
WITH expensive_products AS (
    SELECT product_id, product_name, unit_price, category_id
    FROM products
    WHERE unit_price > 1000
),
category_stats AS (
    SELECT category_id,
           COUNT(*) as expensive_count,
           AVG(unit_price) as avg_expensive_price
    FROM expensive_products
    GROUP BY category_id
)
-- Тепер використовуємо CTE як звичайні таблиці
SELECT c.category_name, cs.expensive_count, cs.avg_expensive_price
FROM category_stats cs
JOIN categories c ON cs.category_id = c.category_id
WHERE cs.expensive_count > 2;
```

**Переваги CTE:**

- Покращує читабельність складних запитів
- Дозволяє повторно використовувати підзапити
- Можна створити кілька CTE в одному запиті
- CTE може посилатися на попередні CTE

#### Рекурсивні CTE - для ієрархічних даних

```sql
-- Знайти всіх підлеглих менеджера (включаючи підлеглих підлеглих)
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor query (базовий випадок): початкові менеджери
    SELECT employee_id, first_name, last_name, reports_to,
           0 as level,  -- Рівень ієрархії
           first_name || ' ' || last_name as hierarchy_path
    FROM employees
    WHERE reports_to IS NULL  -- Топ-менеджери

    UNION ALL

    -- Recursive query (рекурсивний випадок): знаходимо підлеглих
    SELECT e.employee_id, e.first_name, e.last_name, e.reports_to,
           eh.level + 1,  -- Збільшуємо рівень
           eh.hierarchy_path || ' -> ' || e.first_name || ' ' || e.last_name
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.reports_to = eh.employee_id
    WHERE eh.level < 10  -- Обмеження глибини (захист від нескінченних циклів)
)
SELECT employee_id, first_name, last_name, level, hierarchy_path
FROM employee_hierarchy
ORDER BY level, last_name;
```

**Структура рекурсивного CTE:**

1. **Anchor query** - початкова умова (базовий випадок)
2. **UNION ALL** - об'єднання
3. **Recursive query** - рекурсивна частина, що посилається на саме CTE
4. **Умова зупинки** - обов'язкова для уникнення нескінченних циклів

### Практичні поради по оптимізації

#### Порядок виконання SQL запиту

SQL виконується не в тому порядку, в якому написаний. Розуміння цього допомагає писати ефективніші запити:

1. **FROM / JOIN** - спочатку беремо та з'єднуємо таблиці
2. **WHERE** - фільтруємо рядки (ДО групування!)
3. **GROUP BY** - групуємо рядки
4. **HAVING** - фільтруємо групи (ПІСЛЯ групування!)
5. **SELECT** - вибираємо та обчислюємо стовпці
6. **DISTINCT** - видаляємо дублікати
7. **ORDER BY** - сортуємо результат
8. **LIMIT / OFFSET** - обмежуємо кількість рядків

#### Стратегії оптимізації запитів

**1. Ефективна фільтрація**

```sql
-- Краще: фільтруємо рано
SELECT c.contact_name, COUNT(o.order_id)
FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
                      AND o.order_date >= '2024-01-01'  -- Фільтр в JOIN
WHERE c.customer_type = 'company'                       -- Фільтр перед JOIN
GROUP BY c.customer_id, c.contact_name;

-- Гірше: фільтруємо пізно
SELECT c.contact_name, COUNT(o.order_id)
FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_type = 'company'
    AND (o.order_date >= '2024-01-01' OR o.order_date IS NULL)
GROUP BY c.customer_id, c.contact_name;
```

**2. Правильне індексування**

```sql
-- Створюємо індекси для найчастіших запитів
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_products_category_price ON products(category_id, unit_price);
CREATE INDEX idx_customers_type_region ON customers(customer_type, region_id);

-- Складені індекси: порядок стовпців важливий!
-- Індекс (A, B, C) працює для: A, (A,B), (A,B,C)
-- Але НЕ працює для: B, C, (B,C)
```

**3. Оптимізація підзапитів**

```sql
-- EXISTS ефективніше за IN для великих наборів
-- Краще:
SELECT customer_id, contact_name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= '2024-01-01'
);

-- Ніж:
SELECT customer_id, contact_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM orders
    WHERE order_date >= '2024-01-01'
);
```

**4. Аналіз планів виконання**

```sql
-- Використовуйте EXPLAIN для аналізу
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.product_name, c.category_name, p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.unit_price > 1000;

-- Шукайте в плані:
-- • Seq Scan (повне сканування) - зазвичай погано
-- • Index Scan (використання індексу) - зазвичай добре
-- • Nested Loop vs Hash Join - залежить від розміру даних
-- • Високий actual time - потребує оптимізації
```

#### Поширені помилки та як їх уникати

**1. Проблема N+1 запитів**

```sql
-- Погано: один запит для списку + N запитів для деталей
-- (зазвичай в програмному коді)
SELECT customer_id, contact_name FROM customers LIMIT 10;
-- Потім для кожного клієнта:
SELECT COUNT(*) FROM orders WHERE customer_id = ?;

-- Добре: один запит з JOIN
SELECT c.customer_id, c.contact_name, COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.contact_name
LIMIT 10;
```

**2. Неправильне використання DISTINCT**

```sql
-- Погано: DISTINCT маскує проблему дублікатів
SELECT DISTINCT c.contact_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id;

-- Добре: з'ясувати причину дублікатів
SELECT c.contact_name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

**3. Неефективні функції в WHERE**

```sql
-- Погано: функція в WHERE унеможливлює використання індексу
SELECT * FROM orders
WHERE YEAR(order_date) = 2024;

-- Добре: діапазон дат дозволяє використовувати індекс
SELECT * FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';
```

### Особливості роботи з NULL значеннями

NULL в SQL - це не "пусте значення", а "невідоме значення", що має особливу логіку.

**Трьохзначна логіка SQL:**

- TRUE AND NULL = NULL
- FALSE AND NULL = FALSE
- TRUE OR NULL = TRUE
- FALSE OR NULL = NULL

```sql
-- Обережно з порівняннями NULL!
SELECT product_name
FROM products
WHERE category_id = NULL;    -- НЕПРАВИЛЬНО! Завжди 0 результатів

SELECT product_name
FROM products
WHERE category_id IS NULL;  -- ПРАВИЛЬНО

-- NULL в обчисленнях
SELECT product_name,
       unit_price * units_in_stock as total_value  -- NULL якщо будь-що NULL
FROM products;

-- Безпечні обчислення з COALESCE
SELECT product_name,
       COALESCE(unit_price, 0) * COALESCE(units_in_stock, 0) as total_value
FROM products;
```

**NULL у з'єднаннях:**

```sql
-- NULL не з'єднуються навіть з NULL!
SELECT p.product_name, c.category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;
-- Товари з category_id = NULL не знайдуть відповідності
```

### Модульність та повторне використання запитів

**Використання CTE для модульності:**

```sql
-- Розбиваємо складний запит на логічні частини
WITH monthly_sales AS (
    -- Крок 1: Агрегуємо продажі по місяцях
    SELECT
        DATE_TRUNC('month', o.order_date) as month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) as revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
),
sales_with_growth AS (
    -- Крок 2: Додаємо розрахунок зростання
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) as prev_month_revenue,
           revenue - LAG(revenue) OVER (ORDER BY month) as growth_amount,
           ROUND(
               (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 /
               LAG(revenue) OVER (ORDER BY month), 2
           ) as growth_percent
    FROM monthly_sales
)
-- Крок 3: Фінальна вибірка з фільтрацією
SELECT month, revenue, growth_amount, growth_percent
FROM sales_with_growth
WHERE growth_percent IS NOT NULL
ORDER BY month;
```

### Динамічні та параметризовані запити

**Шаблони для гнучких запитів:**

```sql
-- Умовна фільтрація без динамічного SQL
SELECT product_name, unit_price, category_id
FROM products
WHERE (unit_price >= $1 OR $1 IS NULL)        -- Параметр мінімальної ціни
  AND (unit_price <= $2 OR $2 IS NULL)        -- Параметр максимальної ціни
  AND (category_id = $3 OR $3 IS NULL)        -- Параметр категорії
  AND ($4 IS NULL OR
       ($4 = 'expensive' AND unit_price > 1000) OR
       ($4 = 'cheap' AND unit_price <= 1000)   -- Параметр типу товару
      );
```

## ▶️ Хід роботи

1. Підключіться до навчальної бази даних, яка була створена в ЛР1.
2. З'єднання таблиць
    Створити наступні запити для навчальної бази даних:
    1. INNER JOIN - отримати список товарів з назвами категорій та постачальників:
    ```sql
    SELECT p.product_name, c.category_name, s.company_name, p.unit_price
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
    ORDER BY c.category_name, p.product_name;
    ```
    2. LEFT JOIN - отримати всіх клієнтів, включаючи тих, хто не має замовлень:
    ```sql
    SELECT c.contact_name, c.customer_type, r.region_name,
          COUNT(o.order_id) as order_count
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN regions r ON c.region_id = r.region_id
    GROUP BY c.customer_id, c.contact_name, c.customer_type, r.region_name
    ORDER BY order_count DESC;
    ```
    3. Множинне з'єднання - детальна інформація про замовлення:
    ```sql
    -- Ваш код тут - створіть запит з 4-5 таблиць
    ```
3. Агрегатні функції
    1. Підрахувати кількість товарів у кожній категорії та середню ціну:
    ```sql
    SELECT c.category_name,
          COUNT(p.product_id) as product_count,
          AVG(p.unit_price) as avg_price,
          MIN(p.unit_price) as min_price,
          MAX(p.unit_price) as max_price
    FROM categories c
    LEFT JOIN products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name
    ORDER BY product_count DESC;
    ```
    2. Визначити загальні продажі за регіонами:
    ```sql
    -- Ваш код тут - використайте SUM, GROUP BY та HAVING
    ```
    3. Знайти постачальників з кількістю товарів більше 2:
    ```sql
    -- Ваш код тут
    ```
4. Базові підзапити
    1. Знайти товари з ціною вищою за середню ціну товарів у своїй категорії:
    ```sql
    SELECT p.product_name, p.unit_price, c.category_name
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    WHERE p.unit_price > (
        SELECT AVG(p2.unit_price)
        FROM products p2
        WHERE p2.category_id = p.category_id
    )
    ORDER BY c.category_name, p.unit_price DESC;
    ```
    2. Отримати клієнтів, які мали замовлення у 2024 році:
    ```sql
    -- Ваш код тут - використайте підзапит з IN
    ```
    3. Додати до списку товарів інформацію про загальну кількість продажів:
    ```sql
    -- Ваш код тут - підзапит у SELECT
    ```
5. Виконання завдань рівня 2
    1. RIGHT JOIN для аналізу категорій товарів та їх наявності:
    ```sql
    SELECT c.category_name,
          COUNT(p.product_id) as products_count,
          COALESCE(AVG(p.unit_price), 0) as avg_price
    FROM products p
    RIGHT JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_id, c.category_name
    ORDER BY products_count DESC;
    ```
    2. Self-join для знаходження співробітників та їх керівників:
    ```sql
    SELECT e1.first_name || ' ' || e1.last_name as employee,
          e1.title as employee_title,
          e2.first_name || ' ' || e2.last_name as manager,
          e2.title as manager_title
    FROM employees e1
    LEFT JOIN employees e2 ON e1.reports_to = e2.employee_id
    ORDER BY e2.last_name, e1.last_name;
    ```
    3. Ранжувати товари за ціною в межах категорії:
    ```sql
    SELECT p.product_name,
          c.category_name,
          p.unit_price,
          RANK() OVER (PARTITION BY c.category_name ORDER BY p.unit_price DESC) as price_rank,
          DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY p.unit_price DESC) as price_dense_rank,
          ROW_NUMBER() OVER (PARTITION BY c.category_name ORDER BY p.unit_price DESC) as row_num
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    ORDER BY c.category_name, p.unit_price DESC;
    ```
    4. Порівняти замовлення кожного клієнта з попереднім за датою:
    ```sql
    -- Ваш код тут - використайте LAG() та LEAD()
    ```
6. Виконання завдань рівня 3
    1. Створити матеріалізоване представлення для аналізу продажів:
    ```sql
    CREATE MATERIALIZED VIEW mv_monthly_sales AS
    SELECT
        EXTRACT(YEAR FROM o.order_date) as year,
        EXTRACT(MONTH FROM o.order_date) as month,
        c.category_name,
        r.region_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) as total_revenue,
        COUNT(DISTINCT o.order_id) as orders_count,
        AVG(oi.quantity * oi.unit_price * (1 - oi.discount)) as avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    JOIN customers cu ON o.customer_id = cu.customer_id
    LEFT JOIN regions r ON cu.region_id = r.region_id
    WHERE o.order_status = 'delivered'
    GROUP BY year, month, c.category_name, r.region_name;

    -- Створення індексу для матеріалізованого представлення
    CREATE INDEX idx_mv_monthly_sales_date ON mv_monthly_sales(year, month);
    ```
    2. Реалізувати рекурсивний запит для ієрархії керівників:
    ```sql
    WITH RECURSIVE employee_hierarchy AS (
        -- Базовий випадок: топ-менеджери (без керівника)
        SELECT employee_id, first_name, last_name, title, reports_to,
              0 as level,
              CAST(last_name || ' ' || first_name as VARCHAR(1000)) as hierarchy_path
        FROM employees
        WHERE reports_to IS NULL

        UNION ALL

        -- Рекурсивний випадок: підлеглі
        SELECT e.employee_id, e.first_name, e.last_name, e.title, e.reports_to,
              eh.level + 1,
              CAST(eh.hierarchy_path || ' -> ' || e.last_name || ' ' || e.first_name as VARCHAR(1000))
        FROM employees e
        JOIN employee_hierarchy eh ON e.reports_to = eh.employee_id
    )
    SELECT * FROM employee_hierarchy
    ORDER BY hierarchy_path;
    ```
7. Аналіз продуктивності
    1. Використати EXPLAIN ANALYZE для аналізу планів виконання ваших запитів
    2. Визначити найповільніші запити та запропонувати способи їх оптимізації
    3. Створити індекси для покращення продуктивності
8. Створити файл `lab02-report.md` за шаблоном ([📑 Завантажити шаблон](assets/lab02-report-template.md)). Додати опис виконаних запитів та результатів. Включити скріншоти. Виконати оцінку складності кожного запиту. Запропонувати способи їх оптимізації.
9. Завантажити звіт зі скріншотами в репозиторій на GitHub.
10. Як відповідь на завдання в LMS Moodle вставити посилання на репозиторій.
11. Захистити лабораторну перед викладачем.

[🔼 Здати лабораторну роботу](https://moodle.vcolnuft.volyn.ua/moodle/course/view.php?id=32#section-2)

## ❓ Контрольні запитання

1. В чому різниця між INNER JOIN та LEFT JOIN? Коли доцільно використовувати кожен з них в контексті навчальної бази даних?
2. Чому не можна використовувати WHERE для фільтрації результатів агрегатних функцій? Яка роль HAVING при аналізі продажів товарів?
3. Як працюють корельовані підзапити і чим вони відрізняються від звичайних? Наведіть приклад для знаходження товарів з ціною вище середньої по категорії.
4. В яких ситуаціях доцільно використовувати віконні функції замість GROUP BY при аналізі замовлень клієнтів?
5. Що таке матеріалізовані представлення і які переваги вони дають для аналітичних запитів по продажах у навчальній базі даних?
6. Як можна оптимізувати запити з множинними з'єднаннями таблиць orders, order_items, products, customers для покращення продуктивності?
7. Яка різниця між RANK() та DENSE_RANK() при ранжуванні товарів за ціною? Наведіть приклад з конкретними даними.
