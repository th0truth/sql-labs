# Лабораторна робота №1. Робота з СУБД PostgreSQL та основи SQL

- **Дисципліна:** Реляційні бази даних та SQL
- **База даних:** TechnoMart (PostgreSQL 18)
- **Хмарний провайдер:** Neon Serverless PostgreSQL
- **Рівень складності:** Рівень 1–3 (Високий рівень)

---

## Мета роботи
Опанувати практичні навички роботи з об'єктно-реляційною СУБД PostgreSQL у хмарному середовищі Neon, дослідити структуру реляційної схеми даних та засвоїти побудову запитів мовою DQL (SELECT, фільтрація WHERE, сортування ORDER BY, пагінація LIMIT/OFFSET, пошук за шаблонами LIKE/ILIKE, складна булева логіка та умовні конструкції CASE).

---

## Requirements

- **СУБД:** PostgreSQL 18+ (Neon Serverless Cloud)
- **Утиліти:** `psql` (CLI клієнт PostgreSQL), `make` (автоматизація виконання), `git`
- **Графічний клієнт:** DBeaver Community Edition
- **Конфігурація:** рядок підключення `DATABASE_URL` у файлі `.env` (з підтримкою SSL)

---

## Installation & Usage

1. **Клонування репозиторію та налаштування оточення:**
   ```bash
   git clone git@github.com:th0truth/sql-labs.git
   cd sql-labs
   cp .env.example .env
   # Вкажіть дійсний рядок підключення у .env:
   # DATABASE_URL=postgresql://user:password@ep-host.region.neon.tech/neondb?sslmode=require
   ```

2. **Ініціалізація та наповнення БД:**
   ```bash
   make seed-lab01
   ```

3. **Запуск SQL-запитів за рівнями або комплексно:**
   ```bash
   make run-lab01         # Рівень 1
   make run-lab01-level2  # Рівень 2
   make run-lab01-level3  # Рівень 3
   make run-all           # Послідовний запуск усіх рівнів
   ```

---

## Про Neon Serverless PostgreSQL

Neon — це сучасна безсерверна хмарна платформа для PostgreSQL з архітектурою відокремлення обчислювальних ресурсів (compute) від сховища (storage):
- **Copy-on-Write гілкування (Branching):** миттєве створення ізольованих копій бази даних за лічені секунди без дублювання фізичного простору дисків для тестування міграцій чи виконання завдань.
- **Автоматичне масштабування та призупинення (Scale-to-Zero):** compute-вузол автоматично переходить у сплячий режим за відсутності підключень та "прокидається" менш ніж за 500 мс при першому запиті.
- **Вимога SSL (`sslmode=require`):** безпечне шифроване з'єднання через TLS з пулом з'єднань PgBouncer.

---

## Ключові інженерні прийоми (Smart SQL Practices)

1. **Гілкування бази даних через Neon CLI для ізоляції лабораторних:**
   ```bash
   neon branches create --name lab01-feature
   ```

2. **Розумне ранжування вітрини через умовний вираз `CASE` у сортуванні:**
   ```sql
   -- Наявні товари пріоритетно виводяться першими, відсутні зміщуються в кінець
   ORDER BY 
       CASE WHEN p.units_in_stock > 0 THEN 0 ELSE 1 END,
       p.unit_price DESC;
   ```

3. **Елегантна обробка невизначених значень `NULL` через `COALESCE`:**
   ```sql
   -- Запобігання порожнім полям у звітах без ламання логіки вибірки
   COALESCE(e.reports_to::text, 'Керівник відсутній (Топ-менеджер)') AS manager_id
   ```

4. **Пріоритезація дужками для запобігання логічній помилці превалювання `AND` над `OR`:**
   ```sql
   -- Дужки гарантують правильне об'єднання міст перед перевіркою типу контрагента
   WHERE (c.city = 'Київ' OR c.city = 'Львів')
       AND c.customer_type = 'company';
   ```

5. **Математичний розрахунок коректного зміщення при пагінації:**
   ```sql
   -- OFFSET = (PageNumber - 1) * PageSize. Сторінка 3 по 10 записів:
   LIMIT 10 OFFSET 20;
   ```

---

## Рівень 1

