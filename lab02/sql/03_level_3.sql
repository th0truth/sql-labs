-- ============================================================================
-- Лабораторна робота №2: Створення складних SQL запитів
-- Рівень складності: Рівень 3
-- База даних: ТехноМарт (TechnoMart)
-- ============================================================================

-- ============================================================================
-- 6. Оптимізація та складна аналітика
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Завдання 6.1:
-- Матеріалізоване представлення (Materialized View) для аналізу щомісячних продажів
-- Бізнес-логіка: кешування результатів "важкого" аналітичного запиту з множинними
-- JOIN та агрегацією для швидкого формування дашбордів вищого керівництва.
-- ----------------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS mv_monthly_sales CASCADE;

CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT
    EXTRACT(YEAR FROM o.order_date)::INTEGER                         AS sales_year,
    EXTRACT(MONTH FROM o.order_date)::INTEGER                        AS sales_month,
    c.category_name,
    COALESCE(r.region_name, 'Невизначений регіон')                   AS region_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)   AS total_revenue,
    COUNT(DISTINCT o.order_id)::INTEGER                              AS orders_count,
    SUM(oi.quantity)::INTEGER                                        AS items_sold,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)   AS avg_order_item_value
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN products AS p     ON oi.product_id = p.product_id
INNER JOIN categories AS c   ON p.category_id = c.category_id
INNER JOIN customers AS cu   ON o.customer_id = cu.customer_id
LEFT JOIN regions AS r       ON cu.region_id = r.region_id
WHERE o.order_status = 'delivered'
GROUP BY sales_year, sales_month, c.category_name, r.region_name;

-- Створення унікального індексу (необхідний для оновлення CONCURRENTLY без блокування читання)
CREATE UNIQUE INDEX idx_mv_monthly_sales_pk
    ON mv_monthly_sales(sales_year, sales_month, category_name, region_name);

-- Додатковий композитний індекс для прискорення вибірок за періодами
CREATE INDEX idx_mv_monthly_sales_period
    ON mv_monthly_sales(sales_year, sales_month);

-- Демонстрація швидкої аналітичної вибірки з матеріалізованого представлення
SELECT
    sales_year,
    sales_month,
    category_name,
    region_name,
    total_revenue,
    orders_count,
    items_sold,
    avg_order_item_value
FROM mv_monthly_sales
ORDER BY sales_year DESC, sales_month DESC, total_revenue DESC
LIMIT 10;

-- Оновлення матеріалізованого представлення без блокування паралельних SELECT
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_sales;


-- ----------------------------------------------------------------------------
-- Завдання 6.2:
-- Рекурсивний CTE (Common Table Expression) для побудови ієрархії керівництва
-- Бізнес-логіка: візуалізація організаційної структури підприємства від генерального
-- директора до лінійних співробітників із глибиною вкладеності та шляхом підпорядкування.
-- ----------------------------------------------------------------------------

WITH RECURSIVE employee_hierarchy AS (
    -- 1. Anchor query (базовий випадок): топ-менеджмент (без керівника)
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.title,
        e.reports_to,
        0 AS depth_level,
        CAST(e.last_name || ' ' || e.first_name AS VARCHAR(1000)) AS hierarchy_path,
        CAST(e.first_name || ' ' || e.last_name AS VARCHAR(1000)) AS root_executive
    FROM employees AS e
    WHERE e.reports_to IS NULL

    UNION ALL

    -- 2. Recursive query (рекурсивна частина): підлеглі наступних ланок
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.title,
        e.reports_to,
        eh.depth_level + 1 AS depth_level,
        CAST(eh.hierarchy_path || ' -> ' || e.last_name || ' ' || e.first_name AS VARCHAR(1000)) AS hierarchy_path,
        eh.root_executive
    FROM employees AS e
    INNER JOIN employee_hierarchy AS eh
        ON e.reports_to = eh.employee_id
    WHERE eh.depth_level < 10 -- Запобіжник від нескінченної рекурсії (циклічних посилань)
)
SELECT
    employee_id,
    LPAD('', depth_level * 4, ' ') || first_name || ' ' || last_name AS indented_employee_name,
    title,
    depth_level,
    hierarchy_path,
    root_executive
FROM employee_hierarchy
ORDER BY hierarchy_path;


