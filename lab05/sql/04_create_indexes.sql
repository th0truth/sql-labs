-- ============================================================================
-- Лабораторна робота №5: Скрипт 04: Створення оптимізаційних та часткових індексів
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- ----------------------------------------------------------------------------
-- Рівень 1: Три стандартні B-Tree індекси для оптимізації повільних запитів
-- ----------------------------------------------------------------------------

-- 1. Складений індекс для фільтрації замовлень за датою та сортування
DROP INDEX IF EXISTS lab05.idx_orders_date_status;
CREATE INDEX idx_orders_date_status ON lab05.orders(order_date DESC, status);

-- 2. Індекс зовнішнього ключа customer_id у таблиці orders (прискорює JOIN з customers)
DROP INDEX IF EXISTS lab05.idx_orders_customer_id;
CREATE INDEX idx_orders_customer_id ON lab05.orders(customer_id);

-- 3. Індекс на зовнішні ключі позицій замовлень (прискорює JOIN order_items з orders та books)
DROP INDEX IF EXISTS lab05.idx_order_items_order_book;
CREATE INDEX idx_order_items_order_book ON lab05.order_items(order_id, book_id);

-- 4. Додатковий індекс на діапазон цін книг (фільтрація за ціною)
DROP INDEX IF EXISTS lab05.idx_books_price;
CREATE INDEX idx_books_price ON lab05.books(price);

-- 5. Індекс на місто клієнта
DROP INDEX IF EXISTS lab05.idx_customers_city;
CREATE INDEX idx_customers_city ON lab05.customers(city);


-- ----------------------------------------------------------------------------
-- Рівень 2: Часткові індекси (Partial Indexes) з умовою WHERE
-- ----------------------------------------------------------------------------

-- Частковий індекс 1: Тільки для активних/очікуючих замовлень зі статусом 'Pending'
-- Розмір індексу набагато менший за повний індекс по таблиці
DROP INDEX IF EXISTS lab05.idx_orders_pending_partial;
CREATE INDEX idx_orders_pending_partial ON lab05.orders(order_date DESC)
WHERE status = 'Pending';

-- Частковий індекс 2: Тільки для замовлень великої вартості (VIP чеки > 2500 грн)
DROP INDEX IF EXISTS lab05.idx_orders_high_value_partial;
CREATE INDEX idx_orders_high_value_partial ON lab05.orders(customer_id, total_amount)
WHERE total_amount > 2500.00;

-- Частковий індекс 3: Тільки для активних клієнтів
DROP INDEX IF EXISTS lab05.idx_customers_active_partial;
CREATE INDEX idx_customers_active_partial ON lab05.customers(city, customer_id)
WHERE status = 'active';

-- Оновлюємо статистику після створення індексів
ANALYZE lab05.orders;
ANALYZE lab05.order_items;
ANALYZE lab05.books;
ANALYZE lab05.customers;

-- Перевірка створених індексів у схемі lab05 та їх розмірів
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(indexname))) AS index_size
FROM pg_indexes
WHERE schemaname = 'lab05'
ORDER BY tablename, indexname;
