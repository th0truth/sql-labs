-- ============================================================================
-- Лабораторна робота №5: Керування БД, оптимізація продуктивності та автоматизація
-- Скрипт 01: Створення схеми та базових таблиць
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS lab05;
SET search_path TO lab05, public;

-- 1. Таблиця жанрів літератури
DROP TABLE IF EXISTS lab05.order_items CASCADE;
DROP TABLE IF EXISTS lab05.orders CASCADE;
DROP TABLE IF EXISTS lab05.books CASCADE;
DROP TABLE IF EXISTS lab05.customers CASCADE;
DROP TABLE IF EXISTS lab05.authors CASCADE;
DROP TABLE IF EXISTS lab05.genres CASCADE;
DROP TABLE IF EXISTS lab05.audit_log CASCADE;
DROP TABLE IF EXISTS lab05.maintenance_log CASCADE;

CREATE TABLE lab05.genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- 2. Таблиця авторів
CREATE TABLE lab05.authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'Україна',
    birth_year INTEGER
);

-- 3. Таблиця книг (каталог видань)
CREATE TABLE lab05.books (
    book_id SERIAL PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    author_id INTEGER NOT NULL REFERENCES lab05.authors(author_id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES lab05.genres(genre_id) ON DELETE RESTRICT,
    publication_year INTEGER,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

-- 4. Таблиця клієнтів книгарні
CREATE TABLE lab05.customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(30),
    city VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Таблиця замовлень
CREATE TABLE lab05.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES lab05.customers(customer_id) ON DELETE CASCADE,
    order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processing', 'Completed', 'Cancelled')),
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0)
);

-- 6. Позиції замовлень
CREATE TABLE lab05.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES lab05.orders(order_id) ON DELETE CASCADE,
    book_id INTEGER NOT NULL REFERENCES lab05.books(book_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal NUMERIC(10, 2) NOT NULL CHECK (subtotal >= 0)
);

-- 7. Таблиця аудиту операцій (для Рівнів 1 та 2)
CREATE TABLE lab05.audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Таблиця журналу регламентного обслуговування (для Рівня 3)
CREATE TABLE lab05.maintenance_log (
    log_id SERIAL PRIMARY KEY,
    operation TEXT NOT NULL,
    executed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'SUCCESS'
);
