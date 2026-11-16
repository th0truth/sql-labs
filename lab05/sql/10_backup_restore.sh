#!/usr/bin/env bash
# ============================================================================
# Лабораторна робота №5: Скрипт 10: Резервне копіювання та тестування відновлення
# Студент: Панасюк Владислав Васильович, група ІПЗ-32
# ============================================================================

set -euo pipefail

# 1. Завантаження змінних середовища
ENV_FILE="$(dirname "$0")/../../.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi

if [ -z "${DATABASE_URL:-}" ]; then
    echo "❌ Помилка: DATABASE_URL не встановлено в .env"
    exit 1
fi

BACKUP_DIR="$(dirname "$0")/../backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DUMP_FILE="$BACKUP_DIR/lab05_backup_${TIMESTAMP}.dump"
SQL_FILE="$BACKUP_DIR/lab05_backup_${TIMESTAMP}.sql"

echo "============================================================================"
echo "📦 1. СТВОРЕННЯ РЕЗЕРВНОЇ КОПІЇ СХЕМИ lab05 (pg_dump)"
echo "============================================================================"

# Створення бінарного стисненого дампу (Custom format -F c)
echo "-> Створення стисненого дампу: $DUMP_FILE"
pg_dump "$DATABASE_URL" --schema=lab05 -F c -Z 9 -f "$DUMP_FILE"

# Створення текстового SQL-дампу (-F p)
echo "-> Створення текстового SQL-дампу: $SQL_FILE"
pg_dump "$DATABASE_URL" --schema=lab05 -F p --clean --if-exists -f "$SQL_FILE"

echo "✅ Резервні копії успішно створено:"
ls -lh "$BACKUP_DIR"/*"${TIMESTAMP}"*

echo ""
echo "============================================================================"
echo "🔄 2. ТЕСТУВАННЯ ВІДНОВЛЕННЯ ДАНИХ (pg_restore / psql)"
echo "============================================================================"

echo "-> Створення тестової схеми lab05_restore_test..."
psql "$DATABASE_URL" -c "DROP SCHEMA IF EXISTS lab05_restore_test CASCADE; CREATE SCHEMA lab05_restore_test;"

echo "-> Відновлення структури та даних у тестову схему..."
# Для відновлення з custom format у конкретну схему підміняємо lab05 на lab05_restore_test
sed "s/lab05\./lab05_restore_test\./g; s/SCHEMA lab05/SCHEMA lab05_restore_test/g" "$SQL_FILE" | psql "$DATABASE_URL" -q

echo "-> Перевірка кількості відновлених записів у lab05_restore_test:"
psql "$DATABASE_URL" -c "
SELECT 'books' as table_name, count(*) as count FROM lab05_restore_test.books
UNION ALL
SELECT 'customers', count(*) FROM lab05_restore_test.customers
UNION ALL
SELECT 'orders', count(*) FROM lab05_restore_test.orders
UNION ALL
SELECT 'order_items', count(*) FROM lab05_restore_test.order_items;
"

echo "-> Очищення тестової схеми після успішної верифікації..."
psql "$DATABASE_URL" -c "DROP SCHEMA lab05_restore_test CASCADE;"

echo "🎉 ТЕСТ РЕЗЕРВНОГО КОПІЮВАННЯ ТА ВІДНОВЛЕННЯ ПРОЙДЕНО УСПІШНО!"