#### 1.1.1. Всі записи з таблиці customers
```sql
SELECT
    *
FROM customers AS c;
```
Повний огляд клієнтської бази для CRM-системи та перевірки контактів.

![1-1-1](assets/1-1-1.png)

#### 1.1.2. Назви товарів та їхні ціни
```sql
SELECT
    p.product_name,
    p.unit_price
FROM products AS p;
```
Формування базового прайс-листа для сайту без технічних полів.

![1-1-2](assets/1-1-2.png)

#### 1.1.3. Контактні дані співробітників
```sql
SELECT
    e.first_name,
    e.last_name,
    e.phone,
    e.email
FROM employees AS e;
```
Створення внутрішнього довідника для оперативної комунікації між відділами.

![1-1-3](assets/1-1-3.png)

#### 1.2.1. Клієнти з міста Київ
```sql
SELECT
    *
FROM customers AS c
WHERE c.city = 'Київ';
```
Таргетинг промо-кампанії експрес-доставки для мешканців столиці.

![1-2-1](assets/1-2-1.png)

#### 1.2.2. Товари дорожчі за 25000 грн
```sql
SELECT
    p.product_name,
    p.unit_price
FROM products AS p
WHERE p.unit_price > 25000;
```
Сегментація преміальної техніки для аналізу маржинальності.

![1-2-2](assets/1-2-2.png)

#### 1.2.3. Замовлення зі статусом 'delivered'
```sql
SELECT
    *
FROM orders AS o
WHERE o.order_status = 'delivered';
```
Фіксація виконаних замовлень для розрахунку виторгу та бонусів.

![1-2-3](assets/1-2-3.png)

#### 1.2.4. Співробітники відділу продажів
```sql
SELECT
    *
FROM employees AS e
WHERE e.title ILIKE '%продаж%';
```
Визначення персоналу з продажу для розподілу плану реалізації.

![1-2-4](assets/1-2-4.png)

#### 1.3.1. Сортування товарів за зростанням ціни
```sql
SELECT
    *
FROM products AS p
ORDER BY p.unit_price;
```
Фільтр цін від дешевих до дорогих для покупців з обмеженим бюджетом.

![1-3-1](assets/1-3-1.png)

#### 1.3.2. Клієнти в алфавітному порядку за ім'ям
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.city,
    c.phone
FROM customers AS c
ORDER BY c.contact_name;
```
Алфавітне впорядкування бази для швидкого пошуку клієнта оператором.

![1-3-2](assets/1-3-2.png)

#### 1.3.3. Замовлення від найновіших до найстаріших
```sql
SELECT
    *
FROM orders AS o
ORDER BY o.order_date DESC, o.order_id DESC;
```
Хронологічний моніторинг операційної діяльності та динаміки продажів.

![1-3-3](assets/1-3-3.png)

#### 1.4.1. Перші 10 найдорожчих товарів
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price
FROM products AS p
ORDER BY p.unit_price DESC
LIMIT 10;
```
Звіт топ-10 найкоштовніших активів магазину для складського контролю.

![1-4-1](assets/1-4-1.png)

#### 1.4.2. П'ять останніх замовлень за датою
```sql
SELECT
    c.contact_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    o.order_id,
    o.order_date,
    CONCAT('м. ', o.ship_city, ', ', o.ship_address) AS full_address
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN products AS p
    ON oi.product_id = p.product_id
ORDER BY o.order_date DESC, o.order_id DESC
LIMIT 5;
```
Складський маніфест з інформацією про клієнтів, товари та адресу останніх доставок.

![1-4-2](assets/1-4-2.png)

#### 1.4.3. Перші 8 клієнтів в алфавітному порядку
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.city
FROM customers AS c
ORDER BY c.contact_name
LIMIT 8;
```
Початкова сторінка списку клієнтів для першого екрана CRM.

![1-4-3](assets/1-4-3.png)

---

## Рівень 2

#### 2.1.1. Клієнти з ім'ям на "Іван"
```sql
SELECT 
    c.customer_id,
    c.contact_name,
    c.city,
    c.phone
FROM customers AS c
WHERE c.contact_name LIKE 'Іван%';
```
Швидкий пошук клієнта менеджером підтримки за неповним іменем під час вхідного дзвінка.

![2-1-1](assets/2-1-1.png)

#### 2.1.2. Товари з "phone" або "телефон"
```sql
SELECT 
    p.product_id,
    p.product_name,
    p.unit_price
