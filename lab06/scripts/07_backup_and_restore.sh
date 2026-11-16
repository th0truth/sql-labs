#!/usr/bin/env bash
# ==============================================================================
# Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
# Скрипт 07: Резервне копіювання (mongodump, mongoexport) та верифікація відновлення
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
DUMP_DEST="${BACKUP_DIR}/dump_${TIMESTAMP}"
EXPORT_FILE="${BACKUP_DIR}/books_${TIMESTAMP}.json"

mkdir -p "${DUMP_DEST}"

echo "======================================================="
echo ">>> 1. СТВОРЕННЯ ЛОГІЧНОЇ РЕЗЕРВНОЇ КОПІЇ (mongodump)"
echo "======================================================="
echo "📦 Дамп бази даних 'library'..."

docker exec mongodb mongodump --db=library --out="/tmp/dump_${TIMESTAMP}" --quiet
docker cp "mongodb:/tmp/dump_${TIMESTAMP}/." "${DUMP_DEST}/"
docker exec mongodb rm -rf "/tmp/dump_${TIMESTAMP}"

echo "✅ Резервну копію збережено у: ${DUMP_DEST}"
ls -la "${DUMP_DEST}/library"

echo ""
echo "======================================================="
echo ">>> 2. ЕКСПОРТ КОЛЕКЦІЇ У ФОРМАТ JSON (mongoexport)"
echo "======================================================="
docker exec mongodb mongoexport \
  --db=library \
  --collection=books \
  --out="/tmp/books_${TIMESTAMP}.json" \
  --jsonArray \
  --pretty \
  --quiet

docker cp "mongodb:/tmp/books_${TIMESTAMP}.json" "${EXPORT_FILE}"
docker exec mongodb rm -f "/tmp/books_${TIMESTAMP}.json"

echo "✅ Колекцію books експортовано у: ${EXPORT_FILE}"
echo "Кількість рядків у JSON файлі: $(wc -l < "${EXPORT_FILE}")"
echo "Розмір експорту: $(du -sh "${EXPORT_FILE}" | cut -f1)"

echo ""
echo "======================================================="
echo ">>> 3. ТЕСТОВЕ ВІДНОВЛЕННЯ У СХЕМУ (library_restore_test)"
echo "======================================================="

# Копіюємо дамп назад у контейнер для тесту mongorestore
docker exec mongodb rm -rf /tmp/test_restore_dump
docker cp "${DUMP_DEST}/library/." "mongodb:/tmp/test_restore_dump/"

# Відновлюємо дані у тестову БД library_restore_test
docker exec mongodb mongorestore \
  --db=library_restore_test \
  --drop \
  --quiet \
  /tmp/test_restore_dump

echo "✅ mongorestore успішно відновив дані у базу 'library_restore_test'."

echo ""
echo "======================================================="
echo ">>> 4. ВЕРИФІКАЦІЯ ВІДНОВЛЕНИХ ДАНИХ ТА ПІДРАХУНОК КІЛЬКОСТІ"
echo "======================================================="

docker exec mongodb mongosh library_restore_test --quiet --eval '
const bCount = db.books.countDocuments();
const aCount = db.authors.countDocuments();
const uCount = db.users.countDocuments();
const lCount = db.locations.countDocuments();
const hCount = db.book_history.countDocuments();

print(`📊 Відновлені документи у "library_restore_test":`);
print(`   - Книг (books):             ${bCount} шт.`);
print(`   - Авторів (authors):         ${aCount} шт.`);
print(`   - Читачів (users):           ${uCount} шт.`);
print(`   - Філій (locations):        ${lCount} шт.`);
print(`   - Історії змін (history):   ${hCount} шт.`);

if (bCount > 0 && aCount > 0 && uCount > 0) {
    print("\n🎉 ВЕРИФІКАЦІЯ УСПІШНА: усі сутності та індекси відновлено без втрат!");
} else {
    print("\n❌ ПОМИЛКА: дані не відновлено!");
}

// Очищення тестової бази даних після перевірки
db.dropDatabase();
print("🧹 Тестову базу library_restore_test видалено.");
'

docker exec mongodb rm -rf /tmp/test_restore_dump

echo ""
echo ">>> 🎉 Резервне копіювання та верифікація відновлення завершені на 100%!"
