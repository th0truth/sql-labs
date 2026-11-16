-- ============================================================================
-- Лабораторна робота №5: Скрипт 09: Процедура автоматизованого обслуговування та моніторинг
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- ----------------------------------------------------------------------------
-- 1. Збережена процедура для регламентного обслуговування СУБД (Рівень 3)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE lab05.maintain_database()
LANGUAGE plpgsql
AS $$
DECLARE
    tbl RECORD;
    reindex_count INTEGER := 0;
    start_ts TIMESTAMPTZ := clock_timestamp();
    duration INTERVAL;
BEGIN
    RAISE NOTICE '🔧 Початок регламентного обслуговування схеми lab05...';

    -- 1. Оновлення статистики планувальника запитів для схеми lab05
    ANALYZE lab05.genres;
    ANALYZE lab05.authors;
    ANALYZE lab05.books;
    ANALYZE lab05.customers;
    ANALYZE lab05.orders;
    ANALYZE lab05.order_items;
    RAISE NOTICE '✅ Системну статистику оптимізатора успішно оновлено.';

    -- 2. Динамічна перебудова індексів (REINDEX TABLE) для усунення bloat та фрагментації
    FOR tbl IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'lab05'
        ORDER BY tablename
    LOOP
        EXECUTE format('REINDEX TABLE lab05.%I;', tbl.tablename);
        reindex_count := reindex_count + 1;
        RAISE NOTICE '  -> Перебудовано індекси таблиці lab05.%', tbl.tablename;
    END LOOP;

    duration := clock_timestamp() - start_ts;

    -- 3. Фіксація виконання в системному журналі обслуговування
    INSERT INTO lab05.maintenance_log (operation, executed_at, status)
    VALUES (
        format('ANALYZE + REINDEX (%s таблиць за %s)', reindex_count, duration),
        NOW(),
        'SUCCESS'
    );

    RAISE NOTICE '🎉 Обслуговування успішно завершено! Перебудовано % таблиць за %.', reindex_count, duration;
END;
$$;

-- Виклик процедури регламентного обслуговування
CALL lab05.maintain_database();

-- Перевірка запису в журналі обслуговування
SELECT * FROM lab05.maintenance_log ORDER BY log_id DESC LIMIT 3;


-- ----------------------------------------------------------------------------
-- 2. Скрипти автоматизованого моніторингу продуктивності (Рівень 3)
-- ----------------------------------------------------------------------------

-- Моніторинг 1: Аналіз використання індексів (пошук невикористовуваних або низькоефективних індексів)
\echo '=== МОНІТОРИНГ: АНАЛІЗ ВИКОРИСТАННЯ ІНДЕКСІВ (pg_stat_user_indexes) ==='
SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS scan_count,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    CASE 
        WHEN idx_scan = 0 THEN '⚠️ КАНДИДАТ НА ВИДАЛЕННЯ (0 сканувань)'
        WHEN idx_scan < 10 THEN 'ℹ️ Рідко використовується'
        ELSE '✅ Активний індекс'
    END AS recommendation
FROM pg_stat_user_indexes
WHERE schemaname = 'lab05'
ORDER BY idx_scan ASC, pg_relation_size(indexrelid) DESC;


-- Моніторинг 2: Топ найповільніших запитів через розширення pg_stat_statements
\echo '=== МОНІТОРИНГ: ТОП-5 НАЙПОВІЛЬНІШИХ ЗАПИТІВ (pg_stat_statements) ==='
SELECT
    LEFT(query, 80) AS query_preview,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    ROUND(mean_exec_time::numeric, 2) AS avg_ms,
    ROUND(max_exec_time::numeric, 2) AS max_ms,
    rows AS total_rows
FROM pg_stat_statements
WHERE query ILIKE '%lab05%'
ORDER BY mean_exec_time DESC
LIMIT 5;
