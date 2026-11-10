-- ============================================================================
-- Лабораторна робота №3: Модифікація даних та транзакції
-- Рівень складності: Рівень 2
-- База даних: Керування бібліотекою (Library Management)
-- ============================================================================

-- ============================================================================
-- 1. Додавання таблиць для бронювань та історії змін
-- ============================================================================

-- 1.1. Таблиця бронювань книг
-- Обмеження: PRIMARY KEY, FOREIGN KEY з ON DELETE CASCADE, CHECK (статус)
DROP TABLE IF EXISTS reservations CASCADE;

CREATE TABLE reservations (
    reservation_id   SERIAL PRIMARY KEY,
    book_id          INTEGER NOT NULL,
    reader_id        INTEGER NOT NULL,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiration_date  TIMESTAMP NOT NULL,
    status           VARCHAR(20) DEFAULT 'Active'
        CHECK (status IN ('Active', 'Fulfilled', 'Cancelled', 'Expired')),
    CONSTRAINT fk_reservations_book
        FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservations_reader
        FOREIGN KEY (reader_id) REFERENCES readers(reader_id) ON DELETE CASCADE
);

-- 1.2. Таблиця історії аудиту змін (Audit Log)
-- Зберігає знімки рядків до та після модифікації у форматі JSONB
CREATE TABLE IF NOT EXISTS audit_log (
    log_id      SERIAL PRIMARY KEY,
    table_name  VARCHAR(50) NOT NULL,
    operation   VARCHAR(10) NOT NULL,
    record_id   INTEGER NOT NULL,
    old_data    JSONB,
    new_data    JSONB,
    changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by  VARCHAR(100) DEFAULT CURRENT_USER
);

-- Додавання тестового бронювання читачем №2 на книгу №1
INSERT INTO reservations (book_id, reader_id, expiration_date, status)
VALUES (1, 2, CURRENT_TIMESTAMP + INTERVAL '7 days', 'Active');

-- Перевірка стану таблиці бронювань
SELECT * FROM reservations;


-- ============================================================================
-- 2. Складні транзакції з множинними операціями модифікації
-- ============================================================================

-- Бізнес-процес: Повернення виданої книги та автоматичне задоволення черги бронювання
-- Виконується як єдина неподільна транзакція
BEGIN;

-- Крок 2.1: Фіксація фактичного повернення книги у таблиці видач
UPDATE lendings
SET return_date = CURRENT_DATE
WHERE lending_id = 1 
  AND return_date IS NULL;

-- Крок 2.2: Збільшення кількості вільних примірників книги
UPDATE books
SET available_copies = available_copies + 1
WHERE book_id = (SELECT book_id FROM lendings WHERE lending_id = 1);

-- Крок 2.3: Перевірка наявності активних бронювань на цю книгу
SELECT reservation_id, reader_id, book_id, reservation_date, status
FROM reservations
WHERE book_id = (SELECT book_id FROM lendings WHERE lending_id = 1)
  AND status = 'Active'
ORDER BY reservation_date ASC
LIMIT 1;

-- Крок 2.4: Якщо є активне бронювання — переведення його статусу у 'Fulfilled'
UPDATE reservations
SET status = 'Fulfilled'
WHERE reservation_id = (
    SELECT reservation_id
    FROM reservations
    WHERE book_id = (SELECT book_id FROM lendings WHERE lending_id = 1)
      AND status = 'Active'
    ORDER BY reservation_date ASC
    LIMIT 1
);

-- Крок 2.5: Перевірка узгодженості даних перед фіксацією
SELECT lending_id, book_id, reader_id, return_date FROM lendings WHERE lending_id = 1;
SELECT book_id, title, available_copies FROM books WHERE book_id = (SELECT book_id FROM lendings WHERE lending_id = 1);
SELECT * FROM reservations WHERE status = 'Fulfilled';

-- Фіксація всіх змін
COMMIT;


-- ============================================================================
-- 3. Впровадження каскадних операцій (ON DELETE CASCADE)
-- ============================================================================

-- Підготовка тестових даних: книга з прив'язаним бронюванням
INSERT INTO books (isbn, title, author_id, publication_year, genre, total_copies, available_copies)
VALUES ('978-966-00-9999-0', 'Тимчасова книга для каскаду', 1, 2024, 'Тест', 1, 0);

INSERT INTO reservations (book_id, reader_id, expiration_date, status)
VALUES (
    (SELECT book_id FROM books WHERE isbn = '978-966-00-9999-0'),
    1,
    CURRENT_TIMESTAMP + INTERVAL '3 days',
    'Active'
);

-- Перевірка наявності зв'язку між книгою та бронюванням
SELECT b.book_id, b.title, b.isbn, r.reservation_id, r.status
FROM books AS b
INNER JOIN reservations AS r ON b.book_id = r.book_id
WHERE b.isbn = '978-966-00-9999-0';

-- Видалення книги: завдяки ON DELETE CASCADE відповідне бронювання видаляється автоматично
DELETE FROM books
WHERE isbn = '978-966-00-9999-0';

