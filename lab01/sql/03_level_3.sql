-- ============================================================================
-- Лабораторна робота №1: Робота з СУБД PostgreSQL та основи SQL
-- Рівень складності: Рівень 3
-- База даних: ТехноМарт (TechnoMart)
-- ============================================================================

-- ============================================================================
-- 1. Складні комбінації LIKE з логічними операторами
-- ============================================================================

-- Завдання 1.1:
-- Товари брендів Samsung або Apple, що не є чохлами.
-- Бізнес-логіка: Виділення техніки провідних виробників без супутніх дрібних аксесуарів для підрахунку продажів.
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

-- Завдання 1.2 (Самостійно, LIKE + AND/OR/NOT):
-- Пошук флагманських модифікацій техніки (Pro, Max, Plus) без аксесуарів.
-- Бізнес-логіка: Виділення пристроїв розширених модифікацій для преміального маркетингу без супутніх чохлів.
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

-- Завдання 1.3 (Самостійно, LIKE + AND/OR/NOT):
-- Співробітники керуючої та спеціалізованої ланки не з відділу продажів.
-- Бізнес-логіка: Формування списку адміністративного персоналу для проходження внутрішнього технічного аудиту.
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

-- Завдання 1.4 (Самостійно, LIKE + AND/OR/NOT):
-- Замовлення з адресною доставкою до квартир через поштових операторів.
-- Бізнес-логіка: Аналіз попиту на підйом великогабаритних замовлень на поверх кур'єрами в житлових будинках.
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

-- Завдання 1.5 (Самостійно, LIKE + AND/OR/NOT):
-- Клієнти з номерами оператора Vodafone та альтернативними поштовими доменами.
-- Бізнес-логіка: Сегментація бази для запуску таргетованої SMS-кампанії без дублювання в промо-каналах Gmail.
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

-- ============================================================================
-- 2. Вкладені логічні умови
-- ============================================================================

-- Завдання 2.1:
-- Товари дорожчі за 20000 грн категорій 1 і 2 або дешевші за 5000 грн.
-- Бізнес-логіка: Формування асортиментної вибірки преміальної електроніки та товарів першої ціни для контрастної вітрини.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price
FROM products AS p
WHERE (p.unit_price > 20000
    AND p.category_id IN (1, 2))
    OR (p.unit_price < 5000);

-- Завдання 2.2 (Самостійно, Вкладені умови):
-- Відбір проблемних або термінових замовлень для диспетчера.
-- Бізнес-логіка: Контроль замовлень, які зависли в очікуванні, або дорогих відправлень в обробці з підвищеною вартістю доставки.
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

-- Завдання 2.3 (Самостійно, Вкладені умови):
-- Пріоритетні категорії клієнтів для комерційного відділу.
-- Бізнес-логіка: Формування комбінованого списку B2B-компаній у бізнес-центрах та активних приватних клієнтів західного регіону.
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

-- Завдання 2.4 (Самостійно, Вкладені умови):
-- Аналіз критичних складських залишків та високовартісних поставок.
-- Бізнес-логіка: Виявлення товарів, запаси яких наближаються до нуля, або преміальної техніки, що вже прямує від постачальників.
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

-- ============================================================================
-- 3. Комплексні аналітичні запити
-- ============================================================================

-- Завдання 3.1 (Самостійно, 5+ умов фільтрації):
-- Звіт товарів активного поповнюваного асортименту середньо-високого класу.
-- Бізнес-логіка: Багатофакторний аудит ходової електроніки в наявності для планування безперервного ланцюга постачання.
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

-- Завдання 3.2 (Самостійно, Множинні критерії клієнтської бази):
-- Аналіз надійних корпоративних клієнтів у ключових бізнес-регіонах.
-- Бізнес-логіка: Формування перевіреної B2B-бази з реальними офісами та контактами для укладання рамкових договорів поставок.
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

-- ============================================================================
-- 4. Дослідження даних та пошук закономірностей
-- ============================================================================

-- Завдання 4.1 (Самостійно, Цінові сегменти - Бюджетний):
-- Аналіз бюджетних товарів та розрахунок вартості залишку на складі.
-- Бізнес-логіка: Оцінка капіталізації швидкообортових дрібних товарів вартістю до 5000 грн для оптимізації обігових коштів.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    (p.unit_price * p.units_in_stock) AS inventory_value
FROM products AS p
WHERE p.unit_price < 5000
ORDER BY p.unit_price;

-- Завдання 4.2 (Самостійно, Цінові сегменти - Середній клас):
-- Товари масового попиту середнього цінового сегмента від 10 000 до 30 000 грн.
-- Бізнес-логіка: Аналіз товарного ядра для споживчих акцій та партнерських програм банківської розстрочки.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    p.units_in_stock
FROM products AS p
WHERE p.unit_price
    BETWEEN 10000 AND 30000
    AND p.units_in_stock > 0
ORDER BY p.unit_price DESC;

-- Завдання 4.3 (Самостійно, Цінові сегменти - Люкс):
-- Преміальна техніка вищої цінової категорії (понад 45 000 грн).
-- Бізнес-логіка: Контроль залишків високомаржинальної техніки для персональних пропозицій VIP-клієнтам та їх страхування.
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order
FROM products AS p
WHERE p.unit_price > 45000
ORDER BY p.unit_price DESC;

