-- ============================================================================
-- Лабораторна робота №5: Скрипт 06: Представлення, правила (RULES) та Materialized Views
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- ----------------------------------------------------------------------------
-- Рівень 1: Створення двох звичайних представлень (VIEW)
-- ----------------------------------------------------------------------------

-- 1. Представлення активності покупців (з агрегацією та JOIN)
CREATE OR REPLACE VIEW lab05.v_customer_activity AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    c.status,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM lab05.customers c
LEFT JOIN lab05.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email, c.city, c.status;

-- 2. Представлення фінансової аналітики по жанрах
CREATE OR REPLACE VIEW lab05.v_genre_sales_analytics AS
SELECT
    g.genre_id,
    g.name AS genre_name,
    COUNT(DISTINCT b.book_id) AS total_titles,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.subtotal), 0.00) AS total_revenue,
    ROUND(COALESCE(AVG(b.price), 0.00), 2) AS avg_book_price
FROM lab05.genres g
LEFT JOIN lab05.books b ON g.genre_id = b.genre_id
LEFT JOIN lab05.order_items oi ON b.book_id = oi.book_id
GROUP BY g.genre_id, g.name;


-- ----------------------------------------------------------------------------
-- Рівень 2: Представлення з можливістю оновлення через правила (RULES)
-- ----------------------------------------------------------------------------

-- Представлення контактних даних активних клієнтів
CREATE OR REPLACE VIEW lab05.v_customer_contacts AS
SELECT
    customer_id,
    full_name,
    email,
    phone,
    city,
    status
FROM lab05.customers
WHERE status <> 'blocked';

-- Правило: при спробі UPDATE представлення оновлюються дозволені поля базової таблиці
CREATE OR REPLACE RULE r_customer_contacts_update AS
ON UPDATE TO lab05.v_customer_contacts
DO INSTEAD
    UPDATE lab05.customers
    SET email = NEW.email,
        phone = NEW.phone,
        city = NEW.city
    WHERE customer_id = OLD.customer_id;


-- ----------------------------------------------------------------------------
-- Рівень 3: Матеріалізоване представлення (MATERIALIZED VIEW)
-- ----------------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS lab05.mv_daily_sales_summary CASCADE;

CREATE MATERIALIZED VIEW lab05.mv_daily_sales_summary AS
SELECT
    DATE(order_date) AS sale_date,
    status,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS daily_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM lab05.orders
GROUP BY DATE(order_date), status;

-- Унікальний індекс обов'язковий для виконання REFRESH MATERIALIZED VIEW CONCURRENTLY
CREATE UNIQUE INDEX idx_mv_daily_sales_date_status
ON lab05.mv_daily_sales_summary(sale_date, status);

-- Первинне оновлення
REFRESH MATERIALIZED VIEW lab05.mv_daily_sales_summary;

-- Тестові вибірки
SELECT * FROM lab05.v_customer_activity ORDER BY total_spent DESC LIMIT 5;
SELECT * FROM lab05.v_genre_sales_analytics ORDER BY total_revenue DESC LIMIT 5;
SELECT * FROM lab05.mv_daily_sales_summary ORDER BY sale_date DESC LIMIT 5;