-- Перевірка результату каскаду: бронювання також успішно видалено
SELECT *
FROM reservations
WHERE book_id NOT IN (SELECT book_id FROM books);


-- ============================================================================
-- 4. Використання точок збереження (SAVEPOINT) для часткового відкату
-- ============================================================================

-- Бізнес-сценарій: додавання автора та книг у межах однієї транзакції
-- Якщо виникає помилка при додаванні другої книги (наприклад, дублікат ISBN),
-- ми відкочуємося лише до точки збереження, не втрачаючи вже доданого автора.
BEGIN;

-- Дія 1: Додавання нової авторки
INSERT INTO authors (first_name, last_name, birth_year, country)
VALUES ('Ольга', 'Кобилянська', 1863, 'Україна');

-- Встановлення точки збереження після успішного додавання автора
SAVEPOINT after_author_insert;

-- Дія 2: Спроба вставити книгу з дублікатом ISBN першої книги ('Кобзар')
-- Це викликає помилку порушення унікальності books_isbn_key
DO $$
BEGIN
    INSERT INTO books (isbn, title, author_id, publication_year, genre, total_copies, available_copies)
    VALUES (
        '978-966-03-4561-2', -- дублікат ISBN
        'Помилкова книга з існуючим ISBN',
        (SELECT author_id FROM authors WHERE last_name = 'Кобилянська' LIMIT 1),
        1902, 'Роман', 3, 3
    );
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Виявлено дублікат ISBN! Виконуємо відкат до точки збереження after_author_insert.';
END $$;

-- Частковий відкат до точки збереження: скасовує збійну операцію,
-- повертаючи транзакцію в активний працездатний стан
ROLLBACK TO SAVEPOINT after_author_insert;

-- Дія 3: Повторна вставка книги вже з коректним унікальним ISBN
INSERT INTO books (isbn, title, author_id, publication_year, genre, total_copies, available_copies)
VALUES (
    '978-966-03-4567-4',
    'Земля',
    (SELECT author_id FROM authors WHERE last_name = 'Кобилянська' LIMIT 1),
    1902, 'Роман', 3, 3
);

-- Фіксація транзакції: автор та книга з правильним ISBN успішно збережені
COMMIT;

-- Перевірка результату роботи SAVEPOINT
SELECT a.first_name, a.last_name, b.title, b.isbn
FROM authors AS a
INNER JOIN books AS b ON a.author_id = b.author_id
WHERE a.last_name = 'Кобилянська';


-- ============================================================================
-- 5. Створення тригерів для автоматичного ведення історії змін
-- ============================================================================

-- 5.1. Тригерна функція аудиту таблиці books
CREATE OR REPLACE FUNCTION log_books_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, record_id, new_data)
        VALUES ('books', 'INSERT', NEW.book_id, row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_data, new_data)
        VALUES ('books', 'UPDATE', NEW.book_id, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_data)
        VALUES ('books', 'DELETE', OLD.book_id, row_to_json(OLD)::jsonb);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 5.2. Прив'язка тригера до таблиці books
DROP TRIGGER IF EXISTS books_audit_trigger ON books;

CREATE TRIGGER books_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON books
FOR EACH ROW
EXECUTE FUNCTION log_books_changes();

-- 5.3. Тестування тригера: зміна залишків книги №2 ('Захар Беркут')
UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = 2;

-- 5.4. Перегляд результатів у журналі аудиту (витяг даних із JSONB)
SELECT
    log_id,
    table_name,
    operation,
    record_id,
    new_data->>'title'            AS book_title,
    old_data->>'available_copies' AS previous_available,
    new_data->>'available_copies' AS current_available,
    changed_at,
    changed_by
FROM audit_log
WHERE table_name = 'books'
ORDER BY log_id DESC
LIMIT 5;


-- ============================================================================
-- 6. Реалізація механізмів блокування записів для паралельного доступу
-- ============================================================================

-- Бізнес-логіка: Песимістичне блокування рядка (SELECT ... FOR UPDATE)
-- Запобігає стану гонки (race condition) та аномалії втраченого оновлення (Lost Update),
-- коли два користувачі одночасно намагаються взяти останній примірник книги.

BEGIN;

-- 1. Ексклюзивне блокування рядка книги №3 ('Лісова пісня') для читання та наступного оновлення.
-- Будь-яка інша транзакція, що виконає SELECT ... FOR UPDATE або UPDATE для цього рядка,
-- буде очікувати завершення поточної транзакції.
SELECT book_id, title, available_copies
FROM books
WHERE book_id = 3
FOR UPDATE;

-- 2. Безпечна модифікація заблокованого ресурсу
UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = 3 
  AND available_copies > 0;

-- 3. Фіксація змін та автоматичне зняття блокування
COMMIT;

-- Перевірка підсумкового стану книги №3
SELECT book_id, title, available_copies, total_copies
FROM books
WHERE book_id = 3;