FROM products AS p
WHERE p.product_name ILIKE '%телефон%'
    OR p.product_name ILIKE '%phone%';
```
Реалізація мультиязичного пошуку мобільних телефонів у рядку пошуку інтернет-магазину.

![2-1-2](assets/2-1-2.png)

#### 2.1.3. Замовлення зі службами доставки зі словом "пошта"
```sql
SELECT
    o.order_id,
    o.ship_name,
    o.ship_via,
    o.ship_address 
FROM orders AS o
WHERE o.ship_via ILIKE '%пошта%';
```
Оцінка частки поштових перевізників у загальному логістичному потоці для отримання знижок на доставку.

![2-1-3](assets/2-1-3.png)

#### 2.1.4. Співробітники за фрагментом прізвища "nko" в email
```sql
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name, ' ', e.middle_name) AS fullname,
    e.title AS position,
    e.email
FROM employees AS e
WHERE e.email LIKE '%nko%';
```
Швидка адресація корпоративних листів співробітникам за типовим українським суфіксом прізвища.

![2-1-4](assets/2-1-4.png)

#### 2.1.5. Товари з накопичувачем 256 ГБ
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price
FROM products AS p
WHERE p.product_name LIKE '%256%';
```
Маркетинговий аналіз залишків техніки з найбільш затребуваним об'ємом сховища 256GB.

![2-1-5](assets/2-1-5.png)

#### 2.2.1. Товари від 15000 до 50000 грн
```sql
SELECT 
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price
FROM products AS p
WHERE p.unit_price > 15000
    AND p.unit_price < 50000;
```
Виділення основного середньо-високого цінового сегмента для запуску таргетованої реклами.

![2-2-1](assets/2-2-1.png)

#### 2.2.2. Юридичні особи з Києва або Львова
```sql
SELECT
    c.customer_id,
    c.company_name,
    c.contact_name,
    c.contact_title,
    c.city,
    c.email,
    c.customer_type
FROM customers AS c
WHERE (c.city = 'Київ' OR c.city = 'Львів')
    AND c.company_name IS NOT NULL
    AND c.customer_type = 'company';
```
Формування B2B-бази у ключових бізнес-хабах для пропозиції індивідуального кредитного ліміту.

![2-2-2](assets/2-2-2.png)

#### 2.2.3. Товари 128 ГБ від 13 000 до 25 000 грн
```sql
SELECT
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price,
    p.units_on_order
FROM products AS p
WHERE p.product_name LIKE '%128%'
    AND p.unit_price > 13000
    AND p.unit_price < 25000;
```
Сегментація популярних гаджетів доступного класу (128GB) для формування акційного каталогу.

![2-2-3](assets/2-2-3.png)

#### 2.2.4. Постачальники форми власності ТОВ з ненульовим виторгом
```sql
SELECT
    pss.product_id,
    pss.product_name,
    pss.category_name,
    pss.supplier_name,
    pss.unit_price,
    pss.total_revenue,
    pss.order_count
FROM product_sales_summary AS pss
WHERE pss.supplier_name LIKE '%ТОВ%'
    AND pss.total_revenue != 0;
```
Оцінка надійності та комерційної ефективності співпраці з постачальниками статусу ТОВ.

![2-2-4](assets/2-2-4.png)

#### 2.2.5. Місяці з продажами понад 10 одиниць
```sql
SELECT 
    msr.year_month,
    msr.orders_count,
    msr.unique_customers,
    msr.total_items,
    msr.total_revenue
FROM monthly_sales_report AS msr
WHERE msr.total_items > 10
ORDER BY msr.total_items DESC;
```
Виявлення пікових періодів торговельної активності для оптимізації графіку роботи складу.

![2-2-5](assets/2-2-5.png)

#### 2.2.6. Продуктивність київських працівників
```sql
SELECT 
    ep.employee_id,
    ep.full_name,
    ep.title AS job_position,
    ep.city
FROM employee_performance AS ep
WHERE ep.city = 'Київ';
```
Аналіз ефективності персоналу центрального офісу в Києві для розподілу бонусного фонду.

