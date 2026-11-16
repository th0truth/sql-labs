-- ============================================================================
-- Лабораторна робота №4: Розробка реляційної бази даних з простою інтеграцією
-- Скрипт: 04_create_triggers.sql
-- Тригери бази даних (Рівень 2: мінімум 2 тригери)
-- ============================================================================

SET search_path TO bookstore, public;

-- ----------------------------------------------------------------------------
-- Тригер 1: Аудит модифікації цін на книги (Price Audit Trigger)
-- Подія: AFTER UPDATE OF price ON books
-- Логіка: автоматично фіксує стару та нову ціну у таблицю book_price_audit,
-- якщо ціна книги зазнала змін.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_audit_book_price()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO book_price_audit (book_id, old_price, new_price, changed_by, changed_at)
        VALUES (NEW.book_id, OLD.price, NEW.price, CURRENT_USER, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_book_price ON books;
CREATE TRIGGER trg_audit_book_price
AFTER UPDATE OF price ON books
FOR EACH ROW
EXECUTE FUNCTION fn_audit_book_price();

-- ----------------------------------------------------------------------------
-- Тригер 2: Автоматичний перерахунок суми замовлення (Order Total Auto-Recalculate)
-- Подія: AFTER INSERT OR UPDATE OR DELETE ON order_items
-- Логіка: при додаванні, зміні кількості або видаленні позиції автоматично
-- перераховує orders.total_amount для відповідного замовлення з урахуванням знижки клієнта.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_recalculate_order_total()
RETURNS TRIGGER AS $$
DECLARE
    v_order_id INT;
    v_discount DECIMAL(5,2);
    v_raw_sum   DECIMAL(10,2);
BEGIN
    v_order_id := COALESCE(NEW.order_id, OLD.order_id);

    -- Отримання персональної знижки покупця
    SELECT COALESCE(c.discount_percent, 0.00) INTO v_discount
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_id = v_order_id;

    -- Обчислення чистої суми позицій
    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_raw_sum
    FROM order_items
    WHERE order_id = v_order_id;

    -- Оновлення замовлення
    UPDATE orders
    SET total_amount = ROUND(v_raw_sum * (1.0 - (COALESCE(v_discount, 0.00) / 100.0)), 2)
    WHERE order_id = v_order_id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_recalculate_order_total ON order_items;
CREATE TRIGGER trg_recalculate_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION fn_recalculate_order_total();

-- ----------------------------------------------------------------------------
-- Тригер 3: Валідація та автоматична зміна часової мітки (Timestamp & Integrity)
-- Подія: BEFORE UPDATE ON books
-- Логіка: контролює, щоб ціна та залишок не були від'ємними, й автоматично
-- оновлює стовпець updated_at.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_book_before_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.price < 0 THEN
        RAISE EXCEPTION 'Неприпустима операція: ціна книги не може бути від''ємною (%)', NEW.price;
    END IF;

    IF NEW.stock_quantity < 0 THEN
        RAISE EXCEPTION 'Неприпустима операція: залишок на складі не може бути від''ємним (%)', NEW.stock_quantity;
    END IF;

    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_book_before_update ON books;
CREATE TRIGGER trg_book_before_update
BEFORE UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION fn_book_before_update();
