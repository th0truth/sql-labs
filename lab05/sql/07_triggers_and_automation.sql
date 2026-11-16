-- ============================================================================
-- Лабораторна робота №5: Скрипт 07: Валідація, аудит, каскадні тригери та автооновлення MV
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- ----------------------------------------------------------------------------
-- Рівень 2: Валідаційний тригер (BEFORE INSERT OR UPDATE)
-- Перевіряє формат електронної пошти та номера телефону клієнта
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab05.fn_validate_customer()
RETURNS TRIGGER AS $$
BEGIN
    -- Перевірка валідності формату email
    IF NEW.email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Помилка валідації: некоректний формат email «%»', NEW.email
            USING ERRCODE = 'check_violation';
    END IF;

    -- Перевірка формату номера телефону (має починатися з +380)
    IF NEW.phone IS NOT NULL AND NEW.phone !~ '^\+380[0-9]{9}$' THEN
        RAISE EXCEPTION 'Помилка валідації: номер телефону «%» повинен мати формат +380XXXXXXXXX', NEW.phone
            USING ERRCODE = 'check_violation';
    END IF;

    -- Автоматичне форматування імені (видалення зайвих пробілів)
    NEW.full_name := trim(regexp_replace(NEW.full_name, '\s+', ' ', 'g'));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_customer ON lab05.customers;
CREATE TRIGGER trg_validate_customer
BEFORE INSERT OR UPDATE ON lab05.customers
FOR EACH ROW
EXECUTE FUNCTION lab05.fn_validate_customer();


-- ----------------------------------------------------------------------------
-- Рівні 1 та 2: Розширена система логування аудиту (comprehensive audit_log)
-- Логує INSERT, UPDATE, DELETE з повним дампом old_values та new_values у JSONB
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab05.fn_comprehensive_audit_log()
RETURNS TRIGGER AS $$
DECLARE
    rec_id INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        rec_id := OLD.customer_id;
        INSERT INTO lab05.audit_log (table_name, operation, record_id, old_values, new_values, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, TG_OP, rec_id, to_jsonb(OLD), NULL, current_user, NOW());
        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        rec_id := NEW.customer_id;
        INSERT INTO lab05.audit_log (table_name, operation, record_id, old_values, new_values, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, TG_OP, rec_id, to_jsonb(OLD), to_jsonb(NEW), current_user, NOW());
        RETURN NEW;

    ELSIF TG_OP = 'INSERT' THEN
        rec_id := NEW.customer_id;
        INSERT INTO lab05.audit_log (table_name, operation, record_id, old_values, new_values, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, TG_OP, rec_id, NULL, to_jsonb(NEW), current_user, NOW());
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_customer_audit ON lab05.customers;
CREATE TRIGGER trg_customer_audit
AFTER INSERT OR UPDATE OR DELETE ON lab05.customers
FOR EACH ROW
EXECUTE FUNCTION lab05.fn_comprehensive_audit_log();


-- ----------------------------------------------------------------------------
-- Рівень 3: Автоматичне оновлення матеріалізованого представлення (STATEMENT-level)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab05.fn_refresh_daily_sales()
RETURNS TRIGGER AS $$
BEGIN
    -- Конкурентне оновлення MV без блокування читання
    REFRESH MATERIALIZED VIEW CONCURRENTLY lab05.mv_daily_sales_summary;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_refresh_sales_mv ON lab05.orders;
CREATE TRIGGER trg_refresh_sales_mv
AFTER INSERT OR UPDATE OR DELETE ON lab05.orders
FOR EACH STATEMENT
EXECUTE FUNCTION lab05.fn_refresh_daily_sales();


-- ----------------------------------------------------------------------------
-- Рівень 3: Каскадні тригери бізнес-логіки між таблицями
-- 1. Контроль наявності книги на складі та автоматичне списання залишку
-- 2. Перерахунок загальної вартості замовлення
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lab05.fn_cascade_order_inventory()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INTEGER;
    book_title VARCHAR(200);
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Отримуємо поточний залишок книги
        SELECT stock_quantity, title INTO current_stock, book_title
        FROM lab05.books
        WHERE book_id = NEW.book_id
        FOR UPDATE; -- Блокування рядка від race condition

        IF current_stock < NEW.quantity THEN
            RAISE EXCEPTION 'Неможливо оформити замовлення: недостатньо книги «%» (ID=%) на складі. Залишок: %, замовлено: %',
                book_title, NEW.book_id, current_stock, NEW.quantity
                USING ERRCODE = 'check_violation';
        END IF;

        -- Каскадне списання зі складу
        UPDATE lab05.books
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE book_id = NEW.book_id;

        -- Оновлення суми замовлення
        UPDATE lab05.orders
        SET total_amount = total_amount + NEW.subtotal
        WHERE order_id = NEW.order_id;

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        -- Повернення товару на склад при видаленні позиції
        UPDATE lab05.books
        SET stock_quantity = stock_quantity + OLD.quantity
        WHERE book_id = OLD.book_id;

        -- Зменшення суми замовлення
        UPDATE lab05.orders
        SET total_amount = GREATEST(0.00, total_amount - OLD.subtotal)
        WHERE order_id = OLD.order_id;

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cascade_order_inventory ON lab05.order_items;
CREATE TRIGGER trg_cascade_order_inventory
AFTER INSERT OR DELETE ON lab05.order_items
FOR EACH ROW
EXECUTE FUNCTION lab05.fn_cascade_order_inventory();
