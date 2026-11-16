-- ============================================================================
-- Лабораторна робота №4: Розробка реляційної бази даних з простою інтеграцією
-- Скрипт: 05_create_views.sql
-- Представлення (Рівень 2: мінімум 2 представлення)
-- ============================================================================

SET search_path TO bookstore, public;

-- ----------------------------------------------------------------------------
-- Представлення 1: Денормалізований каталог книг для вебінтерфейсу
-- Призначення: об'єднує книги з авторами та жанрами в єдине оптимізоване подання,
-- готове для швидкого виведення на сторінках вебзастосунку та експорту в звіти.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_book_catalog AS
SELECT
    b.book_id,
    b.isbn,
    b.title,
    a.author_id,
    (a.first_name || ' ' || a.last_name) AS author_name,
    a.country AS author_country,
    g.genre_id,
    g.name AS genre_name,
    b.publication_year,
    b.pages,
    b.price,
    b.stock_quantity,
    CASE
        WHEN b.stock_quantity > 10 THEN 'В наявності'
        WHEN b.stock_quantity > 0  THEN 'Закінчується'
        ELSE 'Немає на складі'
    END AS stock_status,
    b.created_at,
    b.updated_at
FROM books b
JOIN authors a ON a.author_id = b.author_id
JOIN genres g  ON g.genre_id = b.genre_id;

-- ----------------------------------------------------------------------------
-- Представлення 2: Аналітичний звіт клієнтської активності
-- Призначення: агрегує фінансові показники кожного покупця: кількість замовлень,
-- сумарний обсяг покупок, дату останнього замовлення та статус лояльності.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_customer_order_summary AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    c.discount_percent,
    COUNT(o.order_id) AS total_orders,
    COUNT(CASE WHEN o.status = 'Completed' THEN 1 END) AS completed_orders,
    COUNT(CASE WHEN o.status = 'Pending' THEN 1 END) AS pending_orders,
    COALESCE(SUM(CASE WHEN o.status = 'Completed' THEN o.total_amount ELSE 0.00 END), 0.00) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.email, c.city, c.discount_percent;

-- ----------------------------------------------------------------------------
-- Представлення 3: Топ найпопулярніших книг за виторгом та продажами
-- Призначення: використовується панелями моніторингу та керівництвом для аналізу попиту.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_top_selling_books AS
SELECT
    b.book_id,
    b.title,
    (a.first_name || ' ' || a.last_name) AS author_name,
    g.name AS genre_name,
    b.price,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.subtotal), 0.00) AS total_revenue
FROM books b
JOIN authors a ON a.author_id = b.author_id
JOIN genres g ON g.genre_id = b.genre_id
LEFT JOIN order_items oi ON oi.book_id = b.book_id
LEFT JOIN orders o ON o.order_id = oi.order_id AND o.status = 'Completed'
GROUP BY b.book_id, b.title, a.first_name, a.last_name, g.name, b.price
ORDER BY total_revenue DESC, units_sold DESC;