-- Завдання 4.4 (Самостійно, Географія - Столичний хаб):
-- Аналіз клієнтської бази міста Києва з розподілом за типами контрагентів.
-- Бізнес-логіка: Оцінка концентрації столичних клієнтів для визначення доцільності відкриття нових пунктів самовивозу.
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

-- Завдання 4.5 (Самостійно, Географія - Західний регіон):
-- Дослідження клієнтської активності у Львові.
-- Бізнес-логіка: Аналіз попиту в західному регіоні для оптимізації логістичного плеча львівського хабу.
SELECT
    c.customer_id,
    c.customer_type,
    c.contact_name,
    c.address,
    c.phone
FROM customers AS c
WHERE c.city = 'Львів'
ORDER BY c.contact_name;

-- Завдання 4.6 (Самостійно, Географія - Південно-Східні індустріальні центри):
-- Клієнти з ключових промислових та портових міст (Дніпро, Харків, Одеса).
-- Бізнес-логіка: Оцінка ринкової присутності інтернет-магазину у великих індустріальних агломераціях України.
SELECT
    c.customer_id,
    c.city,
    c.customer_type,
    c.company_name,
    c.contact_name
FROM customers AS c
WHERE c.city IN ('Дніпро', 'Харків', 'Одеса')
ORDER BY c.city, c.customer_type DESC;

-- Завдання 4.7 (Самостійно, Географія - Регіональний B2B сектор):
-- Підприємства та організації поза межами столиці.
-- Бізнес-логіка: Вивчення потенціалу розвитку дистриб'юторської B2B-мережі в регіонах без урахування київського офісу.
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

-- Завдання 4.8 (Самостійно, Часові патерни - Оперативність доставки):
-- Замовлення з швидким виконанням доставки (до 3 днів включно).
-- Бізнес-логіка: Моніторинг дотримання стандартів швидкої складської комплектації та доставки для надійних перевізників.
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

-- Завдання 4.9 (Самостійно, Часові патерни - Літній сезон):
-- Замовлення, оформлені протягом літнього торговельного періоду 2024 року.
-- Бізнес-логіка: Аналіз інтенсивності літнього попиту для корекції планів закупівель на наступні періоди.
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.freight
FROM orders AS o
WHERE o.order_date
    BETWEEN '2024-06-01' AND '2024-08-31'
ORDER BY o.order_date;

-- Завдання 4.10 (Самостійно, Часові патерни - Невідвантажені замовлення):
-- Замовлення, термін комплектації яких потребує перевірки диспетчером.
-- Бізнес-логіка: Контроль замовлень без дати фактичного відвантаження для запобігання скаргам клієнтів.
SELECT
    o.order_id,
    o.order_date,
    o.required_date,
    o.order_status,
    o.ship_city
FROM orders AS o
WHERE o.shipped_date IS NULL
ORDER BY o.order_date;

-- ============================================================================
-- 5. Креативні завдання
-- ============================================================================

-- Завдання 5.1 (Самостійно, Креативні запити - Маркетингова класифікація):
-- Автоматична категоризація товарів за ціновими класами та розрахунок вартості з ПДВ.
-- Бізнес-логіка: Автоматизоване ціноутворення та присвоєння маркетингових міток (Бюджет/Оптимум/Преміум/Люкс).
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

-- Завдання 5.2 (Самостійно, Креативні запити - Профіль співробітника):
-- Формування ділової картки співробітника з розрахунком планової винагороди.
-- Бізнес-логіка: Підготовка даних для виготовлення внутрішніх бейджів та розрахунку окладу з плановим бонусом 15%.
SELECT
    e.employee_id,
    CONCAT(e.last_name, ' ', e.first_name, ' (', e.title, ')') AS employee_badge,
    e.salary,
    ROUND(e.salary * 1.15, 2) AS projected_salary_with_bonus,
    COALESCE(e.reports_to::text, 'Керівник відсутній (Топ-менеджер)') AS manager_id
FROM employees AS e
ORDER BY e.salary DESC;

-- Завдання 5.3 (Самостійно, Креативні запити - Валідація CRM даних):
-- Аудит якості та повноти заповнення контактних реквізитів контрагентів.
-- Бізнес-логіка: Автоматичне виявлення клієнтів із підозрілими номерами телефонів або незаповненими поштовими даними.
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

-- Завдання 5.4 (Самостійно, Креативні запити - Розумне сортування вітрини):
-- Пріоритетне відображення доступних товарів із зміщенням відсутніх у кінець списку.
-- Бізнес-логіка: Підвищення конверсії вітрини магазину за рахунок показу наявних товарів перед відсутніми.
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

-- Завдання 5.5 (Самостійно, Креативні запити - Логістичний аудит):
-- Аудит вартості доставки з урахуванням податкового збору та текстовою заміною статусів.
-- Бізнес-логіка: Розрахунок повної логістичної вартості відправлень з ПДВ та наочною індикацією статусу відвантаження.
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
