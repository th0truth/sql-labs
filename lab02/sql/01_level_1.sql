-- ============================================================================
-- Лабораторна робота №2: Створення складних SQL запитів
-- Рівень складності: Рівень 1
-- База даних: ТехноМарт (TechnoMart) — створена в ЛР1
-- ============================================================================

-- ============================================================================
-- 1. З'єднання таблиць (JOIN)
-- ============================================================================

-- Завдання 1.1:
-- INNER JOIN — список товарів з назвами категорій та постачальників.
-- Бізнес-логіка: єдиний каталог товарів із джерелом постачання для відділу закупівель.
SELECT
    c.category_id      AS "CategoryID",
    p.product_id       AS "ProductID",
    s.supplier_id      AS "SupplierID",
    s.company_name     AS "CompanyName",
    s.phone            AS "SupplierPhoneNumber",
    CONCAT('₴', p.unit_price) AS "PriceInUAH",
    c.category_name    AS "CategoryName",
    p.product_name     AS "ProductName",
    p.description      AS "ProductDescription"
FROM categories AS c
INNER JOIN products AS p
    ON p.category_id = c.category_id
INNER JOIN suppliers AS s
    ON s.supplier_id = p.supplier_id
ORDER BY c.category_name, p.product_name;

-- Завдання 1.2:
-- LEFT JOIN — усі клієнти, включно з тими, хто не має замовлень.
-- Бізнес-логіка: оцінка активності клієнтської бази та кількості замовлень на клієнта.
SELECT
    c.customer_id,
    c.company_name,
    c.contact_name,
    r.region_code,
    r.region_name,
    c.city,
    c.email,
    COUNT(o.order_id) AS order_count
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
LEFT JOIN regions AS r
    ON r.region_id = c.region_id
WHERE c.company_name IS NOT NULL
GROUP BY
    c.customer_id, c.company_name, c.contact_name,
    r.region_code, r.region_name, c.city, c.email
ORDER BY order_count DESC;

-- Завдання 1.3:
-- Множинне з'єднання (5 таблиць) — детальна інформація про замовлення.
-- Бізнес-логіка: розгорнута деталізація позицій замовлень (клієнт, товар, категорія)
-- для аналітики продажів та звірки з відвантаженнями.
SELECT
    o.order_id,
    o.order_date,
    cu.contact_name AS customer,
    p.product_name,
    c.category_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN products AS p ON oi.product_id = p.product_id
INNER JOIN categories AS c ON p.category_id = c.category_id
INNER JOIN customers AS cu ON o.customer_id = cu.customer_id
ORDER BY o.order_id, p.product_name;

-- ============================================================================
-- 2. Агрегатні функції (COUNT, SUM, AVG, MIN, MAX) з GROUP BY та HAVING
-- ============================================================================

-- Завдання 3

-- Категорії, у яких понад 5 товарів
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count,
    AVG(p.unit_price)   AS avg_price
FROM categories AS c
INNER JOIN products AS p
    ON p.category_id = c.category_id
GROUP BY c.category_name
HAVING COUNT(p.product_id) > 2
ORDER BY product_count DESC;

-- Клієнти із загальною сумою замовлень понад 10000 ₴
SELECT
    cu.company_name,
    COUNT(DISTINCT o.order_id)       AS order_count,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers AS cu
INNER JOIN orders      AS o
    ON o.customer_id = cu.customer_id
INNER JOIN order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY cu.company_name
HAVING SUM(oi.quantity * oi.unit_price) > 10000
ORDER BY total_spent DESC;
