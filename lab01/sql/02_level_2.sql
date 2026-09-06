-- ============================================================================
-- Лабораторна робота №1: Робота з СУБД PostgreSQL та основи SQL
-- Рівень складності: Рівень 2
-- База даних: ТехноМарт (TechnoMart)
-- ============================================================================

-- ============================================================================
-- 1. Пошук за зразком з LIKE
-- ============================================================================

-- Завдання 1.1: Знайти всіх клієнтів, чиї імена починаються на "Іван".
SELECT 
    c.customer_id,
    c.contact_name,
    c.city,
    c.phone
FROM customers AS c
WHERE c.contact_name LIKE 'Іван%';

-- Завдання 1.2: Вивести товари, в назві яких є слово "phone" або "телефон".
SELECT 
    p.product_id,
    p.product_name,
    p.unit_price
FROM products AS p
WHERE p.product_name ILIKE '%телефон%'
   OR p.product_name ILIKE '%phone%'; 

-- Завдання 1.3 (Самостійно): Пошук замовлень за службами доставки, що містять слово "пошта".
SELECT
    o.order_id,
    o.ship_name,
    o.ship_via,
    o.ship_address 
FROM orders AS o
WHERE o.ship_via ILIKE '%пошта%';

-- Завдання 1.4 (Самостійно): Пошук співробітників за фрагментом прізвища в електронній пошті.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name, ' ', e.middle_name) AS fullname,
    e.title AS position,
    e.email
FROM employees AS e
WHERE e.email LIKE '%nko%';

-- Завдання 1.5 (Самостійно): Пошук товарів із фіксованим об'ємом накопичувача 256 ГБ.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.product_name LIKE '%256%';


-- ============================================================================
-- 2. Логічні оператори AND, OR, NOT
-- ============================================================================

-- Завдання 2.1: Знайти товари дорожчі за 15000 грн і дешевші за 50000 грн.
SELECT 
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price
FROM products AS p
WHERE p.unit_price > 15000
  AND p.unit_price < 50000;

-- Завдання 2.2: Вивести клієнтів з Києва або Львова, які є юридичними особами.
SELECT
    c.customer_id,
    c.company_name,
    c.contact_name,
    c.contact_title,
    c.city,
    c.email,
    c.customer_type
FROM customers AS c
WHERE (c.city = 'Київ' OR c.city = 'Львів')
  AND c.company_name IS NOT NULL
  AND c.customer_type = 'company';

-- Завдання 2.3 (Самостійно): Товари об'ємом 128 ГБ у діапазоні цін 13 000 - 25 000 грн.
SELECT
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price,
    p.units_on_order
FROM products AS p
WHERE p.product_name LIKE '%128%'
  AND p.unit_price > 13000
  AND p.unit_price < 25000;

-- Завдання 2.4 (Самостійно): Постачальники форми власності ТОВ з ненульовим виторгом товарів.
SELECT
    pss.product_id,
    pss.product_name,
    pss.category_name,
    pss.supplier_name,
    pss.unit_price,
    pss.total_revenue,
    pss.order_count
FROM product_sales_summary AS pss
WHERE pss.supplier_name LIKE '%ТОВ%'
  AND pss.total_revenue != 0;

-- Завдання 2.5 (Самостійно): Місяці з високою інтенсивністю продажів (більше 10 реалізованих одиниць).
SELECT 
    msr.year_month,
    msr.orders_count,
    msr.unique_customers,
    msr.total_items,
    msr.total_revenue
FROM monthly_sales_report AS msr
WHERE msr.total_items > 10
ORDER BY msr.total_items DESC;

-- Завдання 2.6 (Самостійно): Оцінка продуктивності київських працівників.
SELECT 
    ep.employee_id,
    ep.full_name,
    ep.title AS job_position,
    ep.city
FROM employee_performance AS ep
WHERE ep.city = 'Київ';


-- ============================================================================
-- 3. Оператори IN, BETWEEN, IS NULL
-- ============================================================================

-- Завдання 3.1: Вивести клієнтів з міст Київ, Харків, Одеса, Дніпро.
SELECT
    c.customer_id,
    c.contact_name,
    c.company_name,
    c.city,
    c.phone,
    c.customer_type
FROM customers AS c
WHERE c.city IN ('Київ', 'Харків', 'Одеса', 'Дніпро');

-- Завдання 3.2: Знайти товари в ціновому діапазоні від 10000 до 30000 грн.
SELECT
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price
FROM products AS p
WHERE p.unit_price BETWEEN 10000 AND 30000; 

-- Завдання 3.3 (Самостійно, IN): Замовлення, що очікують або проходять комплектацію на складі.
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.ship_city,
    o.ship_via
FROM orders AS o
WHERE o.order_status IN ('pending', 'processing')
ORDER BY o.order_date;