![2-2-6](assets/2-2-6.png)

#### 2.3.1. Клієнти з міст Київ, Харків, Одеса, Дніпро
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.company_name,
    c.city,
    c.phone,
    c.customer_type
FROM customers AS c
WHERE c.city IN ('Київ', 'Харків', 'Одеса', 'Дніпро');
```
Фокусування маркетингу на містах-мільйонниках України з найбільшою платоспроможністю населення.

![2-3-1](assets/2-3-1.png)

#### 2.3.2. Товари в діапазоні від 10000 до 30000 грн
```sql
SELECT
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price
FROM products AS p
WHERE p.unit_price BETWEEN 10000 AND 30000;
```
Формування переліку техніки для запуску партнерської банківської розстрочки "Оплата частинами".

![2-3-2](assets/2-3-2.png)

#### 2.3.3. Замовлення на комплектації або в очікуванні
```sql
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.ship_city,
    o.ship_via
FROM orders AS o
WHERE o.order_status IN ('pending', 'processing')
ORDER BY o.order_date;
```
Формування активної черги пакування замовлень зі статусами 'pending' та 'processing' для складу.

![2-3-3](assets/2-3-3.png)

#### 2.3.4. Товари поза категоріями 1 та 2
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.category_id NOT IN (1, 2)
ORDER BY p.category_id, p.unit_price DESC;
```
Складання товарного асортименту для окремої промо-акції побутової та аудіотехніки.

![2-3-4](assets/2-3-4.png)

#### 2.3.5. Замовлення за другий квартал 2024 року
```sql
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
WHERE o.order_date BETWEEN '2024-04-01' AND '2024-06-30'
ORDER BY o.order_date;
```
Отримання вибірки замовлень з квітня по червень 2024 року для складання квартального фінансового звіту.

![2-3-5](assets/2-3-5.png)

#### 2.3.6. Співробітники з окладом від 25 000 до 35 000 грн
```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    e.salary
FROM employees AS e
WHERE e.salary BETWEEN 25000 AND 35000
ORDER BY e.salary DESC;
```
Аналіз фонду оплати праці фахівців із окладом від 25 000 до 35 000 грн для перегляду тарифної сітки.

![2-3-6](assets/2-3-6.png)

#### 2.3.7. Невідвантажені замовлення
```sql
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.required_date,
    o.order_status,
    o.ship_city
FROM orders AS o
WHERE o.shipped_date IS NULL
ORDER BY o.order_date;
```
Щоденний диспетчерський контроль невідвантажених посилок для уникнення зриву термінів доставки.

![2-3-7](assets/2-3-7.png)

#### 2.3.8. Клієнти із зазначеною посадою представника
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.contact_title AS job_position,
    c.city,
    CONCAT('м. ', c.city, ', ', c.address) AS full_address
FROM customers AS c
WHERE c.contact_title IS NOT NULL
ORDER BY c.city, c.contact_name;
```
Формування верифікованої контактної бази представників юридичних осіб для персоналізованих B2B пропозицій.

![2-3-8](assets/2-3-8.png)

#### 2.4.1. Активні товари топових брендів у наявності
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE (p.product_name ILIKE '%Apple%' OR p.product_name ILIKE '%Samsung%')
    AND p.units_in_stock > 0
    AND p.discontinued = false
ORDER BY p.unit_price DESC;
```
Промо-кампанія наявних на складі товарів брендів Apple і Samsung, які не зняті з виробництва.

![2-4-1](assets/2-4-1.png)

#### 2.4.2. Товари середнього цінового сегмента пріоритетних категорій
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.unit_price BETWEEN 15000 AND 35000
    AND p.category_id IN (1, 2, 3)
ORDER BY p.category_id, p.unit_price DESC;
```
Аналіз товарів вартістю від 15 000 до 35 000 грн для смартфонів, ноутбуків та телевізорів.

![2-4-2](assets/2-4-2.png)

#### 2.4.3. Фізичні особи з поштовими скриньками Gmail та Ukr.net
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.city,
    c.email
FROM customers AS c
WHERE c.company_name IS NULL
    AND (c.email LIKE '%@gmail.com' OR c.email LIKE '%@ukr.net')
ORDER BY c.city, c.contact_name;
```
Сегментація приватних клієнтів для запуску цільової email-розсилки на сервісах Gmail та UKR.NET.

