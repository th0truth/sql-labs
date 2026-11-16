-- ============================================================================
-- Лабораторна робота №5: Скрипт 05: Аналіз виконання запитів ПІСЛЯ індексації
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- ----------------------------------------------------------------------------
-- Запит 1 (Після індексації):
-- Очікується: Використання часткового індексу idx_orders_pending_partial або idx_orders_date_status
-- Замість Seq Scan (482 буфери) -> Index Scan / Bitmap Index Scan
-- ----------------------------------------------------------------------------
\echo '=== ЗАПИТ 1 (ПІСЛЯ ІНДЕКСАЦІЇ) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    order_date,
    status,
    total_amount
FROM lab05.orders
WHERE order_date >= NOW() - INTERVAL '30 days'
  AND status = 'Pending'
ORDER BY order_date DESC;

-- ----------------------------------------------------------------------------
-- Запит 2 (Після індексації):
-- Очікується: Використання часткового індексу idx_orders_high_value_partial
-- та індексу idx_customers_city замість подвійного Seq Scan
-- ----------------------------------------------------------------------------
\echo '=== ЗАПИТ 2 (ПІСЛЯ ІНДЕКСАЦІЇ) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    ROUND(AVG(o.total_amount), 2) AS avg_order_amount
FROM lab05.customers c
JOIN lab05.orders o ON c.customer_id = o.customer_id
WHERE c.city = 'Київ'
  AND o.total_amount > 2500.00
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- Запит 3 (Після індексації):
-- Очікується: Використання індексів idx_order_items_order_book, idx_books_price
-- ----------------------------------------------------------------------------
\echo '=== ЗАПИТ 3 (ПІСЛЯ ІНДЕКСАЦІЇ) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    g.name AS genre_name,
    b.book_id,
    b.title,
    b.price,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.subtotal) AS gross_revenue
FROM lab05.genres g
JOIN lab05.books b ON g.genre_id = b.genre_id
JOIN lab05.order_items oi ON b.book_id = oi.book_id
JOIN lab05.orders o ON oi.order_id = o.order_id
WHERE b.price BETWEEN 500.00 AND 1200.00
  AND o.order_date >= NOW() - INTERVAL '180 days'
GROUP BY g.name, b.book_id, b.title, b.price
HAVING SUM(oi.quantity) > 10
ORDER BY gross_revenue DESC
LIMIT 25;

-- ----------------------------------------------------------------------------
-- Додатковий тест: Специфічний запит для демонстрації часткового індексу (Рівень 2)
-- ----------------------------------------------------------------------------
\echo '=== ДЕМОНСТРАЦІЯ ЧАСТКОВОГО ІНДЕКСУ (PARTIAL INDEX SCAN) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date, total_amount
FROM lab05.orders
WHERE status = 'Pending'
  AND order_date >= NOW() - INTERVAL '7 days'
ORDER BY order_date DESC;
