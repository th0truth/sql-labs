-- ============================================================================
-- Лабораторна робота №1: Робота з СУБД PostgreSQL та основи SQL
-- Рівень складності: Рівень 2
-- База даних: ТехноМарт (TechnoMart)
-- ============================================================================

-- ============================================================================
-- 1. Пошук за зразком з LIKE
-- ============================================================================

-- Завдання 1.1:
-- Знайти всіх клієнтів, чиї імена починаються на "Іван".
-- Бізнес-логіка: Швидкий пошук клієнта менеджером підтримки за неповним іменем під час вхідного дзвінка.
SELECT 
    c.customer_id,
    c.contact_name,
    c.city,
    c.phone
FROM customers AS c
WHERE c.contact_name LIKE 'Іван%';

-- Завдання 1.2:
-- Вивести товари, в назві яких є слово "phone" або "телефон".
-- Бізнес-логіка: Реалізація мультиязичного пошуку мобільних телефонів у пошуковому рядку інтернет-магазину.
SELECT 
    p.product_id,
    p.product_name,
    p.unit_price
FROM products AS p
WHERE p.product_name ILIKE '%телефон%'
   OR p.product_name ILIKE '%phone%'; 

-- Завдання 1.3 (Самостійно, LIKE):
-- Пошук замовлень за службами доставки, що містять слово "пошта".
-- Бізнес-логіка: Оцінка частки поштових перевізників у загальному логістичному потоці для отримання знижок на доставку.
SELECT
    o.order_id,
    o.ship_name,
    o.ship_via,
    o.ship_address 
FROM orders AS o
WHERE o.ship_via ILIKE '%пошта%';

-- Завдання 1.4 (Самостійно, LIKE):
-- Пошук співробітників за фрагментом прізвища "nko" в електронній пошті.
-- Бізнес-логіка: Швидка адресація корпоративних листів співробітникам за типовим українським суфіксом прізвища.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name, ' ', e.middle_name) AS fullname,
    e.title AS position,
    e.email
FROM employees AS e
WHERE e.email LIKE '%nko%';

-- Завдання 1.5 (Самостійно, LIKE):
-- Пошук товарів із фіксованим об'ємом накопичувача "256" ГБ.
-- Бізнес-логіка: Маркетинговий аналіз залишків техніки з найбільш затребуваним об'ємом сховища 256GB.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.product_name LIKE '%256%';


-- ============================================================================
-- 2. Логічні оператори AND, OR, NOT
-- ============================================================================

-- Завдання 2.1:
-- Знайти товари дорожчі за 15000 грн і дешевші за 50000 грн.
-- Бізнес-логіка: Виділення основного середньо-високого цінового сегмента для запуску таргетованої реклами.
SELECT 
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price
FROM products AS p
WHERE p.unit_price > 15000
  AND p.unit_price < 50000;

-- Завдання 2.2:
-- Вивести клієнтів з Києва або Львова, які є юридичними особами.
-- Бізнес-логіка: Формування B2B-бази у ключових бізнес-хабах для пропозиції індивідуального кредитного ліміту.
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

-- Завдання 2.3 (Самостійно, LIKE + AND):
-- Товари об'ємом 128 ГБ у діапазоні цін від 13 000 до 25 000 грн.
-- Бізнес-логіка: Сегментація популярних гаджетів доступного класу (128GB) для формування акційного каталогу.
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

-- Завдання 2.4 (Самостійно, LIKE + AND):
-- Постачальники форми власності ТОВ з ненульовим виторгом товарів.
-- Бізнес-логіка: Оцінка надійності та комерційної ефективності співпраці з постачальниками статусу ТОВ.
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

-- Завдання 2.5 (Самостійно, AND + ORDER BY):
-- Місяці з високою інтенсивністю продажів (більше 10 реалізованих одиниць).
-- Бізнес-логіка: Виявлення пікових періодів торговельної активності для оптимізації графіку роботи складу.
SELECT 
    msr.year_month,
    msr.orders_count,
    msr.unique_customers,
    msr.total_items,
    msr.total_revenue
