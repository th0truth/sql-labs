# SQL Laboratory Works (sql-labs)

Репозиторій лабораторних робіт із реляційних баз даних та PostgreSQL. Усі завдання виконуються на хмарній платформі Neon Serverless PostgreSQL з використанням DBeaver та psql CLI.

---

## Огляд робіт

| Лабораторна | Тема | Рівень | Статус | Код | Звіт |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Lab 01** | Основи PostgreSQL, вибірка даних (DQL: SELECT, WHERE, ORDER BY, LIMIT, OFFSET, LIKE, CASE) | 1–3 (Високий) | Завершено | [SQL](lab01/sql/) | [Звіт](lab01/report.md) |
| **Lab 02** | Складні SQL запити (JOIN, агрегатні функції, підзапити, віконні функції, CTE, матеріалізовані представлення) | 1–3 (Високий) | Завершено | [SQL](lab02/sql/) | [Звіт](lab02/report.md) |
| **Lab 03** | Модифікація даних та транзакції (INSERT, UPDATE, DELETE, цілісність даних, транзакції, COMMIT, ROLLBACK) | 1–3 (Високий) | Завершено | [SQL](lab03/sql/) | [Звіт](lab03/report.md) |
| **Lab 04** | Розробка реляційної БД з веб-інтеграцією (Bookstore DB, Flask, Docker, REST API, RBAC, Reports) | 1–3 (Високий) | Завершено | [SQL](lab04/database/) | [Звіт](lab04/report.md) |
| **Lab 05** | Керування БД, оптимізація продуктивності та автоматизація (EXPLAIN ANALYZE, Indexes, Triggers, Views, Roles, Backup) | 1–3 (Високий) | Завершено | [SQL](lab05/sql/) | [Звіт](lab05/report.md) |
| **Lab 06** | Робота з СУБД MongoDB та реалізація операцій (NoSQL CRUD, Aggregations, $lookup, 2dsphere, Versioning, Backup) | 1–3 (Високий) | Завершено | [Scripts](lab06/scripts/) | [Звіт](lab06/report.md) |

---

## Хмарна інфраструктура (Neon PostgreSQL)

Лабораторні роботи розгорнуті на серверлес-платформі **Neon PostgreSQL 18**:

- **Консоль управління:** [console.neon.tech](https://console.neon.tech)
- **Проєкт:** `patient-heart-57906540` (*Learning-Purposes*)
- **Регіон:** `aws-eu-central-1` (Frankfurt)
- **Архітектура:** розділення compute та storage, підтримка миттєвого Copy-on-Write гілкування (branching) для безпечного тестування міграцій без впливу на основну базу даних.

---

## Швидкий старт

### 1. Налаштування змінних середовища
Створіть локальний конфігураційний файл `.env`:
```bash
cp .env.example .env
```
Задайте дійсний рядок підключення `DATABASE_URL` із параметром `sslmode=require`.

### 2. Керування через Makefile
Автоматизація виконання та тестування запитів:

```bash
# Довідка за всіма доступними командами
make help

# Інтерактивне підключення до бази через psql CLI
make psql

# Завантаження початкової схеми та даних TechnoMart
make seed-lab01

# Запуск запитів за рівнями складності
make run-lab01          # Рівень 1
make run-lab01-level2   # Рівень 2
make run-lab01-level3   # Рівень 3

# Послідовне виконання всіх рівнів лабораторної
make run-all
```

### 3. Робота з гілками через Neon CLI
```bash
# Створення нової ізольованої гілки для експериментів
neon branches create --name lab01-dev

# Перегляд переліку активних гілок
neon branches list
```

---

## Структура репозиторію

```text
sql-labs/
├── Makefile                # Автоматизація збірки та запусків
├── README.md               # Документація репозиторію
├── lab01/                  # Лабораторна робота №1
│   ├── report.md           # Підсумковий звіт із поясненнями та скріншотами
│   ├── assets/             # 68 знімків виконання запитів (Рівні 1–3)
│   ├── sql/                # SQL-скрипти з коментарями бізнес-логіки
│   │   ├── 01_level_1.sql  # Рівень 1 (13 запитів)
│   │   ├── 02_level_2.sql  # Рівень 2 (29 запитів)
│   │   └── 03_level_3.sql  # Рівень 3 (26 запитів)
│   └── task/               # Методичні матеріали
│       ├── lab-01.md       # Завдання та вимоги
│       └── technomart.sql  # DDL та DML схеми TechnoMart
└── lab02/                  # Лабораторна робота №2 (використовує БД TechnoMart з ЛР1)
    ├── report.md           # Підсумковий звіт із поясненнями та скріншотами
    ├── assets/             # 25 знімків виконання запитів (Рівні 1–3)
    ├── sql/                # SQL-скрипти (JOIN, агрегати, підзапити, віконні функції, CTE)
    │   ├── 01_level_1.sql  # Рівень 1
    │   ├── 02_level_2.sql  # Рівень 2
    │   └── 03_level_3.sql  # Рівень 3
    └── task/               # Методичні матеріали
        └── lab-02.md       # Завдання та вимоги
└── lab03/                  # Лабораторна робота №3 (БД Library Management)
    ├── report.md           # Підсумковий звіт із поясненнями та скріншотами
    ├── assets/             # 42 знімки виконання запитів (Рівні 1–3)
    ├── sql/                # SQL-скрипти модифікації даних та транзакцій
    │   ├── 01_level_1.sql  # Рівень 1
    │   ├── 02_level_2.sql  # Рівень 2
    │   └── 03_level_3.sql  # Рівень 3
    └── task/               # Методичні матеріали
        └── lab-03.md       # Завдання та вимоги
└── lab04/                  # Лабораторна робота №4 (БД Bookstore + Flask Web + CLI)
    ├── report.md           # Підсумковий звіт із поясненнями та скріншотами
    ├── docker-compose.yaml # Контейнеризація PostgreSQL 17 + pgAdmin + Web
    ├── database/           # DDL, тестові дані, процедури, тригери, представлення
    ├── console_app/        # Консольний застосунок CRUD (Python CLI)
    ├── web_app/            # Повноцінний Flask вебзастосунок (RBAC, API, PDF, Charts)
    ├── docs/               # Концептуальна ERD та опис 3НФ
    └── task/               # Методичні матеріали
        └── lab-04.md       # Завдання та вимоги
└── lab05/                  # Лабораторна робота №5 (Оптимізація продуктивності та DBA)
    ├── report.md           # Підсумковий звіт (порівняння EXPLAIN, запитання)
    ├── sql/                # SQL-скрипти оптимізації (01–10)
    │   ├── 01_create_schema.sql             # DDL схеми lab05
    │   ├── 02_seed_large_dataset.sql        # Навантажувальний датасет (205k+ записів)
    │   ├── 03_explain_before.sql            # EXPLAIN ANALYZE до оптимізації
    │   ├── 04_create_indexes.sql            # B-Tree та часткові індекси
    │   ├── 05_explain_after.sql             # EXPLAIN ANALYZE після оптимізації
    │   ├── 06_views_and_rules.sql           # VIEW, RULES, MATERIALIZED VIEW
    │   ├── 07_triggers_and_automation.sql   # Валідація, аудит, каскадні тригери
    │   ├── 08_roles_and_permissions.sql     # Ієрархія ролей (RBAC)
    │   ├── 09_maintenance_and_monitoring.sql# Обслуговування СУБД та моніторинг
    │   └── 10_backup_restore.sh             # Резервне копіювання та відновлення
    └── task/               # Методичні матеріали
        └── lab-05.md       # Завдання та вимоги
└── lab06/                  # Лабораторна робота №6 (NoSQL СУБД MongoDB)
    ├── report.md           # Підсумковий звіт (порівняння NoSQL vs SQL, запитання)
    ├── report.pdf          # Експортований друкований PDF-звіт
    ├── scripts/            # Скрипти MongoDB (01–07, run_all.sh)
    │   ├── 01_seed_database.js              # Ініціалізація та наповнення (books, authors, users, locations)
    │   ├── 02_basic_crud.js                 # CRUD операції (insertOne/Many, find, update, replace, delete)
    │   ├── 03_indexes_and_performance.js    # B-Tree, складені та унікальні індекси, explain executionStats
    │   ├── 04_aggregation_pipelines.js      # Конвеєри ($unwind, $group, $project, $avg, $sum)
    │   ├── 05_lookup_and_views.js           # З'єднання $lookup, представлення (view), текстовий пошук $text
    │   ├── 06_advanced_level3.js            # JSON Schema, 2dsphere геопошук, версіонування документів
    │   ├── 07_backup_and_restore.sh         # mongodump, mongoexport, тестове відновлення mongorestore
    │   └── run_all.sh                       # Автоматизований наскрізний запуск усього конвеєра
    ├── backups/            # Логічні дампи BSON та JSON
    └── task/               # Методичні матеріали
        └── lab-06.md       # Завдання та вимоги
```