![2-4-3](assets/2-4-3.png)

#### 2.4.4. Замовлення у великі міста з граничною вартістю доставки
```sql
SELECT
    o.order_id,
    o.ship_city,
    o.ship_via,
    o.freight,
    o.order_status
FROM orders AS o
WHERE o.ship_city IN ('Київ', 'Дніпро', 'Львів')
    AND o.freight NOT BETWEEN 100 AND 300
ORDER BY o.freight DESC;
```
Логістичний аудит нестандартних транспортних витрат (поза 100-300 грн) при доставці у великі хаби.

![2-4-4](assets/2-4-4.png)

#### 2.4.5. Керівний та фінансовий персонал із високим окладом
```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    e.salary,
    e.email
FROM employees AS e
WHERE (e.title ILIKE '%директор%' OR e.title ILIKE '%бухгалтер%')
    AND e.salary > 30000
    AND e.email IS NOT NULL
ORDER BY e.salary DESC;
```
Перевірка коректності внесених корпоративних контактів для менеджменту з окладом понад 30 000 грн.

![2-4-5](assets/2-4-5.png)

#### 2.5.1. Каталог товарів за категорією та ціною
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
ORDER BY p.category_id, p.unit_price DESC;
```
Впорядкування вітрини за розділами з відображенням найдорожчих моделей на початку списку.

![2-5-1](assets/2-5-1.png)

#### 2.5.2. Реєстр клієнтів за містом, типом та контактною особою
```sql
SELECT
    c.customer_id,
    c.city,
    c.customer_type,
    c.company_name,
    c.contact_name,
    c.phone
FROM customers AS c
ORDER BY c.city, c.customer_type DESC, c.contact_name;
```
Структурування бази для комерційного відділу з наданням пріоритету корпоративним клієнтам (B2B).

![2-5-2](assets/2-5-2.png)

#### 2.5.3. Моніторинг замовлень за статусом виконання та датою
```sql
SELECT
    o.order_id,
    o.order_status,
    o.order_date,
    o.customer_id,
    o.ship_city,
    o.freight
FROM orders AS o
ORDER BY o.order_status, o.order_date DESC, o.order_id DESC;
```
Диспетчерський контроль замовлень за стадією обробки та хронологією їх створення.

![2-5-3](assets/2-5-3.png)

#### 2.5.4. Друга сторінка каталогу товарів (LIMIT 5 OFFSET 5)
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
ORDER BY p.unit_price DESC, p.product_id
LIMIT 5 OFFSET 5;
```
Веб-пагінація каталогу при перегляді наступної порції товарів покупцем на сайті.

![2-5-4](assets/2-5-4.png)

#### 2.5.5. Третя сторінка журналу замовлень (LIMIT 10 OFFSET 20)
```sql
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
ORDER BY o.order_date DESC, o.order_id DESC
LIMIT 10 OFFSET 20;
```
Посторінкова навігація в системі адміністратора при аудиті історії замовлень.

![2-5-5](assets/2-5-5.png)

---

## Рівень 3

#### 3.1.1. Товари брендів Samsung або Apple без чохлів
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.quantity_per_unit,
    p.unit_price,
    p.description
FROM products AS p
WHERE (p.product_name ILIKE '%samsung%'
    OR p.product_name ILIKE '%apple%')
    AND p.product_name NOT ILIKE '%чохол%';
```
Виділення техніки провідних виробників без супутніх дрібних аксесуарів для підрахунку продажів.

![3-1-1](assets/3-1-1.png)

#### 3.1.2. Флагманські модифікації Pro, Max, Plus без чохлів
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE (p.product_name ILIKE '%Pro%'
    OR p.product_name ILIKE '%Max%'
    OR p.product_name ILIKE '%Plus%')
    AND p.product_name NOT ILIKE '%чохол%'
ORDER BY p.unit_price DESC;
```
Виділення пристроїв розширених модифікацій для преміального маркетингу без супутніх чохлів.

![3-1-2](assets/3-1-2.png)