-- ----------------------------------------------------------------------------
-- Завдання 6.3:
-- Динамічний SQL у збереженій функції для параметризованої аналітики
-- Бізнес-логіка: універсальний аналітичний двигун звітності, що конструює оптимізований
-- SQL-запит залежно від вхідних параметрів фільтрації (рік, категорія, поріг виручки).
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_parameterized_sales_analytics(
    p_year INT DEFAULT NULL,
    p_category_id INT DEFAULT NULL,
    p_min_revenue NUMERIC DEFAULT NULL,
    p_sort_by VARCHAR DEFAULT 'revenue'
)
RETURNS TABLE (
    category_name VARCHAR,
    product_name VARCHAR,
    total_quantity BIGINT,
    total_revenue NUMERIC,
    orders_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- Базова структура аналітичного запиту
    v_sql := '
        SELECT
            c.category_name,
            p.product_name,
            SUM(oi.quantity)::BIGINT AS total_quantity,
            ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue,
            COUNT(DISTINCT o.order_id)::BIGINT AS orders_count
        FROM orders AS o
        INNER JOIN order_items AS oi ON o.order_id = oi.order_id
        INNER JOIN products AS p     ON oi.product_id = p.product_id
        INNER JOIN categories AS c   ON p.category_id = c.category_id
        WHERE 1=1';

    -- Динамічне додавання фільтра за роком (безпечна інтерполяція через %L)
    IF p_year IS NOT NULL THEN
        v_sql := v_sql || format(' AND EXTRACT(YEAR FROM o.order_date) = %L', p_year);
    END IF;

    -- Динамічне додавання фільтра за категорією
    IF p_category_id IS NOT NULL THEN
        v_sql := v_sql || format(' AND p.category_id = %L', p_category_id);
    END IF;

    -- Групування результатів
    v_sql := v_sql || ' GROUP BY c.category_name, p.product_name';

    -- Динамічне додавання фільтра HAVING за мінімальним порогом виручки
    IF p_min_revenue IS NOT NULL THEN
        v_sql := v_sql || format(' HAVING SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) >= %L', p_min_revenue);
    END IF;

    -- Динамічне сортування
    IF p_sort_by = 'quantity' THEN
        v_sql := v_sql || ' ORDER BY total_quantity DESC, product_name';
    ELSE
        v_sql := v_sql || ' ORDER BY total_revenue DESC, product_name';
    END IF;

    -- Виконання динамічно згенерованого SQL
    RETURN QUERY EXECUTE v_sql;
END;
$$;

-- Демонстрація 1: Аналітика всіх товарів з виручкою понад 100 000 ₴ за 2024 рік
SELECT *
FROM get_parameterized_sales_analytics(2024, NULL, 100000.00, 'revenue');

-- Демонстрація 2: Аналітика виключно ноутбуків (category_id = 2) за обсягом продажів
SELECT *
FROM get_parameterized_sales_analytics(2024, 2, NULL, 'quantity');


-- ============================================================================
-- 7. Аналіз продуктивності та оптимізація запитів
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Завдання 7.1:
-- Аналіз плану виконання запиту (EXPLAIN ANALYZE) до оптимізації
-- ----------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.order_date,
    cu.contact_name,
    p.product_name,
    c.category_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN products AS p     ON oi.product_id = p.product_id
INNER JOIN categories AS c   ON p.category_id = c.category_id
INNER JOIN customers AS cu   ON o.customer_id = cu.customer_id
WHERE o.order_date >= '2024-03-01'
  AND p.unit_price > 20000;

-- ----------------------------------------------------------------------------
-- Завдання 7.2:
-- Створення оптимізуючих індексів (B-Tree для зовнішніх ключів та фільтрів)
-- ----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_orders_customer_date
    ON orders(customer_id, order_date);

CREATE INDEX IF NOT EXISTS idx_order_items_product_order
    ON order_items(product_id, order_id);

CREATE INDEX IF NOT EXISTS idx_products_category_price
    ON products(category_id, unit_price);

-- ----------------------------------------------------------------------------
-- Завдання 7.3:
-- Аналіз плану виконання запиту після створення індексів
-- ----------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.order_date,
    cu.contact_name,
    p.product_name,
    c.category_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN products AS p     ON oi.product_id = p.product_id
INNER JOIN categories AS c   ON p.category_id = c.category_id
INNER JOIN customers AS cu   ON o.customer_id = cu.customer_id
WHERE o.order_date >= '2024-03-01'
  AND p.unit_price > 20000;
