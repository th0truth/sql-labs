-- ============================================================================
-- Лабораторна робота №4: Розробка реляційної бази даних з простою інтеграцією
-- Скрипт: 01_create_tables.sql
-- Предметна область: Система управління книжковим магазином (Bookstore)
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS bookstore;
SET search_path TO bookstore, public;

-- Видалення попередніх версій таблиць з урахуванням зовнішніх ключів
DROP TABLE IF EXISTS book_price_audit CASCADE;
DROP TABLE IF EXISTS activity_log CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Таблиця жанрів / категорій книг
CREATE TABLE genres (
    genre_id    SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблиця авторів
CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    birth_year  INTEGER CHECK (birth_year >= 1000 AND birth_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    country     VARCHAR(50),
    bio         TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Таблиця книг
CREATE TABLE books (
    book_id          SERIAL PRIMARY KEY,
    isbn             VARCHAR(17) NOT NULL UNIQUE,
    title            VARCHAR(200) NOT NULL,
    author_id        INTEGER NOT NULL,
    genre_id         INTEGER NOT NULL,
    publication_year INTEGER CHECK (publication_year >= 1450 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    pages            INTEGER CHECK (pages > 0),
    price            DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity   INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_books_author
        FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE RESTRICT,
    CONSTRAINT fk_books_genre
        FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE RESTRICT
);

-- 4. Таблиця клієнтів (покупців)
CREATE TABLE customers (
    customer_id      SERIAL PRIMARY KEY,
    full_name        VARCHAR(100) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    city             VARCHAR(50),
    address          VARCHAR(200),
    discount_percent DECIMAL(5, 2) DEFAULT 0.00 CHECK (discount_percent >= 0.00 AND discount_percent <= 50.00),
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Таблиця замовлень
CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL,
    order_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status       VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Processing', 'Completed', 'Cancelled')),
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0.00),
    notes        TEXT,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT
);

-- 6. Таблиця позицій замовлень (Order Items)
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INTEGER NOT NULL,
    book_id       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0.00),
    subtotal      DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_book
        FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    CONSTRAINT uq_order_book
        UNIQUE (order_id, book_id)
);

-- 7. Таблиця користувачів системи (Рівень 3 - RBAC)
CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    username      VARCHAR(64) NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    role          VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (role IN ('admin', 'manager', 'user')),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Журнал аудиту активності (Рівень 3 - Audit Log)
CREATE TABLE activity_log (
    log_id      SERIAL PRIMARY KEY,
    user_id     INTEGER,
    username    VARCHAR(64),
    action      VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id   INTEGER,
    details     JSONB,
    ip_address  VARCHAR(45),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 9. Журнал аудиту цін на книги (для тригера аудиту цін)
CREATE TABLE book_price_audit (
    audit_id   SERIAL PRIMARY KEY,
    book_id    INTEGER NOT NULL,
    old_price  DECIMAL(10, 2) NOT NULL,
    new_price  DECIMAL(10, 2) NOT NULL,
    changed_by VARCHAR(50) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_book
        FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Створення B-Tree індексів для оптимізації продуктивності (Рівень 3)
CREATE INDEX idx_books_author_id ON books(author_id);
CREATE INDEX idx_books_genre_id ON books(genre_id);
CREATE INDEX idx_books_price ON books(price);
CREATE INDEX idx_books_title_lower ON books(LOWER(title));
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_book_id ON order_items(book_id);
CREATE INDEX idx_activity_log_created_at ON activity_log(created_at);