#### 3.1.3. Керуючий персонал не з відділу продажів
```sql
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS fullname,
    e.title AS job_position,
    e.email
FROM employees AS e
WHERE (e.title ILIKE '%менеджер%'
    OR e.title ILIKE '%спеціаліст%')
    AND e.title NOT ILIKE '%продаж%'
ORDER BY e.employee_id;
```
Формування списку адміністративного персоналу для проходження внутрішнього технічного аудиту.

![3-1-3](assets/3-1-3.png)

#### 3.1.4. Замовлення з доставкою до квартир через поштових операторів
```sql
SELECT
    o.order_id,
    o.ship_name,
    o.ship_via,
    o.ship_city,
    o.ship_address
FROM orders AS o
WHERE (o.ship_via ILIKE '%Нова Пошта%'
    OR o.ship_via ILIKE '%Делівері%')
    AND o.ship_address ILIKE '%кв.%'
    AND o.ship_address NOT ILIKE '%пр.%'
ORDER BY o.order_id DESC;
```
Аналіз попиту на підйом великогабаритних замовлень на поверх кур'єрами в житлових будинках.

![3-1-4](assets/3-1-4.png)

#### 3.1.5. Клієнти Vodafone без пошти Gmail
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.phone,
    c.email,
    c.city
FROM customers AS c
WHERE (c.phone LIKE '+38050%'
    OR c.phone LIKE '+38066%')
    AND c.email NOT LIKE '%@gmail.com'
ORDER BY c.customer_id;
```
Сегментація бази для запуску таргетованої SMS-кампанії без дублювання в промо-каналах Gmail.

![3-1-5](assets/3-1-5.png)

#### 3.2.1. Товари дорожчі за 20000 грн (кат. 1, 2) або дешевші за 5000 грн
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price
FROM products AS p
WHERE (p.unit_price > 20000
    AND p.category_id IN (1, 2))
    OR (p.unit_price < 5000);
```
Формування асортиментної вибірки преміальної електроніки та товарів першої ціни для контрастної вітрини.

![3-2-1](assets/3-2-1.png)

#### 3.2.2. Проблемні або термінові замовлення для диспетчера
```sql
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
WHERE (o.order_status = 'pending'
    AND o.order_date < '2024-08-15')
    OR (o.order_status = 'processing'
    AND o.freight > 300)
ORDER BY o.order_date;
```
Контроль замовлень, які зависли в очікуванні, або дорогих відправлень в обробці з підвищеною вартістю доставки.

![3-2-2](assets/3-2-2.png)

#### 3.2.3. Пріоритетні категорії клієнтів для комерційного відділу
```sql
SELECT
    c.customer_id,
    c.customer_type,
    c.company_name,
    c.contact_name,
    c.city,
    c.email
FROM customers AS c
WHERE (c.customer_type = 'company'
    AND c.city IN ('Київ', 'Дніпро'))
    OR (c.customer_type = 'individual'
    AND c.city = 'Львів'
    AND c.email LIKE '%@gmail.com')
ORDER BY c.city, c.customer_type DESC;
```
Формування комбінованого списку B2B-компаній у бізнес-центрах та активних приватних клієнтів західного регіону.

![3-2-3](assets/3-2-3.png)

#### 3.2.4. Критичні складські залишки та високовартісні поставки
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    p.reorder_level,
    p.units_on_order
FROM products AS p
WHERE (p.units_in_stock <= p.reorder_level
    AND p.discontinued = false)
    OR (p.unit_price > 40000
    AND p.units_on_order > 0)
ORDER BY p.unit_price DESC;
```
Виявлення товарів, запаси яких наближаються до нуля, або преміальної техніки, що вже прямує від постачальників.

![3-2-4](assets/3-2-4.png)

#### 3.3.1. Звіт активного асортименту з 6 умовами фільтрації
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock,
    p.reorder_level
FROM products AS p
WHERE p.unit_price BETWEEN 10000 AND 50000
    AND p.category_id IN (1, 2, 3)
    AND p.units_in_stock > 5
    AND p.discontinued = false
    AND p.reorder_level >= 2
    AND p.product_name NOT ILIKE '%чохол%'
ORDER BY p.unit_price DESC;
```
Багатофакторний аудит ходової електроніки в наявності для планування безперервного ланцюга постачання.

