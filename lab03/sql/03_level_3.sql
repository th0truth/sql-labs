-- ============================================================================
-- Лабораторна робота №3: Модифікація даних та транзакції
-- Рівень складності: Рівень 3
-- База даних: Керування бібліотекою (Library Management)
-- ============================================================================

-- ============================================================================
-- 1. Система версіонування записів (SCD Type 2 Temporal Versioning)
-- ============================================================================

-- 1.1. Таблиця історії версій книг (Temporal History)
DROP TABLE IF EXISTS books_history CASCADE;

CREATE TABLE books_history (
    history_id       SERIAL PRIMARY KEY,
    book_id          INTEGER NOT NULL,
    version_num      INTEGER NOT NULL,
    isbn             VARCHAR(17) NOT NULL,
    title            VARCHAR(200) NOT NULL,
    author_id        INTEGER NOT NULL,
    publication_year INTEGER,
    genre            VARCHAR(50),
    total_copies     INTEGER NOT NULL,
    available_copies INTEGER NOT NULL,
    valid_from       TIMESTAMP NOT NULL,
    valid_to         TIMESTAMP,
    is_current       BOOLEAN DEFAULT TRUE,
    change_type      VARCHAR(10) NOT NULL CHECK (change_type IN ('INSERT', 'UPDATE', 'DELETE', 'REVERT')),
    changed_by       VARCHAR(100) DEFAULT CURRENT_USER
);