-- Завдання 3.4 (Самостійно, NOT IN): Товари, що не належать до категорій смартфонів та комп'ютерів.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.category_id NOT IN (1, 2)
ORDER BY p.category_id, p.unit_price DESC;

-- Завдання 3.5 (Самостійно, BETWEEN): Замовлення за другий квартал 2024 року.
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
WHERE o.order_date BETWEEN '2024-04-01' AND '2024-06-30'
ORDER BY o.order_date;

-- Завдання 3.6 (Самостійно, BETWEEN): Співробітники із заробітною платою середньої ланки.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    e.salary
FROM employees AS e
WHERE e.salary BETWEEN 25000 AND 35000
ORDER BY e.salary DESC;

-- Завдання 3.7 (Самостійно, IS NULL): Замовлення, які ще не були відправлені покупцям.
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.required_date,
    o.order_status,
    o.ship_city
FROM orders AS o
WHERE o.shipped_date IS NULL
ORDER BY o.order_date;

-- Завдання 3.8 (Самостійно, IS NOT NULL): Клієнти із зазначеною посадою представника компанії.
SELECT
    c.customer_id,
    c.contact_name,
    c.contact_title AS job_position,
    CONCAT('м. ', c.city, ', ', c.address) AS full_address
FROM customers AS c
WHERE c.contact_title IS NOT NULL
ORDER BY c.city, c.contact_name;


-- ============================================================================
-- 4. Комбінування умов
-- ============================================================================

-- Завдання 4.1 (Самостійно, LIKE + AND/OR + BOOLEAN): Активні товари топових брендів у наявності.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE (p.product_name ILIKE '%Apple%' OR p.product_name ILIKE '%Samsung%')
  AND p.units_in_stock > 0
  AND p.discontinued = false
ORDER BY p.unit_price DESC;

-- Завдання 4.2 (Самостійно, BETWEEN + IN): Товари середнього цінового сегмента пріоритетних категорій.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.unit_price BETWEEN 15000 AND 35000
  AND p.category_id IN (1, 2, 3)
ORDER BY p.category_id ASC, p.unit_price DESC;

-- Завдання 4.3 (Самостійно, IS NULL + LIKE + OR): Фізичні особи з поштовими скриньками популярних доменів.
SELECT
    c.customer_id,
    c.contact_name,
    c.city,
    c.email
FROM customers AS c
WHERE c.company_name IS NULL
  AND (c.email LIKE '%@gmail.com' OR c.email LIKE '%@ukr.net')
ORDER BY c.city, c.contact_name;

-- Завдання 4.4 (Самостійно, NOT BETWEEN + IN): Замовлення у великі міста з граничною вартістю доставки.
SELECT
    o.order_id,
    o.ship_city,
    o.ship_via,
    o.freight,
    o.order_status
FROM orders AS o
WHERE o.ship_city IN ('Київ', 'Дніпро', 'Львів')
  AND o.freight NOT BETWEEN 100 AND 300
ORDER BY o.freight DESC;

-- Завдання 4.5 (Самостійно, LIKE + IS NOT NULL + AND): Керівний та фінансовий персонал із високим окладом.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    e.salary,
    e.email
FROM employees AS e
WHERE (e.title ILIKE '%директор%' OR e.title ILIKE '%бухгалтер%')
  AND e.salary > 30000
  AND e.email IS NOT NULL
ORDER BY e.salary DESC;


-- ============================================================================
-- 5. Складне сортування та пагінація
-- ============================================================================

-- Завдання 5.1 (Самостійно, Сортування за 2 полями): Каталог товарів за категорією та ціною.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
ORDER BY p.category_id,
    p.unit_price DESC;

-- Завдання 5.2 (Самостійно, Сортування за 3 полями): Реєстр клієнтів за містом, типом та контактною особою.
SELECT
    c.customer_id,
    c.city,
    c.customer_type,
    c.company_name,
    c.contact_name,
    c.phone
FROM customers AS c
ORDER BY c.city, 
    c.customer_type DESC,
    c.contact_name;

-- Завдання 5.3 (Самостійно, Сортування за 2 полями): Моніторинг замовлень за статусом виконання та датою.
SELECT
    o.order_id,
    o.order_status,
    o.order_date,
    o.customer_id,
    o.ship_city,
    o.freight
FROM orders AS o
ORDER BY o.order_status,
    o.order_date DESC,
    o.order_id DESC;

-- Завдання 5.4 (Самостійно, Пагінація через LIMIT та OFFSET): Друга сторінка каталогу товарів.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
ORDER BY p.unit_price DESC,
    p.product_id
LIMIT 5 OFFSET 5;

-- Завдання 5.5 (Самостійно, Пагінація через LIMIT та OFFSET): Третя сторінка журналу замовлень.
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
ORDER BY o.order_date DESC,
    o.order_id DESC
LIMIT 10 OFFSET 20;
