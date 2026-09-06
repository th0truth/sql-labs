# SQL Laboratory Works (sql-labs)

Репозиторій лабораторних робіт із реляційних баз даних та PostgreSQL.

## 📊 Огляд робіт

| Лабораторна | Тема | Статус | Каталог |
| :--- | :--- | :---: | :--- |
| **Lab 01** | Основи PostgreSQL, вибірка даних (DQL: SELECT, WHERE, ORDER BY, LIMIT) | 🟡 В процесі | [`lab01/`](./lab01/) |

---

## ☁️ Хмарна база даних (Neon PostgreSQL)

Усі лабораторні роботи виконуються на хмарній базі даних **Neon Serverless PostgreSQL**.

* **Neon Console:** [https://console.neon.tech](https://console.neon.tech)
* **Проєкт:** `patient-heart-57906540` (*Learning-Purposes*)
* **Регіон:** `aws-eu-central-1` (Frankfurt)
* **СУБД:** PostgreSQL 18

---

## 🚀 Швидкий старт та налаштування

### 1. Налаштування змінних середовища
Створіть локальний файл `.env` на основі шаблону:
```bash
cp .env.example .env
```
Вкажіть у `.env` свій рядок підключення `DATABASE_URL`. Файл `.env` додано до `.gitignore` і він не потрапляє у репозиторій.

### 2. Виконання команд через Makefile

Для зручності додано простий `Makefile`:

```bash
# Інтерактивне підключення до бази через psql
make psql

# Завантаження початкових даних (TechnoMart) для Лабораторної №1
make seed-lab01

# Запуск SQL-запитів Лабораторної №1 (Рівень 1)
make run-lab01
```

### 3. Виконання команд вручну через psql

```bash
# Завантаження схеми та даних
psql "$DATABASE_URL" -f lab01/task/technomart.sql

# Виконання запитів
psql "$DATABASE_URL" -f lab01/sql/01_level_1.sql
```

### 4. Керування гілками (Neon CLI)

```bash
# Створити ізольовану гілку БД для нової лабораторної
neon branches create --name lab01

# Переглянути список гілок
neon branches list
```