FROM monthly_sales_report AS msr
WHERE msr.total_items > 10
ORDER BY msr.total_items DESC;

-- Завдання 2.6 (Самостійно, AND):
-- Оцінка продуктивності київських працівників.
-- Бізнес-логіка: Аналіз ефективності персоналу центрального офісу в Києві для розподілу бонусного фонду.
SELECT 
    ep.employee_id,
    ep.full_name,
    ep.title AS job_position,
    ep.city
FROM employee_performance AS ep
WHERE ep.city = 'Київ';


-- ============================================================================
-- 3. Оператори IN, BETWEEN, IS NULL
-- ============================================================================

-- Завдання 3.1:
-- Вивести клієнтів з міст Київ, Харків, Одеса, Дніпро.
-- Бізнес-логіка: Фокусування маркетингу на містах-мільйонниках України з найбільшою платоспроможністю населення.
SELECT
    c.customer_id,
    c.contact_name,
    c.company_name,
    c.city,
    c.phone,
    c.customer_type
FROM customers AS c
WHERE c.city IN ('Київ', 'Харків', 'Одеса', 'Дніпро');

-- Завдання 3.2:
-- Знайти товари в ціновому діапазоні від 10000 до 30000 грн.
-- Бізнес-логіка: Формування переліку техніки для запуску партнерської банківської розстрочки "Оплата частинами".
SELECT
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price
FROM products AS p
WHERE p.unit_price BETWEEN 10000 AND 30000; 

-- Завдання 3.3 (Самостійно, IN):
-- Замовлення, що очікують або проходять комплектацію на складі.
-- Бізнес-логіка: Формування активної черги пакування замовлень зі статусами 'pending' та 'processing' для складу.
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

-- Завдання 3.4 (Самостійно, NOT IN):
-- Товари, що не належать до категорій смартфонів та комп'ютерів.
-- Бізнес-логіка: Складання товарного асортименту для окремої промо-акції побутової та аудіотехніки.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.category_id NOT IN (1, 2)
ORDER BY p.category_id, p.unit_price DESC;

-- Завдання 3.5 (Самостійно, BETWEEN):
-- Замовлення за другий квартал 2024 року.
-- Бізнес-логіка: Отримання вибірки замовлень з квітня по червень 2024 року для складання квартального фінансового звіту.
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
WHERE o.order_date BETWEEN '2024-04-01' AND '2024-06-30'
ORDER BY o.order_date;

-- Завдання 3.6 (Самостійно, BETWEEN):
-- Співробітники із заробітною платою середньої ланки.
-- Бізнес-логіка: Аналіз фонду оплати праці фахівців із окладом від 25 000 до 35 000 грн для перегляду тарифної сітки.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    e.salary
FROM employees AS e
WHERE e.salary BETWEEN 25000 AND 35000
ORDER BY e.salary DESC;

-- Завдання 3.7 (Самостійно, IS NULL):
-- Замовлення, які ще не були відправлені покупцям.
-- Бізнес-логіка: Щоденний диспетчерський контроль невідвантажених посилок для уникнення зриву термінів доставки.
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

-- Завдання 3.8 (Самостійно, IS NOT NULL):
-- Клієнти із зазначеною посадою представника компанії.
-- Бізнес-логіка: Формування верифікованої контактної бази представників юридичних осіб для персоналізованих B2B пропозицій.
SELECT
    c.customer_id,
    c.contact_name,
    c.contact_title AS job_position,
    c.city,
    CONCAT('м. ', c.city, ', ', c.address) AS full_address
FROM customers AS c
WHERE c.contact_title IS NOT NULL
ORDER BY c.city, c.contact_name;


-- ============================================================================
-- 4. Комбінування умов
-- ============================================================================

