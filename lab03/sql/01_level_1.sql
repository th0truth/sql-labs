-- ============================================================================
-- Лабораторна робота №3: Модифікація даних та транзакції
-- Рівень складності: Рівень 1
-- База даних: Керування бібліотекою (Library Management)
-- ============================================================================

-- ============================================================================
-- 1. Створення структури бази даних з обмеженнями цілісності
-- ============================================================================

-- Очищення попередніх версій таблиць (у порядку зворотному до залежностей)
DROP TABLE IF EXISTS lendings CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS readers CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;

-- 1.1. Таблиця авторів
-- Обмеження: PRIMARY KEY, NOT NULL, CHECK (діапазон року народження)
CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    birth_year  INTEGER CHECK (birth_year >= 1000 AND birth_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    country     VARCHAR(50),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.2. Таблиця книг
-- Обмеження: PRIMARY KEY, UNIQUE (isbn), NOT NULL, FOREIGN KEY (RESTRICT),
--            CHECK (рік видання >= 1450, невід'ємна кількість, available <= total)
CREATE TABLE books (
    book_id          SERIAL PRIMARY KEY,
    isbn             VARCHAR(17) UNIQUE NOT NULL,
    title            VARCHAR(200) NOT NULL,
    author_id        INTEGER NOT NULL,
    publication_year INTEGER CHECK (publication_year >= 1450),
    genre            VARCHAR(50),
    total_copies     INTEGER DEFAULT 1 CHECK (total_copies >= 0),
    available_copies INTEGER DEFAULT 1 CHECK (available_copies >= 0),
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_books_author
        FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE RESTRICT,
    CONSTRAINT chk_available_copies_limit
        CHECK (available_copies <= total_copies)
);

-- 1.3. Таблиця читачів
-- Обмеження: PRIMARY KEY, UNIQUE (email, library_card_number), NOT NULL,
--            CHECK (допустимі статуси читача: Active, Blocked, Inactive)
CREATE TABLE readers (
    reader_id           SERIAL PRIMARY KEY,
    first_name          VARCHAR(50) NOT NULL,
    last_name           VARCHAR(50) NOT NULL,
    email               VARCHAR(100) UNIQUE NOT NULL,
    phone               VARCHAR(20),
    library_card_number VARCHAR(20) UNIQUE NOT NULL,
    registration_date   DATE DEFAULT CURRENT_DATE,
    status              VARCHAR(20) DEFAULT 'Active'
        CHECK (status IN ('Active', 'Blocked', 'Inactive'))
);

-- 1.4. Таблиця видач книг
-- Обмеження: PRIMARY KEY, FOREIGN KEY до books і readers (RESTRICT),
--            CHECK (термін повернення due_date пізніше дати видачі lending_date,
--                   фактична дата повернення return_date >= дати видачі)
CREATE TABLE lendings (
    lending_id   SERIAL PRIMARY KEY,
    book_id      INTEGER NOT NULL,
    reader_id    INTEGER NOT NULL,
    lending_date DATE DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL,
    return_date  DATE,
    CONSTRAINT fk_lendings_book
        FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lendings_reader
        FOREIGN KEY (reader_id) REFERENCES readers(reader_id) ON DELETE RESTRICT,
    CONSTRAINT chk_due_date_future
        CHECK (due_date > lending_date),
    CONSTRAINT chk_return_date_valid
        CHECK (return_date IS NULL OR return_date >= lending_date)
);


-- ============================================================================
-- 2. Операції додавання нових записів (INSERT) та перевірка обмежень
-- ============================================================================

-- 2.1. Додавання авторів
INSERT INTO authors (first_name, last_name, birth_year, country)
VALUES
    ('Тарас', 'Шевченко', 1814, 'Україна'),
    ('Іван', 'Франко', 1856, 'Україна'),
    ('Леся', 'Українка', 1871, 'Україна'),
    ('Михайло', 'Коцюбинський', 1864, 'Україна'),
    ('Панас', 'Мирний', 1849, 'Україна');

-- 2.2. Додавання книг
INSERT INTO books (isbn, title, author_id, publication_year, genre, total_copies, available_copies)
VALUES
    ('978-966-03-4561-2', 'Кобзар', 1, 1840, 'Поезія', 10, 10),
    ('978-966-03-4562-9', 'Захар Беркут', 2, 1883, 'Історична проза', 5, 5),
    ('978-966-03-4563-6', 'Лісова пісня', 3, 1911, 'Драма', 7, 7),
    ('978-966-03-4564-3', 'Тіні забутих предків', 4, 1911, 'Повість', 6, 6),
    ('978-966-03-4565-0', 'Хіба ревуть воли, як ясла повні', 5, 1880, 'Повість', 4, 4);

-- 2.3. Додавання читачів
INSERT INTO readers (first_name, last_name, email, phone, library_card_number)
VALUES
    ('Олена', 'Петренко', 'olena.petrenko@email.com', '+380501234567', 'LIB-2024-001'),
    ('Андрій', 'Коваленко', 'andrii.kovalenko@email.com', '+380502345678', 'LIB-2024-002'),
    ('Марія', 'Сидоренко', 'maria.sydorenko@email.com', '+380503456789', 'LIB-2024-003'),
    ('Іван', 'Мельник', 'ivan.melnyk@email.com', '+380504567890', 'LIB-2024-004');

-- Перевірка вставлених даних
SELECT * FROM authors;
SELECT * FROM books;
SELECT * FROM readers;

-- 2.4. Демонстрація перевірки обмежень (тест на помилку CHECK):
-- Спроба вставити книгу з available_copies (15) > total_copies (10).
-- При виконанні буде згенеровано помилку:
-- ERROR: new row for relation "books" violates check constraint "chk_available_copies_limit"
DO $$
BEGIN
    INSERT INTO books (isbn, title, author_id, publication_year, genre, total_copies, available_copies)
    VALUES ('978-966-03-9999-9', 'Помилкова книга', 1, 2024, 'Тест', 10, 15);
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'Успішно перехоплено порушення CHECK обмеження (available_copies <= total_copies)';
END $$;


-- ============================================================================
-- 3. Безпечне оновлення записів з використанням умов WHERE (UPDATE)
-- ============================================================================

-- Крок 3.1: Перевірка поточного стану книги перед оновленням
SELECT book_id, title, available_copies, total_copies
FROM books
WHERE book_id = 1;

-- Крок 3.2: Безпечне зменшення кількості вільних примірників
-- Обов'язкова умова WHERE за первинним ключем та додатковий запобіжник (available_copies > 0)
UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = 1
  AND available_copies > 0;

-- Крок 3.3: Контрольна перевірка результату оновлення
SELECT book_id, title, available_copies, total_copies
FROM books
WHERE book_id = 1;


-- ============================================================================
-- 4. Використання простих транзакцій для групування операцій (COMMIT)
-- ============================================================================

-- Бізнес-процес: комплексна видача книги читачеві (атомарна дія: створення запису про видачу + зміна залишку книги)
BEGIN;

-- 1. Реєстрація видачі книги №1 читачеві №1 на 14 днів
INSERT INTO lendings (book_id, reader_id, due_date)
VALUES (1, 1, CURRENT_DATE + INTERVAL '14 days');

-- 2. Списання одного доступного примірника книги зі сховища
UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = 1
  AND available_copies > 0;

-- 3. Перевірка цілісності даних перед підтвердженням
SELECT * FROM lendings WHERE book_id = 1 AND reader_id = 1 AND return_date IS NULL;
SELECT book_id, title, available_copies FROM books WHERE book_id = 1;

-- 4. Успішна фіксація транзакції
COMMIT;


-- ============================================================================
-- 5. Демонстрація роботи механізму ROLLBACK при помилках
-- ============================================================================

-- Сценарій: початок транзакції, модифікація даних та виникнення конфлікту цілісності
BEGIN;

-- 1. Попередня дія: блокування читача №2
UPDATE readers
SET status = 'Blocked'
WHERE reader_id = 2;

-- 2. Спроба видалити автора №1, у якого є зареєстровані книги в таблиці books.
-- СУБД повертає помилку через обмеження ON DELETE RESTRICT:
-- ERROR: update or delete on table "authors" violates foreign key constraint "fk_books_author"
DO $$
BEGIN
    DELETE FROM authors WHERE author_id = 1;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Помилка зовнішнього ключа: неможливо видалити автора, який має книги';
END $$;

-- 3. Відкат транзакції: скасовуються всі попередні зміни цієї транзакції (включно зі зміною статусу читача)
ROLLBACK;

-- 4. Перевірка: статус читача №2 залишився попереднім ('Active'), відкат успішно захистив базу
SELECT reader_id, first_name, last_name, status
FROM readers
WHERE reader_id = 2;


-- ============================================================================
-- 6. Здійснення видалення записів з урахуванням зовнішніх ключів (DELETE)
-- ============================================================================

-- 6.1. Демонстрація захисту від видалення книги з активною видачею:
-- Книга №1 зараз видана читачеві №1 (запис у lendings), тому видалення заборонено
DO $$
BEGIN
    DELETE FROM books WHERE book_id = 1;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Захист цілісності: книгу з активною видачею не можна видалити';
END $$;

-- 6.2. Безпечне видалення неактивного читача, що не має заборгованостей
-- Додаємо тимчасового читача без замовлень
INSERT INTO readers (first_name, last_name, email, phone, library_card_number, status)
VALUES ('Тест', 'Тестовий', 'temp.test@email.com', '+380990001122', 'LIB-TEMP-999', 'Inactive');

-- Перевірка перед видаленням
SELECT * FROM readers WHERE library_card_number = 'LIB-TEMP-999';

-- Безпечне видалення неактивного читача без неповернутих книг
DELETE FROM readers
WHERE status = 'Inactive'
  AND reader_id NOT IN (
      SELECT DISTINCT reader_id
      FROM lendings
      WHERE return_date IS NULL
  );

-- Контрольна перевірка: читача видалено
SELECT * FROM readers WHERE library_card_number = 'LIB-TEMP-999';