![3-3-1](assets/3-3-1.png)

#### 3.3.2. Надійні корпоративні клієнти у ключових бізнес-регіонах
```sql
SELECT
    c.customer_id,
    c.company_name,
    c.contact_name,
    c.city,
    c.phone,
    c.email
FROM customers AS c
WHERE c.customer_type = 'company'
    AND c.city IN ('Київ', 'Дніпро', 'Харків')
    AND c.phone LIKE '+380%'
    AND c.email IS NOT NULL
    AND c.contact_title IS NOT NULL
    AND c.address NOT ILIKE '%а/с%'
ORDER BY c.city, c.contact_name;
```
Формування перевіреної B2B-бази з реальними офісами та контактами для укладання рамкових договорів поставок.

![3-3-2](assets/3-3-2.png)

#### 3.4.1. Бюджетні товари та вартість залишку на складі
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    (p.unit_price * p.units_in_stock) AS inventory_value
FROM products AS p
WHERE p.unit_price < 5000
ORDER BY p.unit_price;
```
Оцінка капіталізації швидкообортових дрібних товарів вартістю до 5000 грн для оптимізації обігових коштів.

![3-4-1](assets/3-4-1.png)

#### 3.4.2. Товари середнього цінового сегмента від 10 000 до 30 000 грн
```sql
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.unit_price BETWEEN 10000 AND 30000
    AND p.units_in_stock > 0
ORDER BY p.unit_price DESC;
```
Аналіз товарного ядра для споживчих акцій та партнерських програм банківської розстрочки.

![3-4-2](assets/3-4-2.png)

#### 3.4.3. Преміальна техніка понад 45 000 грн
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order
FROM products AS p
WHERE p.unit_price > 45000
ORDER BY p.unit_price DESC;
```
Контроль залишків високомаржинальної техніки для персональних пропозицій VIP-клієнтам та їх страхування.

![3-4-3](assets/3-4-3.png)

#### 3.4.4. Клієнтська база Києва з розподілом за типами контрагентів
```sql
SELECT
    c.customer_id,
    c.customer_type,
    c.company_name,
    c.contact_name,
    c.address,
    c.phone
FROM customers AS c
WHERE c.city = 'Київ'
ORDER BY c.customer_type DESC, c.contact_name;
```
Оцінка концентрації столичних клієнтів для визначення доцільності відкриття нових пунктів самовивозу.

![3-4-4](assets/3-4-4.png)

#### 3.4.5. Клієнтська активність у Львові
```sql
SELECT
    c.customer_id,
    c.customer_type,
    c.contact_name,
    c.address,
    c.phone
FROM customers AS c
WHERE c.city = 'Львів'
ORDER BY c.contact_name;
```
Аналіз попиту в західному регіоні для оптимізації логістичного плеча львівського хабу.

![3-4-5](assets/3-4-5.png)

#### 3.4.6. Клієнти з промислових центрів (Дніпро, Харків, Одеса)
```sql
SELECT
    c.customer_id,
    c.city,
    c.customer_type,
    c.company_name,
    c.contact_name
FROM customers AS c
WHERE c.city IN ('Дніпро', 'Харків', 'Одеса')
ORDER BY c.city, c.customer_type DESC;
```
Оцінка ринкової присутності інтернет-магазину у великих індустріальних агломераціях України.

![3-4-6](assets/3-4-6.png)

#### 3.4.7. Підприємства та організації поза межами столиці
```sql
SELECT
    c.customer_id,
    c.city,
    c.company_name,
    c.contact_name,
    c.contact_title,
    c.phone
FROM customers AS c
WHERE c.customer_type = 'company'
    AND c.city != 'Київ'
ORDER BY c.city, c.company_name;
```
Вивчення потенціалу розвитку дистриб'юторської B2B-мережі в регіонах без урахування київського офісу.

![3-4-7](assets/3-4-7.png)

#### 3.4.8. Замовлення з швидкою доставкою до 3 днів
```sql
SELECT
    o.order_id,
    o.order_date,
    o.shipped_date,
    (o.shipped_date - o.order_date) AS delivery_days,
    o.ship_via,
    o.ship_city
FROM orders AS o
WHERE o.shipped_date IS NOT NULL
    AND (o.shipped_date - o.order_date) <= 3
ORDER BY delivery_days, o.order_date DESC;
```
Моніторинг дотримання стандартів швидкої складської комплектації та доставки для надійних перевізників.

