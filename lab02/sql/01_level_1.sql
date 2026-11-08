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

-- Завдання 2.1:
-- Кількість товарів та цінова статистика за категоріями (COUNT, AVG, MIN, MAX, SUM).
-- Бізнес-логіка: аналіз товарного асортименту, цінового діапазону та складських залишків у розрізі категорій.
SELECT
    c.category_id,
    c.category_name,
    COUNT(p.product_id)                                            AS product_count,
    COALESCE(ROUND(AVG(p.unit_price), 2), 0.00)                    AS avg_price,
    COALESCE(MIN(p.unit_price), 0.00)                              AS min_price,
    COALESCE(MAX(p.unit_price), 0.00)                              AS max_price,
    COALESCE(SUM(p.units_in_stock), 0)                             AS total_units_in_stock,
    COALESCE(ROUND(SUM(p.unit_price * p.units_in_stock), 2), 0.00) AS total_stock_value
FROM categories AS c
LEFT JOIN products AS p
    ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC, c.category_name;

-- Завдання 2.2:
-- Загальні продажі за регіонами (SUM, COUNT, AVG, GROUP BY, HAVING).
-- Бізнес-логіка: географічний аналіз виручки та виділення пріоритетних ринків з обсягом продажів понад 100 000 ₴.
SELECT
    r.region_id,
    r.region_name,
    COUNT(DISTINCT o.order_id)                                     AS total_orders,
    SUM(oi.quantity)                                               AS total_items_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_sales,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS avg_item_revenue
FROM regions AS r
INNER JOIN orders AS o
    ON o.ship_region_id = r.region_id
INNER JOIN order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY r.region_id, r.region_name
HAVING SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) > 100000
ORDER BY total_sales DESC;

-- Завдання 2.3:
-- Постачальники з кількістю товарів більше 2 (COUNT, AVG, MIN, MAX, GROUP BY, HAVING).
-- Бізнес-логіка: виявлення ключових постачальників із диверсифікованим асортиментом понад 2 позиції для оптимізації контрактів.
SELECT
    s.supplier_id,
    s.company_name,
    s.city,
    COUNT(p.product_id)         AS product_count,
    ROUND(AVG(p.unit_price), 2) AS avg_price,
    MIN(p.unit_price)           AS min_price,
    MAX(p.unit_price)           AS max_price
FROM suppliers AS s
INNER JOIN products AS p
    ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.company_name, s.city
HAVING COUNT(p.product_id) > 2
ORDER BY product_count DESC, s.company_name;

-- ============================================================================
-- 3. Базові підзапити
-- ============================================================================

-- Завдання 3.1:
-- Підзапит у розділі WHERE (корельований) — товари дорожчі за середню ціну у своїй категорії.
-- Бізнес-логіка: сегментація флагманських і високомаржинальних моделей для кожної категорії каталогу.
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    ROUND((
        SELECT AVG(p2.unit_price)
        FROM products AS p2
        WHERE p2.category_id = p.category_id
    ), 2) AS category_avg_price
FROM products AS p
INNER JOIN categories AS c
    ON c.category_id = p.category_id
WHERE p.unit_price > (
    SELECT AVG(p2.unit_price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.category_name, p.unit_price DESC;

-- Завдання 3.2:
-- Підзапит з оператором IN у WHERE — клієнти, які розмістили замовлення у 2024 році.
-- Бізнес-логіка: відбір активної клієнтської аудиторії поточного року для таргетингу програми лояльності.
SELECT
    c.customer_id,
    COALESCE(c.company_name, c.contact_name) AS customer_name,
    c.contact_name,
    c.city,
    c.email
FROM customers AS c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders AS o
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
)
ORDER BY c.customer_id;

-- Завдання 3.3:
-- Підзапит з оператором EXISTS у WHERE — клієнти, які замовляли телевізори або смартфони.
-- Бізнес-логіка: перевірка наявності покупок у пріоритетних категоріях для персоналізованих рекомендацій супутніх товарів.
SELECT
    c.customer_id,
    COALESCE(c.company_name, c.contact_name) AS customer_name,
    c.city,
    c.customer_type
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    INNER JOIN order_items AS oi ON oi.order_id = o.order_id
    INNER JOIN products AS p     ON p.product_id = oi.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category_id IN (1, 3) -- Смартфони (1) та Телевізори (3)
)
ORDER BY c.customer_id;

-- Завдання 3.4 (3.3 у шаблоні звіту):
-- Підзапит у розділі SELECT — товари із сумарною кількістю продажів та обсягом виручки.
-- Бізнес-логіка: додавання обчислювальних показників реалізації до каталогу товарів без групування зовнішньої таблиці.
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    COALESCE((
        SELECT SUM(oi.quantity)
        FROM order_items AS oi
        WHERE oi.product_id = p.product_id
    ), 0) AS total_units_sold,
    COALESCE((
        SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)
        FROM order_items AS oi
        WHERE oi.product_id = p.product_id
    ), 0.00) AS total_sales_revenue
FROM products AS p
INNER JOIN categories AS c
    ON c.category_id = p.category_id
ORDER BY total_units_sold DESC, p.product_id;
