-- ============================================================================
-- Лабораторна робота №5: Скрипт 03: Аналіз виконання запитів ДО індексації
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- ----------------------------------------------------------------------------
-- Запит 1: Фільтрація та сортування замовлень за періодом і статусом
-- Очікується: Sequential Scan на таблиці orders (60 000 рядків)
-- ----------------------------------------------------------------------------
\echo '=== ЗАПИТ 1 (ДО ІНДЕКСАЦІЇ) ==='
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
-- Запит 2: Аналіз активних клієнтів м. Київ із замовленнями високої вартості
-- Очікується: Seq Scan на customers + Seq Scan / Hash Join на orders
-- ----------------------------------------------------------------------------
\echo '=== ЗАПИТ 2 (ДО ІНДЕКСАЦІЇ) ==='
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
-- Запит 3: Об'єднання 4 таблиць з агрегацією виручки та фільтрацією за ціною/датою
-- Очікується: Багаторазові Seq Scan на books, order_items (120k) та orders (60k)
-- ----------------------------------------------------------------------------
\echo '=== ЗАПИТ 3 (ДО ІНДЕКСАЦІЇ) ==='
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
