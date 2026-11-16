-- ============================================================================
-- Лабораторна робота №5: Скрипт 08: Керування доступом, ролями та привілеями
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Рівень 1: Окремий користувач із обмеженими правами (тільки SELECT на певні таблиці)
-- ----------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_report_viewer') THEN
        CREATE USER lab05_report_viewer WITH PASSWORD 'report_pass_2026';
    END IF;
END $$;

GRANT CONNECT ON DATABASE neondb TO lab05_report_viewer;
GRANT USAGE ON SCHEMA lab05 TO lab05_report_viewer;
GRANT SELECT ON lab05.books, lab05.genres, lab05.v_customer_activity, lab05.v_genre_sales_analytics TO lab05_report_viewer;


-- ----------------------------------------------------------------------------
-- Рівень 3: Ієрархія ролей (RBAC в PostgreSQL)
-- ----------------------------------------------------------------------------

-- 1. Базова роль: Тільки читання (lab05_readonly)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_readonly') THEN
        CREATE ROLE lab05_readonly NOLOGIN;
    END IF;
END $$;

GRANT CONNECT ON DATABASE neondb TO lab05_readonly;
GRANT USAGE ON SCHEMA lab05 TO lab05_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA lab05 TO lab05_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA lab05 TO lab05_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA lab05 GRANT SELECT ON TABLES TO lab05_readonly;

-- 2. Роль модератора: Читання + Модифікація бізнес-даних (lab05_readwrite)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_readwrite') THEN
        CREATE ROLE lab05_readwrite NOLOGIN;
    END IF;
END $$;

-- Успадкування прав readonly
GRANT lab05_readonly TO lab05_readwrite;
GRANT INSERT, UPDATE, DELETE ON lab05.books, lab05.customers, lab05.orders, lab05.order_items TO lab05_readwrite;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA lab05 TO lab05_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA lab05 GRANT INSERT, UPDATE, DELETE ON TABLES TO lab05_readwrite;

-- 3. Роль адміністратора: Повні права на всі об'єкти схеми (lab05_admin)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_admin') THEN
        CREATE ROLE lab05_admin NOLOGIN;
    END IF;
END $$;

-- Успадкування прав readwrite
GRANT lab05_readwrite TO lab05_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA lab05 TO lab05_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA lab05 TO lab05_admin;
GRANT ALL PRIVILEGES ON SCHEMA lab05 TO lab05_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA lab05 GRANT ALL PRIVILEGES ON TABLES TO lab05_admin;


-- ----------------------------------------------------------------------------
-- Створення користувачів та призначення ролей
-- ----------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_viewer') THEN
        CREATE USER lab05_viewer WITH PASSWORD 'viewer_secure_pass_2026';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_moderator') THEN
        CREATE USER lab05_moderator WITH PASSWORD 'mod_secure_pass_2026';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'lab05_administrator') THEN
        CREATE USER lab05_administrator WITH PASSWORD 'admin_secure_pass_2026';
    END IF;
END $$;

GRANT lab05_readonly TO lab05_viewer;
GRANT lab05_readwrite TO lab05_moderator;
GRANT lab05_admin TO lab05_administrator;

-- Перевірка призначених ролей
SELECT
    r.rolname as role_or_user,
    r.rolcanlogin as can_login,
    ARRAY(
        SELECT b.rolname
        FROM pg_auth_members m
        JOIN pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid
    ) as member_of_roles
FROM pg_roles r
WHERE r.rolname LIKE 'lab05%'
ORDER BY r.rolcanlogin, r.rolname;
