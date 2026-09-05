-- ============================================================================
-- Лабораторна робота №1: Робота з СУБД PostgreSQL та основи SQL
-- Рівень складності: Рівень 1
-- База даних: ТехноМарт (TechnoMart)
-- ============================================================================


-- ========== 1. Основні SELECT запити ==========


-- Завдання 1.1: Отримати всі записи з таблиці customers.
SELECT
    *
FROM customers AS c;

-- Завдання 1.2: Вивести тільки назви товарів і їхні ціни з таблиці products.
SELECT
    p.product_name,
    p.unit_price
FROM products AS p;

-- Завдання 1.3: Показати контактні дані всіх співробітників (ім'я, прізвище, телефон, email).
SELECT
    e.first_name,
    e.last_name,
    e.phone,
    e.email
FROM employees AS e;


-- ========== 2. Прості умови WHERE ==========


-- Завдання 2.1: Знайти всіх клієнтів з міста Київ.
SELECT
    *
FROM customers AS c
WHERE c.city = 'Київ';

-- Завдання 2.2: Вивести товари, які коштують більше 25000 грн.
SELECT
    p.product_name,
    p.unit_price
FROM products AS p
WHERE p.unit_price > 25000;

-- Завдання 2.3: Показати всі замовлення зі статусом 'delivered'.
SELECT
    *
FROM orders AS o
WHERE o.order_status = 'delivered';

-- Завдання 2.4: Знайти співробітників, які працюють у відділі продажів (посада містить слово "продаж").
SELECT
    *
FROM employees AS e
WHERE e.title ILIKE '%продаж%';


-- ========== 3. Базове сортування ORDER BY ==========


-- Завдання 3.1: Відсортувати товари за зростанням ціни.
SELECT
    *
FROM products AS p
ORDER BY p.unit_price ASC; -- Можемо опустити ASC, оскільки це значення за замовчуванням

-- Завдання 3.2: Показати клієнтів в алфавітному порядку за іменем контактної особи.
SELECT
    c.contact_name
FROM customers AS c
ORDER BY c.contact_name ASC; -- Можемо опустити ASC

-- Завдання 3.3: Вивести замовлення від найновіших до найстаріших.
-- Додаємо o.order_id DESC для детермінованого сортування при однакових датах
SELECT
    *
FROM orders AS o
ORDER BY o.order_date DESC, o.order_id DESC;


-- ========== 4. Обмеження результатів LIMIT ==========


-- Завдання 4.1: Показати перші 10 найдорожчих товарів.
SELECT
    p.product_name,
    p.unit_price
FROM products AS p
ORDER BY p.unit_price DESC
LIMIT 10;

-- Завдання 4.2: Вивести 5 останніх замовлень (за датою).
-- Основний варіант: запит до таблиці orders, що гарантує вибірку саме 5 унікальних замовлень
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.order_status,
    o.ship_city,
    o.freight
FROM orders AS o
ORDER BY o.order_date DESC, o.order_id DESC
LIMIT 5;

-- Завдання 4.2 (Бонусний розширений варіант з JOIN):
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

-- Завдання 4.3: Отримати перших 8 клієнтів в алфавітному порядку.
SELECT
    c.contact_name
FROM customers AS c
ORDER BY c.contact_name ASC
LIMIT 8;
