-- ============================================================================
-- Лабораторна робота №5: Скрипт 02: Генерація навантажувального датасету
-- Студент: Панасюк Владислав Васильович, група ІПЗ-32
-- ============================================================================

SET search_path TO lab05, public;

-- 1. Жанри літератури
INSERT INTO lab05.genres (name, description) VALUES
('Фантастика', 'Наукова та космічна фантастика, кіберпанк, постапокаліпсис'),
('Детективи', 'Класичні та психологічні детективи, трилери, нуар'),
('Класична література', 'Світова та українська художня класика'),
('Поезія', 'Збірки ліричних, філософських та патріотичних віршів'),
('Історія та мемуари', 'Документальні дослідження, біографії видатних осіб'),
('Комп''ютерні науки', 'Програмування, архітектура ПЗ, алгоритми, бази даних'),
('Бізнес та економіка', 'Менеджмент, маркетинг, інвестиції, стартапи'),
('Психологія', 'Саморозвиток, когнітивна психологія, лідерство'),
('Філософія', 'Філософські трактати, етика, світоглядні концепції'),
('Дитяча література', 'Казки, пізнавальні повісті, ілюстровані видання')
ON CONFLICT (name) DO NOTHING;

-- 2. Автори (500 записів)
INSERT INTO lab05.authors (first_name, last_name, country, birth_year)
SELECT
    (ARRAY['Тарас', 'Іван', 'Леся', 'Василь', 'Ліна', 'Джордж', 'Стівен', 'Агата', 'Ювал', 'Роберт', 'Артур', 'Микола', 'Ольга', 'Михайло', 'Богдан'])[1 + (g % 15)],
    (ARRAY['Шевченко', 'Франко', 'Українка', 'Стус', 'Костенко', 'Орвелл', 'Кінг', 'Крісті', 'Харарі', 'Мартін', 'Дойл', 'Гоголь', 'Кобилянська', 'Коцюбинський', 'Хмельницький'])[1 + ((g / 15) % 15)] || '_' || g,
    (ARRAY['Україна', 'Велика Британія', 'США', 'Польща', 'Німеччина', 'Франція', 'Ізраїль'])[1 + (g % 7)],
    1800 + (g % 200)
FROM generate_series(1, 500) AS g;

-- 3. Книги (5 000 найменувань)
INSERT INTO lab05.books (isbn, title, author_id, genre_id, publication_year, price, stock_quantity)
SELECT
    '978-' || lpad((g % 1000)::text, 3, '0') || '-' || lpad((g * 7 % 100000)::text, 5, '0') || '-' || (g % 10),
    'Книга видання #' || g || ' (' || (ARRAY['Том 1', 'Том 2', 'Вибране', 'Ювілейне', 'Розширене', 'Повне зібрання'])[1 + (g % 6)] || ')',
    1 + (g % 500),
    1 + (g % 10),
    1950 + (g % 75),
    round((50.00 + (g * 17 % 1450) + (g % 99) * 0.5)::numeric, 2),
    (g * 13 % 120)
FROM generate_series(1, 5000) AS g;

-- 4. Клієнти (20 000 покупців)
INSERT INTO lab05.customers (full_name, email, phone, city, status, created_at)
SELECT
    'Покупець ' || g || ' ' || (ARRAY['Мельник', 'Шевченко', 'Коваленко', 'Бондаренко', 'Бойко', 'Ткаченко', 'Кравченко', 'Олійник', 'Мороз', 'Лисенко'])[1 + (g % 10)],
    'customer_' || g || '_' || (g % 997) || '@bookstore-lab05.ua',
    '+380' || lpad((500000000 + g * 31 % 499999999)::text, 9, '0'),
    (ARRAY['Київ', 'Львів', 'Луцьк', 'Дніпро', 'Одеса', 'Харків', 'Вінниця', 'Тернопіль', 'Івано-Франківськ', 'Рівне'])[1 + (g % 10)],
    CASE 
        WHEN g % 20 = 0 THEN 'blocked'
        WHEN g % 7 = 0 THEN 'inactive'
        ELSE 'active'
    END,
    NOW() - ((g * 11 % 1095) || ' days')::interval - ((g % 86400) || ' seconds')::interval
FROM generate_series(1, 20000) AS g;

-- 5. Замовлення (60 000 замовлень)
INSERT INTO lab05.orders (customer_id, order_date, status, total_amount)
SELECT
    1 + (g * 19 % 20000),
    NOW() - ((g * 13 % 730) || ' days')::interval - ((g % 86400) || ' seconds')::interval,
    (ARRAY['Pending', 'Processing', 'Completed', 'Cancelled', 'Completed', 'Completed'])[1 + (g % 6)],
    round((120.00 + (g * 37 % 4800) + (g % 89) * 0.4)::numeric, 2)
FROM generate_series(1, 60000) AS g;

-- 6. Позиції замовлень (120 000 позицій)
INSERT INTO lab05.order_items (order_id, book_id, quantity, unit_price, subtotal)
SELECT
    1 + (g % 60000),
    1 + (g * 23 % 5000),
    1 + (g % 5),
    round((100.00 + (g * 19 % 900))::numeric, 2),
    round(((1 + (g % 5)) * (100.00 + (g * 19 % 900)))::numeric, 2)
FROM generate_series(1, 120000) AS g;

-- 7. Оновлення статистики оптимізатора
ANALYZE lab05.genres;
ANALYZE lab05.authors;
ANALYZE lab05.books;
ANALYZE lab05.customers;
ANALYZE lab05.orders;
ANALYZE lab05.order_items;

-- Перевірка кількості записів
SELECT 'genres' as table_name, count(*) as row_count FROM lab05.genres
UNION ALL
SELECT 'authors', count(*) FROM lab05.authors
UNION ALL
SELECT 'books', count(*) FROM lab05.books
UNION ALL
SELECT 'customers', count(*) FROM lab05.customers
UNION ALL
SELECT 'orders', count(*) FROM lab05.orders
UNION ALL
SELECT 'order_items', count(*) FROM lab05.order_items;
