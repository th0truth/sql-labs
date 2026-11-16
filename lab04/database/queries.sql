-- ============================================================================
-- Лабораторна робота №4: Розробка реляційної бази даних з простою інтеграцією
-- Скрипт: queries.sql
-- Демонстраційні SQL-запити різної складності (Рівні 1-2)
-- ============================================================================

SET search_path TO bookstore, public;

-- ----------------------------------------------------------------------------
-- Запит 1 (Рівень 1): Простий запит з фільтрацією та сортуванням
-- Мета: Знайти всі книги дорожчі за 250 грн, які є в наявності (stock > 0),
-- відсортовані за спаданням вартості.
-- ----------------------------------------------------------------------------
SELECT
    book_id,
    isbn,
    title,
    publication_year,
    price,
    stock_quantity
FROM books
WHERE price >= 250.00 AND stock_quantity > 0
ORDER BY price DESC, title ASC;

-- ----------------------------------------------------------------------------
-- Запит 2 (Рівень 1): Багатотабличне об'єднання (INNER JOIN)
-- Мета: Отримати детальний перелік книг із зазначенням ПІБ автора, країни
-- походження та назви жанру для творів українських авторів.
-- ----------------------------------------------------------------------------
SELECT
    b.book_id,
    b.title,
    (a.first_name || ' ' || a.last_name) AS author_name,
    a.country,
    g.name AS genre_name,
    b.price
FROM books b
INNER JOIN authors a ON a.author_id = b.author_id
INNER JOIN genres g  ON g.genre_id = b.genre_id
WHERE a.country = 'Україна'
ORDER BY a.last_name, b.title;

-- ----------------------------------------------------------------------------
-- Запит 3 (Рівень 1): Агрегатний запит із групуванням (GROUP BY + HAVING)
-- Мета: Обчислити кількість книг та середню ціну для кожного жанру, де є хоча б
-- 2 зареєстровані найменування, з сортуванням за середньою ціною.
-- ----------------------------------------------------------------------------
SELECT
    g.genre_id,
    g.name AS genre_name,
    COUNT(b.book_id) AS total_books,
    ROUND(AVG(b.price), 2) AS avg_price,
    MIN(b.price) AS min_price,
    MAX(b.price) AS max_price
FROM genres g
INNER JOIN books b ON b.genre_id = g.genre_id
GROUP BY g.genre_id, g.name
HAVING COUNT(b.book_id) >= 2
ORDER BY avg_price DESC;

-- ----------------------------------------------------------------------------
-- Запит 4 (Рівень 1): Запит із вкладеним підзапитом (Subquery)
-- Мета: Знайти книги, вартість яких перевищує середню ціну по всій книгарні.
-- ----------------------------------------------------------------------------
SELECT
    b.book_id,
    b.title,
    b.price,
    ROUND((SELECT AVG(price) FROM books), 2) AS bookstore_avg_price,
    ROUND(b.price - (SELECT AVG(price) FROM books), 2) AS price_difference
FROM books b
WHERE b.price > (SELECT AVG(price) FROM books)
ORDER BY b.price DESC;

-- ----------------------------------------------------------------------------
-- Запит 5 (Рівень 2): Складний аналітичний запит продажів за авторами
-- Мета: Розрахувати загальний фінансовий оборот кожного автора на основі
-- успішно виконаних замовлень (JOIN 5 таблиць).
-- ----------------------------------------------------------------------------
SELECT
    a.author_id,
    (a.first_name || ' ' || a.last_name) AS author_name,
    COUNT(DISTINCT b.book_id) AS catalog_books_count,
    COALESCE(SUM(oi.quantity), 0) AS total_copies_sold,
    COALESCE(SUM(oi.subtotal), 0.00) AS total_revenue
FROM authors a
INNER JOIN books b ON b.author_id = a.author_id
LEFT JOIN order_items oi ON oi.book_id = b.book_id
LEFT JOIN orders o ON o.order_id = oi.order_id AND o.status = 'Completed'
GROUP BY a.author_id, a.first_name, a.last_name
ORDER BY total_revenue DESC, total_copies_sold DESC;

-- ----------------------------------------------------------------------------
-- Запит 6 (Рівень 2): Аналіз конверсії міст та активності клієнтів
-- Мета: Визначити топ міст за кількістю оформлених замовлень та середнім чеком.
-- ----------------------------------------------------------------------------
SELECT
    c.city,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0.00) AS total_turnover,
    COALESCE(ROUND(AVG(o.total_amount), 2), 0.00) AS avg_order_ticket
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE c.city IS NOT NULL
GROUP BY c.city
ORDER BY total_turnover DESC;