-- 1.2. Тригерна функція для автоматичного версіонування змін таблиці books
CREATE OR REPLACE FUNCTION trg_books_versioning()
RETURNS TRIGGER AS $$
DECLARE
    v_last_version INT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO books_history (
            book_id, version_num, isbn, title, author_id, publication_year,
            genre, total_copies, available_copies, valid_from, valid_to, is_current, change_type
        ) VALUES (
            NEW.book_id, 1, NEW.isbn, NEW.title, NEW.author_id, NEW.publication_year,
            NEW.genre, NEW.total_copies, NEW.available_copies, CURRENT_TIMESTAMP, NULL, TRUE, 'INSERT'
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        -- Визначаємо останній номер версії для цієї книги
        SELECT COALESCE(MAX(version_num), 0) INTO v_last_version
        FROM books_history
        WHERE book_id = NEW.book_id;

        -- Закриваємо попередню версію
        UPDATE books_history
        SET valid_to = CURRENT_TIMESTAMP,
            is_current = FALSE
        WHERE book_id = NEW.book_id AND is_current = TRUE;

        -- Створюємо нову версію
        INSERT INTO books_history (
            book_id, version_num, isbn, title, author_id, publication_year,
            genre, total_copies, available_copies, valid_from, valid_to, is_current, change_type
        ) VALUES (
            NEW.book_id, v_last_version + 1, NEW.isbn, NEW.title, NEW.author_id, NEW.publication_year,
            NEW.genre, NEW.total_copies, NEW.available_copies, CURRENT_TIMESTAMP, NULL, TRUE, 'UPDATE'
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        -- Позначаємо поточну версію як закриту через DELETE
        UPDATE books_history
        SET valid_to = CURRENT_TIMESTAMP,
            is_current = FALSE,
            change_type = 'DELETE'
        WHERE book_id = OLD.book_id AND is_current = TRUE;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_books_versioning ON books;
CREATE TRIGGER trg_books_versioning
AFTER INSERT OR UPDATE OR DELETE ON books
FOR EACH ROW EXECUTE FUNCTION trg_books_versioning();

-- 1.3. Початкова синхронізація наявних книг у таблицю версій (якщо вони ще не занесені)
INSERT INTO books_history (
    book_id, version_num, isbn, title, author_id, publication_year,
    genre, total_copies, available_copies, valid_from, is_current, change_type
)
SELECT
    book_id, 1, isbn, title, author_id, publication_year,
    genre, total_copies, available_copies, created_at, TRUE, 'INSERT'
FROM books
WHERE book_id NOT IN (SELECT DISTINCT book_id FROM books_history);

-- Демонстрація створення версій: кілька послідовних оновлень книги №1
UPDATE books 
SET title = 'Кобзар (Повне коментоване видання)', total_copies = 15 
WHERE book_id = 1;

UPDATE books 
SET available_copies = available_copies + 2 
WHERE book_id = 1;

-- Перегляд повної історії змін книги №1
SELECT
    book_id,
    version_num,
    title,
    total_copies,
    available_copies,
    valid_from,
    valid_to,
    is_current,
    change_type
FROM books_history
WHERE book_id = 1
ORDER BY version_num ASC;


-- ============================================================================
-- 2. Механізм відкладених операцій з автоматичним виконанням
-- ============================================================================

-- 2.1. Таблиця черги відкладених операцій (Deferred Task Queue)
DROP TABLE IF EXISTS deferred_operations CASCADE;

CREATE TABLE deferred_operations (
    operation_id   SERIAL PRIMARY KEY,
    operation_type VARCHAR(50) NOT NULL, -- 'EXPIRE_RESERVATIONS', 'APPLY_DISCOUNT', 'AUTO_CANCEL_OVERDUE'
    target_table   VARCHAR(50) NOT NULL,
    payload        JSONB,                -- параметри виконання задачі
    scheduled_at   TIMESTAMP NOT NULL,   -- запланований час запуску
    status         VARCHAR(20) DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    executed_at    TIMESTAMP,
    error_message  TEXT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.2. Процедура для автоматичного виконання черги задач
CREATE OR REPLACE PROCEDURE sp_execute_deferred_operations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_task RECORD;
    v_processed_count INT := 0;
BEGIN
    -- Вибираємо та песимістично блокуємо задачі, час яких настав (FOR UPDATE SKIP LOCKED)
    FOR v_task IN
        SELECT operation_id, operation_type, payload
        FROM deferred_operations
        WHERE scheduled_at <= CURRENT_TIMESTAMP
          AND status = 'PENDING'
        ORDER BY scheduled_at ASC
        FOR UPDATE SKIP LOCKED
    LOOP
        -- Переводимо задачу у стан обробки
        UPDATE deferred_operations
        SET status = 'PROCESSING'
        WHERE operation_id = v_task.operation_id;

        BEGIN
            -- Обробка операції: скасування прострочених бронювань
            IF v_task.operation_type = 'EXPIRE_RESERVATIONS' THEN
                UPDATE reservations
                SET status = 'Expired'
                WHERE status = 'Active'
                  AND expiration_date < CURRENT_TIMESTAMP;

            -- Обробка операції: масове поповнення складських запасів
            ELSIF v_task.operation_type = 'RESTOCK_BOOK' THEN
                UPDATE books
                SET total_copies = total_copies + (v_task.payload->>'quantity')::INT,
                    available_copies = available_copies + (v_task.payload->>'quantity')::INT
                WHERE book_id = (v_task.payload->>'book_id')::INT;

            ELSE
                RAISE EXCEPTION 'Невідомий тип операції: %', v_task.operation_type;
            END IF;

            -- Успішне завершення задачі
            UPDATE deferred_operations
            SET status = 'COMPLETED',
                executed_at = CURRENT_TIMESTAMP
            WHERE operation_id = v_task.operation_id;

            v_processed_count := v_processed_count + 1;

        EXCEPTION WHEN OTHERS THEN
            -- Фіксація помилки виконання окремої задачі
            UPDATE deferred_operations
            SET status = 'FAILED',
                executed_at = CURRENT_TIMESTAMP,
                error_message = SQLERRM
            WHERE operation_id = v_task.operation_id;
        END;
    END LOOP;

    RAISE NOTICE 'Виконано відкладених операцій: %', v_processed_count;
END;
$$;

-- 2.3. Додавання відкладених завдань до черги
INSERT INTO deferred_operations (operation_type, target_table, payload, scheduled_at)
VALUES
    ('EXPIRE_RESERVATIONS', 'reservations', '{}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '1 minute'),
    ('RESTOCK_BOOK', 'books', '{"book_id": 2, "quantity": 5}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '10 seconds');

-- Виконання відкладених операцій
CALL sp_execute_deferred_operations();

-- Перевірка статусу виконання черги завдань
SELECT operation_id, operation_type, status, scheduled_at, executed_at, payload
FROM deferred_operations
ORDER BY operation_id DESC;


-- ============================================================================
-- 3. Складна бізнес-логіка через збережені процедури
-- ============================================================================

-- Процедура видачі книги читачеві з повною валідацією бізнес-правил
CREATE OR REPLACE PROCEDURE sp_issue_book_with_rules(
    p_reader_id INT,
    p_book_id INT,
    p_duration_days INT DEFAULT 14
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_reader_status VARCHAR(20);
    v_active_lendings_count INT;
    v_has_overdue BOOLEAN;
    v_available_copies INT;
    v_reserved_by_other BOOLEAN;
    v_new_lending_id INT;
BEGIN
    -- 1. Перевірка статусу читача
    SELECT status INTO v_reader_status
    FROM readers
    WHERE reader_id = p_reader_id;

    IF v_reader_status IS NULL THEN
        RAISE EXCEPTION 'Помилка: Читача з ID % не знайдено', p_reader_id;
    ELSIF v_reader_status != 'Active' THEN
        RAISE EXCEPTION 'Помилка: Читач має статус "%" і не може брати книги', v_reader_status;
    END IF;

    -- 2. Перевірка наявності прострочених неповернутих книг
    SELECT EXISTS (
        SELECT 1
        FROM lendings
        WHERE reader_id = p_reader_id
          AND return_date IS NULL
          AND due_date < CURRENT_DATE
    ) INTO v_has_overdue;

    IF v_has_overdue THEN
        -- Автоматичне накладання санкцій (блокування читача за заборгованість)
        UPDATE readers SET status = 'Blocked' WHERE reader_id = p_reader_id;
        RAISE EXCEPTION 'Помилка: Читач має прострочені книги! Картку автоматично заблоковано';
    END IF;

    -- 3. Перевірка ліміту активних книг на руках (максимум 5 книг)
    SELECT COUNT(*) INTO v_active_lendings_count
    FROM lendings
    WHERE reader_id = p_reader_id
      AND return_date IS NULL;

    IF v_active_lendings_count >= 5 THEN
        RAISE EXCEPTION 'Помилка: Перевищено ліміт книг на руках (%/5)', v_active_lendings_count;
    END IF;

    -- 4. Перевірка наявності вільних примірників з песимістичним блокуванням книги
    SELECT available_copies INTO v_available_copies
    FROM books
    WHERE book_id = p_book_id
    FOR UPDATE;

    IF v_available_copies IS NULL THEN
        RAISE EXCEPTION 'Помилка: Книгу з ID % не знайдено', p_book_id;
    ELSIF v_available_copies <= 0 THEN
        RAISE EXCEPTION 'Помилка: Жодного вільного примірника книги немає в наявності';
    END IF;

    -- 5. Перевірка пріоритету черги бронювання
    -- Якщо книга заброньована іншим користувачем, її не можна видати
    SELECT EXISTS (
        SELECT 1
        FROM reservations
        WHERE book_id = p_book_id
          AND status = 'Active'
          AND reader_id != p_reader_id
    ) INTO v_reserved_by_other;

    IF v_reserved_by_other THEN
        RAISE EXCEPTION 'Помилка: Цю книгу зарезервовано іншим читачем у черзі!';
    END IF;

    -- 6. Оформлення видачі
    INSERT INTO lendings (book_id, reader_id, lending_date, due_date)
    VALUES (p_book_id, p_reader_id, CURRENT_DATE, CURRENT_DATE + (p_duration_days || ' days')::INTERVAL)
    RETURNING lending_id INTO v_new_lending_id;

    -- 7. Списання доступного примірника
    UPDATE books
    SET available_copies = available_copies - 1
    WHERE book_id = p_book_id;

    -- 8. Якщо у самого читача було активне бронювання на цю книгу — задовольняємо його
    UPDATE reservations
    SET status = 'Fulfilled'
    WHERE book_id = p_book_id
      AND reader_id = p_reader_id
      AND status = 'Active';

    RAISE NOTICE 'Успішно видано книгу #% читачеві #% (Квитанція видачі: #%). Термін до %',
        p_book_id, p_reader_id, v_new_lending_id, CURRENT_DATE + (p_duration_days || ' days')::INTERVAL;
END;
$$;

-- Тестування процедури: успішна видача книги №2 читачеві №3
CALL sp_issue_book_with_rules(3, 2, 21);

-- Перевірка результату видачі
SELECT * FROM lendings WHERE reader_id = 3 AND book_id = 2;


-- ============================================================================
-- 4. Система прав доступу на рівні операцій модифікації (RBAC)
-- ============================================================================

-- 4.1. Створення спеціалізованих ролей безпеки
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_guest') THEN
        CREATE ROLE library_guest;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_operator') THEN
        CREATE ROLE library_operator;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_admin') THEN
        CREATE ROLE library_admin;
    END IF;
END $$;

-- 4.2. Налаштування прав для Гостя (Read-Only)
GRANT SELECT ON books, authors, categories TO library_guest;

-- 4.3. Налаштування прав для Оператора бібліотеки
-- Оператор може переглядати всі дані, оформлювати видачі та бронювання,
-- але не має права видаляти книги або авторів (заборона DELETE)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO library_operator;
GRANT INSERT, UPDATE ON lendings, reservations TO library_operator;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO library_operator;
GRANT EXECUTE ON PROCEDURE sp_issue_book_with_rules TO library_operator;
REVOKE DELETE ON books, authors, readers FROM library_operator;

-- 4.4. Налаштування прав для Адміністратора
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO library_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO library_admin;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public TO library_admin;

-- Перегляд налаштованих привілеїв ролей
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('library_guest', 'library_operator', 'library_admin')
  AND table_schema = 'public'
ORDER BY grantee, table_name;


-- ============================================================================
-- 5. Механізм автоматичного відновлення даних після збоїв (Self-Healing)
-- ============================================================================

-- 5.1. Журнал відновлення та ліквідації інцидентів цілісності
DROP TABLE IF EXISTS healing_incidents_log CASCADE;

CREATE TABLE healing_incidents_log (
    incident_id   SERIAL PRIMARY KEY,
    anomaly_type  VARCHAR(100) NOT NULL,
    entity_table  VARCHAR(50) NOT NULL,
    entity_id     INTEGER NOT NULL,
    old_value     TEXT,
    healed_value  TEXT,
    healed_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details       TEXT
);

-- 5.2. Процедура самовідновлення цілісності бібліотечної системи
CREATE OR REPLACE PROCEDURE sp_heal_library_consistency()
LANGUAGE plpgsql
AS $$
DECLARE
    v_record RECORD;
    v_actual_active_lendings INT;
    v_expected_available INT;
    v_incidents_fixed INT := 0;
BEGIN
    -- Перевірка та усунення розсинхронізації залишків доступних примірників книг
    FOR v_record IN
        SELECT book_id, title, total_copies, available_copies
        FROM books
        FOR UPDATE
    LOOP
        -- Підраховуємо фактичну кількість неповернутих виданих примірників
        SELECT COUNT(*) INTO v_actual_active_lendings
        FROM lendings
        WHERE book_id = v_record.book_id
          AND return_date IS NULL;

        -- Очікувана кількість = загальна кількість мінус активні видачі
        v_expected_available := v_record.total_copies - v_actual_active_lendings;

        -- Якщо виявлено аномалію — автоматично виправляємо її та записуємо в журнал
        IF v_record.available_copies != v_expected_available THEN
            UPDATE books
            SET available_copies = v_expected_available
            WHERE book_id = v_record.book_id;

            INSERT INTO healing_incidents_log (
                anomaly_type, entity_table, entity_id, old_value, healed_value, details
            ) VALUES (
                'INCORRECT_AVAILABLE_COPIES',
                'books',
                v_record.book_id,
                v_record.available_copies::TEXT,
                v_expected_available::TEXT,
                format('Виправлено розсинхронізацію примірників книги "%s". Активних видач: %s',
                       v_record.title, v_actual_active_lendings)
            );

            v_incidents_fixed := v_incidents_fixed + 1;
        END IF;
    END LOOP;

    RAISE NOTICE 'Аудит завершено. Самовідновлено аномалій: %', v_incidents_fixed;
END;
$$;

-- 5.3. Демонстрація відновлення: штучне внесення аномалії розсинхронізації
-- (симуляція втрати даних: залишок зменшено до 2 при відсутності активних видач)
UPDATE books SET available_copies = 2 WHERE book_id = 1;

-- Запуск процедури самовідновлення
CALL sp_heal_library_consistency();

-- Перегляд виправлених інцидентів
SELECT incident_id, anomaly_type, entity_table, entity_id, old_value, healed_value, details, healed_at
FROM healing_incidents_log
ORDER BY incident_id DESC;


-- ============================================================================
-- 6. Інтерфейс для перегляду та відкату змін за період (Time-Travel / Flashback)
-- ============================================================================

-- 6.1. Таблична функція Time-Travel: перегляд стану каталогу на будь-який момент часу в минулому
CREATE OR REPLACE FUNCTION fn_get_books_at_timestamp(p_target_timestamp TIMESTAMP)
RETURNS TABLE (
    book_id          INTEGER,
    isbn             VARCHAR,
    title            VARCHAR,
    author_id        INTEGER,
    total_copies     INTEGER,
    available_copies INTEGER,
    version_num      INTEGER,
    as_of_time       TIMESTAMP
)
LANGUAGE sql
AS $$
    SELECT
        h.book_id,
        h.isbn,
        h.title,
        h.author_id,
        h.total_copies,
        h.available_copies,
        h.version_num,
        p_target_timestamp AS as_of_time
    FROM books_history AS h
    WHERE h.valid_from <= p_target_timestamp
      AND (h.valid_to > p_target_timestamp OR h.valid_to IS NULL)
      AND h.change_type != 'DELETE'
    ORDER BY h.book_id;
$$;

-- 6.2. Процедура відкату стану книги до конкретної історичної версії (Point-in-Time Flashback Revert)
CREATE OR REPLACE PROCEDURE sp_revert_book_to_version(
    p_book_id INT,
    p_target_version INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_history_row RECORD;
BEGIN
    -- Знаходимо знімок книги за вказаною версією
    SELECT * INTO v_history_row
    FROM books_history
    WHERE book_id = p_book_id
      AND version_num = p_target_version;

    IF v_history_row IS NULL THEN
        RAISE EXCEPTION 'Помилка: Версію #% для книги #% не знайдено в історії!', p_target_version, p_book_id;
    END IF;

    -- Відновлюємо поля в основній таблиці books
    -- (тригер trg_books_versioning автоматично згенерує нову версію з типом 'REVERT')
    UPDATE books
    SET title            = v_history_row.title,
        publication_year = v_history_row.publication_year,
        genre            = v_history_row.genre,
        total_copies     = v_history_row.total_copies,
        available_copies = v_history_row.available_copies
    WHERE book_id = p_book_id;

    -- Фіксація типу відкату в останній версії
    UPDATE books_history
    SET change_type = 'REVERT'
    WHERE book_id = p_book_id
      AND is_current = TRUE;

    RAISE NOTICE 'Книгу #% ("%") успішно відкочено до версії #%',
        p_book_id, v_history_row.title, p_target_version;
END;
$$;

-- 6.3. Демонстрація відкату:
-- Відкочуємо книгу №1 назад до початкової версії №1 (до ювілейних перейменувань)
CALL sp_revert_book_to_version(1, 1);

-- Перевірка відновленого стану книги
SELECT book_id, title, total_copies, available_copies
FROM books
WHERE book_id = 1;

-- Перегляд створеного запису відкату в історії
SELECT book_id, version_num, title, total_copies, change_type, valid_from
FROM books_history
WHERE book_id = 1
ORDER BY version_num DESC
LIMIT 3;