![3-4-8](assets/3-4-8.png)

#### 3.4.9. Замовлення літнього періоду 2024 року
```sql
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.freight
FROM orders AS o
WHERE o.order_date BETWEEN '2024-06-01' AND '2024-08-31'
ORDER BY o.order_date;
```
Аналіз інтенсивності літнього попиту для корекції планів закупівель на наступні періоди.

![3-4-9](assets/3-4-9.png)

#### 3.4.10. Невідвантажені замовлення для диспетчерського контролю
```sql
SELECT
    o.order_id,
    o.order_date,
    o.required_date,
    o.order_status,
    o.ship_city
FROM orders AS o
WHERE o.shipped_date IS NULL
ORDER BY o.order_date;
```
Контроль замовлень без дати фактичного відвантаження для запобігання скаргам клієнтів.

![3-4-10](assets/3-4-10.png)

#### 3.5.1. Автоматична категоризація за ціновими класами та ПДВ
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    ROUND(p.unit_price * 1.20, 2) AS price_with_vat,
    CASE
        WHEN p.unit_price < 5000 THEN 'Бюджетний'
        WHEN p.unit_price < 25000 THEN 'Оптимум'
        WHEN p.unit_price < 50000 THEN 'Преміум'
        ELSE 'Люкс'
    END AS price_tier
FROM products AS p
ORDER BY p.unit_price DESC;
```
Автоматизоване ціноутворення та присвоєння маркетингових міток (Бюджет/Оптимум/Преміум/Люкс).

![3-5-1](assets/3-5-1.png)

#### 3.5.2. Ділова картка співробітника та планова винагорода
```sql
SELECT
    e.employee_id,
    CONCAT(e.last_name, ' ', e.first_name, ' (', e.title, ')') AS employee_badge,
    e.salary,
    ROUND(e.salary * 1.15, 2) AS projected_salary_with_bonus,
    COALESCE(e.reports_to::text, 'Керівник відсутній (Топ-менеджер)') AS manager_id
FROM employees AS e
ORDER BY e.salary DESC;
```
Підготовка даних для виготовлення внутрішніх бейджів та розрахунку окладу з плановим бонусом 15%.

![3-5-2](assets/3-5-2.png)

#### 3.5.3. Аудит якості та повноти контактних реквізитів контрагентів
```sql
SELECT
    c.customer_id,
    c.contact_name,
    c.phone,
    c.email,
    c.postal_code,
    LENGTH(c.phone) AS phone_length
FROM customers AS c
WHERE LENGTH(c.phone) < 13
    OR c.postal_code IS NULL
    OR c.email IS NULL
ORDER BY c.customer_id;
```
Автоматичне виявлення клієнтів із підозрілими номерами телефонів або незаповненими поштовими даними.

![3-5-3](assets/3-5-3.png)

#### 3.5.4. Пріоритетне відображення доступних товарів на вітрині
```sql
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    CASE 
        WHEN p.units_in_stock > 0 THEN 'В наявності' 
        ELSE 'Під замовлення' 
    END AS stock_availability
FROM products AS p
ORDER BY 
    CASE WHEN p.units_in_stock > 0 THEN 0 ELSE 1 END,
    p.unit_price DESC;
```
Підвищення конверсії вітрини магазину за рахунок показу наявних товарів перед відсутніми.

![3-5-4](assets/3-5-4.png)

#### 3.5.5. Логістичний аудит вартості доставки з ПДВ
```sql
SELECT
    o.order_id,
    o.order_date,
    o.ship_city,
    o.ship_via,
    o.freight,
    ROUND(o.freight * 1.20, 2) AS freight_with_tax,
    COALESCE(o.shipped_date::text, 'В очікуванні відправки') AS shipment_status
FROM orders AS o
WHERE o.order_status != 'cancelled'
ORDER BY o.freight DESC, o.order_date DESC
LIMIT 10;
```
Розрахунок повної логістичної вартості відправлень з ПДВ та наочною індикацією статусу відвантаження.

![3-5-5](assets/3-5-5.png)
