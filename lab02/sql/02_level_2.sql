-- ============================================================================
-- Лабораторна робота №2: Створення складних SQL запитів
-- Рівень складності: Рівень 2
-- База даних: ТехноМарт (TechnoMart)
-- ============================================================================

-- ============================================================================
-- 4. Складні з'єднання та аналіз
-- ============================================================================

-- Завдання 4.1:
-- RIGHT JOIN — аналіз категорій товарів та наявності продукції.
-- Бізнес-логіка: виявлення незаповнених категорій каталогу для відділу асортиментного планування.
SELECT
    c.category_id,
    c.category_name,
    COUNT(p.product_id)                         AS products_count,
    COALESCE(ROUND(AVG(p.unit_price), 2), 0.00) AS avg_price,
    COALESCE(SUM(p.units_in_stock), 0)          AS total_units_in_stock
FROM products AS p
RIGHT JOIN categories AS c
    ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY products_count DESC, c.category_name;

-- Завдання 4.2:
-- Self-join (самоз'єднання) — співробітники та їхні безпосередні керівники.
-- Бізнес-логіка: побудова організаційної структури та ланцюга підпорядкування компанії.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.title                            AS employee_title,
    COALESCE(m.first_name || ' ' || m.last_name, 'Керівник відсутній (Топ-менеджер)') AS manager_name,
    COALESCE(m.title, '—')             AS manager_title
FROM employees AS e
LEFT JOIN employees AS m
    ON e.reports_to = m.employee_id
ORDER BY e.reports_to NULLS FIRST, e.employee_id;

-- Завдання 4.3:
-- FULL OUTER JOIN — повне зіставлення постачальників і товарів.
-- Бізнес-логіка: аудит зв'язків між контрагентами та номенклатурою (виявлення постачальників без товарів та товарів без постачальників).
SELECT
    s.supplier_id,
    COALESCE(s.company_name, 'Постачальник не вказаний') AS company_name,
    p.product_id,
    COALESCE(p.product_name, 'Товари відсутні')          AS product_name,
    p.unit_price,
    c.category_name
FROM products AS p
FULL OUTER JOIN suppliers AS s
    ON s.supplier_id = p.supplier_id
LEFT JOIN categories AS c
    ON c.category_id = p.category_id
ORDER BY s.supplier_id NULLS LAST, p.product_id NULLS LAST;

-- Завдання 4.4:
-- Умовне з'єднання (з додатковими фільтрами в клаузулі ON).
-- Бізнес-логіка: підключення тільки преміальних товарів (> 30000 ₴) з високим залишком на складі (> 10 шт.)
-- зі збереженням повного переліку категорій (на відміну від WHERE, умова в ON зберігає рядки з NULL для порожніх категорій).
SELECT
    c.category_id,
    c.category_name,
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock
FROM categories AS c
LEFT JOIN products AS p
    ON p.category_id = c.category_id
   AND p.unit_price > 30000
   AND p.units_in_stock > 10
ORDER BY c.category_name, p.unit_price DESC;


-- ============================================================================
-- 5. Віконні функції та аналітика
-- ============================================================================

-- Завдання 5.1:
-- Ранжування товарів у межах кожної категорії за ціною (ROW_NUMBER, RANK, DENSE_RANK).
-- Бізнес-логіка: визначення топових та найдорожчих товарів у кожній товарній групі з демонстрацією різних алгоритмів обробки однакових цін.
SELECT
    c.category_name,
    p.product_name,
    p.unit_price,
    ROW_NUMBER() OVER (
        PARTITION BY c.category_id
        ORDER BY p.unit_price DESC, p.product_name
    ) AS row_num,
    RANK() OVER (
        PARTITION BY c.category_id
        ORDER BY p.unit_price DESC
    ) AS price_rank,
    DENSE_RANK() OVER (
        PARTITION BY c.category_id
        ORDER BY p.unit_price DESC
    ) AS dense_price_rank
FROM products AS p
INNER JOIN categories AS c
    ON c.category_id = p.category_id
ORDER BY c.category_name, p.unit_price DESC;

-- Завдання 5.2:
-- Функції зміщення LAG() та LEAD() — хронологічний аналіз замовлень клієнта.
-- Бізнес-логіка: порівняння чеків і дат між послідовними замовленнями клієнта, розрахунок паузи між покупками (LTV та відтік).
WITH customer_order_totals AS (
    SELECT
        o.order_id,
        o.customer_id,
        cu.contact_name,
        o.order_date,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS order_total
    FROM orders AS o
    INNER JOIN customers AS cu   ON cu.customer_id = o.customer_id
    INNER JOIN order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id, cu.contact_name, o.order_date
)
SELECT
    customer_id,
    contact_name,
    order_id,
    order_date,
    order_total,
    LAG(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS prev_order_date,
    order_date - LAG(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS days_since_prev_order,
    LAG(order_total) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS prev_order_total,
    LEAD(order_total) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS next_order_total,
    ROUND(order_total - LAG(order_total) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ), 2) AS diff_from_prev_order
FROM customer_order_totals
ORDER BY customer_id, order_date;

-- Завдання 5.3:
-- Аналітика в розрізах з PARTITION BY — аналіз структури вартості складських запасів.
-- Бізнес-логіка: розрахунок частки кожного товару в сумарній вартості складських залишків своєї категорії.
SELECT
    c.category_name,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    ROUND(p.unit_price * p.units_in_stock, 2) AS item_stock_value,
    ROUND(SUM(p.unit_price * p.units_in_stock) OVER (
        PARTITION BY c.category_id
    ), 2) AS category_total_stock_value,
    ROUND(
        (p.unit_price * p.units_in_stock * 100.0) /
        NULLIF(SUM(p.unit_price * p.units_in_stock) OVER (PARTITION BY c.category_id), 0),
        2
    ) AS pct_share_in_category,
    ROUND(AVG(p.unit_price) OVER (
        PARTITION BY c.category_id
    ), 2) AS category_avg_price
FROM products AS p
INNER JOIN categories AS c
    ON c.category_id = p.category_id
ORDER BY c.category_name, item_stock_value DESC;
