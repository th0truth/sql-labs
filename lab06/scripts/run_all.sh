#!/usr/bin/env bash
# ==============================================================================
# Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
# Скрипт run_all.sh: Наскрізне виконання всіх завдань Лабораторної роботи №6 (Рівні 1-3)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================================"
echo "🚀 ЗАПУСК ПОВНОГО ЦИКЛУ ЛАБОРАТОРНОЇ РОБОТИ №6 (MongoDB, Рівень 3)"
echo "========================================================================"

# Перевірка контейнера MongoDB
if ! docker ps --format '{{.Names}}' | grep -q "^mongodb$"; then
    echo "⚠️ Контейнер mongodb не запущено. Запуск контейнера..."
    docker rm -f mongodb 2>/dev/null || true
    docker run -d --name mongodb --net=host mongo:8.0
    echo "Очікування готовності MongoDB..."
    sleep 3
fi

echo "📦 Копіювання скриптів у контейнер..."
docker exec mongodb mkdir -p /scripts
docker cp "${SCRIPT_DIR}/." mongodb:/scripts/

echo ""
echo ">>> [КРОК 1] Ініціалізація бази даних library та початкове наповнення..."
docker exec mongodb mongosh /scripts/01_seed_database.js

echo ""
echo ">>> [КРОК 2] Базові CRUD операції (Рівень 1)..."
docker exec mongodb mongosh /scripts/02_basic_crud.js

echo ""
echo ">>> [КРОК 3] Індексування та порівняльний аналіз (explain executionStats)..."
docker exec mongodb mongosh /scripts/03_indexes_and_performance.js

echo ""
echo ">>> [КРОК 4] Агрегаційні пайплайни (Рівень 2)..."
docker exec mongodb mongosh /scripts/04_aggregation_pipelines.js

echo ""
echo ">>> [КРОК 5] Об'єднання (\$lookup), представлення (view) та текстовий пошук..."
docker exec mongodb mongosh /scripts/05_lookup_and_views.js

echo ""
echo ">>> [КРОК 6] Творче розширення Рівня 3 (JSON Schema, 2dsphere, Версіонування)..."
docker exec mongodb mongosh /scripts/06_advanced_level3.js

echo ""
echo ">>> [КРОК 7] Резервне копіювання (mongodump) та тестове відновлення (mongorestore)..."
"${SCRIPT_DIR}/07_backup_and_restore.sh"

echo ""
echo "========================================================================"
echo "🎉 ВСІ ЕТАПИ ЛАБОРАТОРНОЇ РОБОТИ №6 ВИКОНАНО УСПІШНО НА 100% (РІВЕНЬ 3)!"
echo "========================================================================"
