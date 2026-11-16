#!/usr/bin/env bash
# ==============================================================================
# Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
# Скрипт run_all.sh: Наскрізне виконання всіх завдань БД Лабораторної роботи №7 (Рівні 1-3)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================================"
echo "🚀 ЗАПУСК ПОВНОГО ЦИКЛУ БД ЛАБОРАТОРНОЇ РОБОТИ №7 (MongoDB 8.0, Рівень 3)"
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
docker exec mongodb mkdir -p /lab07
docker cp "${SCRIPT_DIR}/." mongodb:/lab07/

echo ""
echo ">>> [КРОК 1] Створення колекцій з JSON Schema валідацією..."
docker exec mongodb mongosh /lab07/01_setup_schema_validation.js

echo ""
echo ">>> [КРОК 2] Створення комплексу індексів (унікальні, складені, часткові, 2dsphere)..."
docker exec mongodb mongosh /lab07/02_create_indexes.js

echo ""
echo ">>> [КРОК 3] Генерація та посів даних (20 користувачів, 10 рубрик, 50 статей, 274 коментарі)..."
docker exec mongodb mongosh /lab07/03_seed_data.js

echo ""
echo ">>> [КРОК 4] Виконання агрегаційних конвеєрів та аналітики..."
docker exec mongodb mongosh /lab07/04_aggregations.js

echo ""
echo ">>> [КРОК 5] Виконання завдань Рівня 3 (Версіонування, дерево коментарів, сповіщення, \$near)..."
docker exec mongodb mongosh /lab07/05_advanced_level3.js

echo ""
echo "========================================================================"
echo "🎉 ВСІ ЕТАПИ БАЗИ ДАНИХ ЛАБОРАТОРНОЇ РОБОТИ №7 ВИКОНАНО УСПІШНО (РІВЕНЬ 3)!"
echo "========================================================================"
