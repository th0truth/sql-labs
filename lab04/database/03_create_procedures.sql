-- ============================================================================
-- Лабораторна робота №4: Розробка реляційної бази даних з простою інтеграцією
-- Скрипт: 03_create_procedures.sql
-- Збережені процедури та функції (Рівень 2: мінімум 3 процедури)
-- ============================================================================

SET search_path TO bookstore, public;

-- ----------------------------------------------------------------------------
-- Процедура 1: Безпечне додавання книги з перевіркою або створенням автора
-- Призначення: автоматизує перевірку наявності автора за ПІБ. Якщо автор відсутній,
-- створює нового автора та пов'язує книгу в одній атомарній операції.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_add_book_with_author(
    p_isbn VARCHAR,
    p_title VARCHAR,
    p_author_first VARCHAR,
    p_author_last VARCHAR,
    p_genre_id INT,
    p_year INT,
    p_pages INT,
    p_price DECIMAL,
    p_stock INT DEFAULT 0
) RETURNS INT AS $$
DECLARE
    v_author_id INT;
    v_book_id   INT;
BEGIN
    -- Перевірка валідності вхідних даних
    IF p_price < 0 THEN
        RAISE EXCEPTION 'Помилка валідації: Ціна книги не може бути від''ємною (%)', p_price;
    END IF;

    IF p_stock < 0 THEN
        RAISE EXCEPTION 'Помилка валідації: Кількість на складі не може бути меншою за 0 (%)', p_stock;
    END IF;

    -- Перевірка існування жанру
    IF NOT EXISTS (SELECT 1 FROM genres WHERE genre_id = p_genre_id) THEN
        RAISE EXCEPTION 'Помилка цілісності: Жанр з ID % не знайдено', p_genre_id;
    END IF;

    -- Пошук або створення автора
    SELECT author_id INTO v_author_id
    FROM authors
    WHERE LOWER(first_name) = LOWER(p_author_first)
      AND LOWER(last_name) = LOWER(p_author_last);

    IF v_author_id IS NULL THEN
        INSERT INTO authors (first_name, last_name, country)
        VALUES (p_author_first, p_author_last, 'Україна')
        RETURNING author_id INTO v_author_id;
    END IF;

    -- Створення книги
    INSERT INTO books (isbn, title, author_id, genre_id, publication_year, pages, price, stock_quantity)
    VALUES (p_isbn, p_title, v_author_id, p_genre_id, p_year, p_pages, p_price, p_stock)
    RETURNING book_id INTO v_book_id;

    RETURN v_book_id;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Процедура 2: Масове оновлення цін на книги обраного жанру зі знижкою
-- Призначення: застосовує акційну знижку (у відсотках) до всіх книг жанру,
-- повертає перелік модифікованих книг із зазначенням старої та нової ціни.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_apply_genre_discount(
    p_genre_id INT,
    p_discount_percent DECIMAL
) RETURNS TABLE(
    out_book_id INT,
    out_title VARCHAR,
    out_old_price DECIMAL,
    out_new_price DECIMAL
) AS $$
BEGIN
    IF p_discount_percent <= 0 OR p_discount_percent > 90 THEN
        RAISE EXCEPTION 'Некоректний відсоток знижки: %. Дозволений діапазон від 1%% до 90%%', p_discount_percent;
    END IF;

    RETURN QUERY
    WITH updated AS (
        UPDATE books
        SET price = ROUND((price * (1 - p_discount_percent / 100.0)), 2),
            updated_at = CURRENT_TIMESTAMP
        WHERE genre_id = p_genre_id
        RETURNING book_id, title, (price / (1 - p_discount_percent / 100.0))::DECIMAL(10,2) AS old_price, price AS new_price
    )
    SELECT book_id, title, old_price, new_price FROM updated;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Процедура 3: Отримання розширеної бізнес-аналітики по автору
-- Призначення: обчислює агреговані показники (кількість книг, середня ціна,
-- загальний тираж на складі, сумарний виторг від продажу в успішних замовленнях).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_get_author_analytics(p_author_id INT)
RETURNS TABLE(
    author_full_name TEXT,
    total_books BIGINT,
    avg_price DECIMAL,
    min_price DECIMAL,
    max_price DECIMAL,
    total_stock BIGINT,
    total_sales_revenue DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (a.first_name || ' ' || a.last_name)::TEXT AS author_full_name,
        COUNT(b.book_id)::BIGINT AS total_books,
        COALESCE(ROUND(AVG(b.price), 2), 0.00)::DECIMAL(10,2) AS avg_price,
        COALESCE(MIN(b.price), 0.00)::DECIMAL(10,2) AS min_price,
        COALESCE(MAX(b.price), 0.00)::DECIMAL(10,2) AS max_price,
        COALESCE(SUM(b.stock_quantity), 0)::BIGINT AS total_stock,
        COALESCE(SUM(oi.subtotal), 0.00)::DECIMAL(10,2) AS total_sales_revenue
    FROM authors a
    LEFT JOIN books b ON b.author_id = a.author_id
    LEFT JOIN order_items oi ON oi.book_id = b.book_id
    LEFT JOIN orders o ON o.order_id = oi.order_id AND o.status = 'Completed'
    WHERE a.author_id = p_author_id
    GROUP BY a.author_id, a.first_name, a.last_name;
END;
$$ LANGUAGE plpgsql;