-- Завдання 4.1 (Самостійно, LIKE + AND/OR + BOOLEAN):
-- Активні товари топових брендів у наявності.
-- Бізнес-логіка: Промо-кампанія наявних на складі товарів брендів Apple і Samsung, які не зняті з виробництва.
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

-- Завдання 4.2 (Самостійно, BETWEEN + IN):
-- Товари середнього цінового сегмента пріоритетних категорій.
-- Бізнес-логіка: Аналіз товарів вартістю від 15 000 до 35 000 грн для смартфонів, ноутбуків та телевізорів.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.unit_price BETWEEN 15000 AND 35000
  AND p.category_id IN (1, 2, 3)
ORDER BY p.category_id ASC, p.unit_price DESC;

-- Завдання 4.3 (Самостійно, IS NULL + LIKE + OR):
-- Фізичні особи з поштовими скриньками популярних доменів.
-- Бізнес-логіка: Сегментація приватних клієнтів для запуску цільової email-розсилки на сервісах Gmail та UKR.NET.
SELECT
    c.customer_id,
    c.contact_name,
    c.city,
    c.email
FROM customers AS c
WHERE c.company_name IS NULL
  AND (c.email LIKE '%@gmail.com' OR c.email LIKE '%@ukr.net')
ORDER BY c.city, c.contact_name;

-- Завдання 4.4 (Самостійно, NOT BETWEEN + IN):
-- Замовлення у великі міста з граничною вартістю доставки.
-- Бізнес-логіка: Логістичний аудит нестандартних транспортних витрат (поза 100-300 грн) при доставці у великі хаби.
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

-- Завдання 4.5 (Самостійно, LIKE + IS NOT NULL + AND):
-- Керівний та фінансовий персонал із високим окладом.
-- Бізнес-логіка: Перевірка коректності внесених корпоративних контактів для менеджменту з окладом понад 30 000 грн.
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


-- ============================================================================
-- 5. Складне сортування та пагінація
-- ============================================================================

-- Завдання 5.1 (Самостійно, Сортування за 2 полями):
-- Каталог товарів за категорією та ціною.
-- Бізнес-логіка: Впорядкування вітрини за розділами з відображенням найдорожчих моделей на початку списку.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
ORDER BY p.category_id ASC, p.unit_price DESC;

-- Завдання 5.2 (Самостійно, Сортування за 3 полями):
-- Реєстр клієнтів за містом, типом та контактною особою.
-- Бізнес-логіка: Структурування бази для комерційного відділу з наданням пріоритету корпоративним клієнтам (B2B).
SELECT
    c.customer_id,
    c.city,
    c.customer_type,
    c.company_name,
    c.contact_name,
    c.phone
FROM customers AS c
ORDER BY c.city ASC, c.customer_type DESC, c.contact_name ASC;

-- Завдання 5.3 (Самостійно, Сортування за 2 полями):
-- Моніторинг замовлень за статусом виконання та датою.
-- Бізнес-логіка: Диспетчерський контроль замовлень за стадією обробки та хронологією їх створення.
SELECT
    o.order_id,
    o.order_status,
    o.order_date,
    o.customer_id,
    o.ship_city,
    o.freight
FROM orders AS o
ORDER BY o.order_status ASC, o.order_date DESC, o.order_id DESC;

-- Завдання 5.4 (Самостійно, Пагінація LIMIT + OFFSET):
-- Друга сторінка каталогу товарів (по 5 товарів на сторінку).
-- Бізнес-логіка: Веб-пагінація каталогу при перегляді наступної порції товарів покупцем на сайті.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM products AS p
ORDER BY p.unit_price DESC, p.product_id ASC
LIMIT 5 OFFSET 5;

-- Завдання 5.5 (Самостійно, Пагінація LIMIT + OFFSET):
-- Третя сторінка журналу замовлень (по 10 замовлень на сторінці).
-- Бізнес-логіка: Посторінкова навігація в системі адміністратора при аудиті історії замовлень.
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
