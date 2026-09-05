-- База даних українського інтернет-магазину "ТехноМарт"
-- Для використання в Supabase PostgreSQL

-- Видалення існуючих таблиць (якщо є)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS regions CASCADE;

-- Створення таблиці регіонів України
CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL,
    region_code VARCHAR(2) NOT NULL UNIQUE
);

-- Створення таблиці постачальників
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(50),
    contact_title VARCHAR(30),
    address VARCHAR(100),
    city VARCHAR(30),
    region_id INTEGER REFERENCES regions(region_id),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100)
);

-- Створення таблиці категорій товарів
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    picture_url VARCHAR(200)
);

-- Створення таблиці товарів
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    category_id INTEGER REFERENCES categories(category_id),
    quantity_per_unit VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0,
    units_in_stock INTEGER DEFAULT 0,
    units_on_order INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 0,
    discontinued BOOLEAN DEFAULT false,
    description TEXT,
    picture_url VARCHAR(200)
);

-- Створення таблиці співробітників
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    title VARCHAR(50),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(100),
    city VARCHAR(30),
    region_id INTEGER REFERENCES regions(region_id),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(100),
    salary DECIMAL(10,2),
    reports_to INTEGER REFERENCES employees(employee_id)
);

-- Створення таблиці клієнтів
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100),
    contact_name VARCHAR(50) NOT NULL,
    contact_title VARCHAR(30),
    address VARCHAR(100),
    city VARCHAR(30),
    region_id INTEGER REFERENCES regions(region_id),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE,
    customer_type VARCHAR(20) DEFAULT 'individual' -- 'individual' або 'company'
);

-- Створення таблиці замовлень
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    order_date DATE DEFAULT CURRENT_DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via VARCHAR(50),
    freight DECIMAL(8,2) DEFAULT 0,
    ship_name VARCHAR(50),
    ship_address VARCHAR(100),
    ship_city VARCHAR(30),
    ship_region_id INTEGER REFERENCES regions(region_id),
    ship_postal_code VARCHAR(10),
    order_status VARCHAR(20) DEFAULT 'pending' -- 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
);

-- Створення таблиці деталей замовлень
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    discount DECIMAL(4,2) DEFAULT 0,
    UNIQUE(order_id, product_id)
);

-- Заповнення даними

-- Регіони України
INSERT INTO regions (region_name, region_code) VALUES
('Київська область', 'KV'),
('Львівська область', 'LV'),
('Харківська область', 'KH'),
('Дніпропетровська область', 'DP'),
('Одеська область', 'OD'),
('Запорізька область', 'ZP'),
('Івано-Франківська область', 'IF'),
('Тернопільська область', 'TE'),
('Вінницька область', 'VI'),
('Полтавська область', 'PO'),
('Чернігівська область', 'CH'),
('Черкаська область', 'CK'),
('Житомирська область', 'ZH'),
('Сумська область', 'SU'),
('Рівненська область', 'RV'),
('Кіровоградська область', 'KR'),
('Хмельницька область', 'HM'),
('Чернівецька область', 'CV'),
('Закарпатська область', 'ZK'),
('Волинська область', 'VO'),
('Миколаївська область', 'MK'),
('Херсонська область', 'KS'),
('Луганська область', 'LU'),
('Донецька область', 'DO'),
('м. Київ', 'KC');

-- Постачальники
INSERT INTO suppliers (company_name, contact_name, contact_title, address, city, region_id, postal_code, phone, email, website) VALUES
('ТОВ "Електроніка Плюс"', 'Петренко Микола Іванович', 'Директор', 'вул. Хрещатик, 15', 'Київ', 25, '01001', '+380445551234', 'info@electronicplus.ua', 'www.electronicplus.ua'),
('ПП "Комп''ютерні технології"', 'Іваненко Олена Петрівна', 'Менеджер з продажу', 'вул. Личаківська, 23', 'Львів', 2, '79000', '+380322334455', 'sales@comptech.ua', 'www.comptech.ua'),
('ТОВ "Мобільний світ"', 'Коваленко Андрій Сергійович', 'Комерційний директор', 'пр. Науки, 45', 'Харків', 3, '61000', '+380577889900', 'orders@mobileworld.ua', 'www.mobileworld.ua'),
('ТОВ "Техно Імпорт"', 'Шевченко Марія Олександрівна', 'Керівник відділу закупівель', 'вул. Дерибасівська, 12', 'Одеса', 5, '65000', '+380482556677', 'import@technoimport.ua', 'www.technoimport.ua'),
('ПАТ "Дніпро Електронікс"', 'Мельник Віктор Васильович', 'Заступник директора', 'пр. Дмитра Яворницького, 67', 'Дніпро', 4, '49000', '+380563445566', 'sales@dnipro-electronics.ua', 'www.dnipro-electronics.ua'),
('ТОВ "Львівські комп''ютери"', 'Гнатенко Ірина Михайлівна', 'Менеджер', 'вул. Городоцька, 89', 'Львів', 2, '79020', '+380322998877', 'lvivpc@gmail.com', 'www.lvivcomputers.ua'),
('ТОВ "Запорізька електроніка"', 'Савченко Олександр Петрович', 'Директор з продажу', 'вул. Соборна, 156', 'Запоріжжя', 6, '69000', '+380612223344', 'info@zp-electronics.ua', 'www.zp-electronics.ua'),
('ПП "Прикарпатські технології"', 'Федоренко Наталія Іванівна', 'Власник', 'вул. Галицька, 34', 'Івано-Франківськ', 7, '76000', '+380342556789', 'contact@prykarpattech.ua', 'www.prykarpattech.ua');

-- Категорії товарів
INSERT INTO categories (category_name, description, picture_url) VALUES
('Смартфони та телефони', 'Мобільні телефони, смартфони, аксесуари', 'https://example.com/phones.jpg'),
('Ноутбуки та комп''ютери', 'Портативні та настільні комп''ютери, комплектуючі', 'https://example.com/computers.jpg'),
('Телевізори та аудіо', 'Телевізори, аудіосистеми, навушники', 'https://example.com/tv-audio.jpg'),
('Побутова техніка', 'Холодильники, пральні машини, мікрохвильові печі', 'https://example.com/appliances.jpg'),
('Фото та відео', 'Фотоапарати, відеокамери, об''єктиви', 'https://example.com/photo-video.jpg'),
('Ігрові консолі та ігри', 'PlayStation, Xbox, Nintendo, ігри', 'https://example.com/gaming.jpg'),
('Планшети та електронні книги', 'iPad, Android планшети, e-book читалки', 'https://example.com/tablets.jpg'),
('Аксесуари та комплектуючі', 'Кабелі, зарядні пристрої, чохли', 'https://example.com/accessories.jpg'),
('Розумний дім', 'IoT пристрої, розумні лампи, системи безпеки', 'https://example.com/smart-home.jpg'),
('Спортивні технології', 'Фітнес-трекери, спортивні годинники', 'https://example.com/sports-tech.jpg');

-- Товари
INSERT INTO products (product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued, description, picture_url) VALUES
-- Смартфони
('iPhone 15 128GB Чорний', 1, 1, '1 шт в коробці', 29999.00, 25, 10, 5, false, 'Новий iPhone 15 з потужним процесором A16 Bionic та покращеною камерою', 'https://example.com/iphone15.jpg'),
('Samsung Galaxy S24 256GB Фіолетовий', 2, 1, '1 шт в коробці', 27999.00, 18, 5, 3, false, 'Флагманський смартфон Samsung з екраном Dynamic AMOLED 2X', 'https://example.com/galaxy-s24.jpg'),
('Xiaomi Redmi Note 13 Pro 128GB Синій', 3, 1, '1 шт в коробці', 12999.00, 45, 20, 10, false, 'Доступний смартфон з відмінними характеристиками', 'https://example.com/redmi-note13.jpg'),
('Google Pixel 8 128GB Білий', 4, 1, '1 шт в коробці', 24999.00, 12, 8, 5, false, 'Смартфон Google з чистим Android та ШІ-функціями', 'https://example.com/pixel8.jpg'),
('OnePlus 12 256GB Зелений', 1, 1, '1 шт в коробці', 22999.00, 8, 0, 3, false, 'Потужний флагман з швидкою зарядкою', 'https://example.com/oneplus12.jpg'),

-- Ноутбуки
('MacBook Air M2 13" 256GB Сріблястий', 2, 2, '1 шт в коробці', 45999.00, 15, 5, 3, false, 'Ультратонкий ноутбук Apple з процесором M2', 'https://example.com/macbook-air.jpg'),
('Dell XPS 13 Plus Intel i7 512GB', 5, 2, '1 шт в коробці', 52999.00, 8, 3, 2, false, 'Преміум ультрабук для професіоналів', 'https://example.com/dell-xps13.jpg'),
('ASUS ROG Strix G15 RTX 4060 1TB', 3, 2, '1 шт в коробці', 42999.00, 12, 8, 5, false, 'Ігровий ноутбук з потужною графікою', 'https://example.com/asus-rog.jpg'),
('Lenovo ThinkPad X1 Carbon Gen 11', 6, 2, '1 шт в коробці', 48999.00, 6, 2, 2, false, 'Бізнес-ноутбук з максимальною надійністю', 'https://example.com/thinkpad-x1.jpg'),
('HP Pavilion 15 AMD Ryzen 7 512GB', 7, 2, '1 шт в коробці', 28999.00, 20, 10, 8, false, 'Універсальний ноутбук для роботи та розваг', 'https://example.com/hp-pavilion.jpg'),

-- Телевізори
('Samsung QLED QE55Q80C 55" 4K', 1, 3, '1 шт в коробці', 34999.00, 10, 5, 3, false, 'Преміум QLED телевізор з квантовими точками', 'https://example.com/samsung-qled.jpg'),
('LG OLED C3 65" 4K Smart TV', 4, 3, '1 шт в коробці', 62999.00, 5, 2, 2, false, 'OLED телевізор з ідеальним чорним кольором', 'https://example.com/lg-oled.jpg'),
('Sony Bravia XR A80L 55" OLED', 2, 3, '1 шт в коробці', 58999.00, 7, 3, 2, false, 'OLED телевізор Sony з процесором Cognitive XR', 'https://example.com/sony-bravia.jpg'),
('TCL C845 Mini LED 65" 4K', 8, 3, '1 шт в коробці', 29999.00, 12, 6, 4, false, 'Mini LED телевізор з відмінним співвідношенням ціна/якість', 'https://example.com/tcl-c845.jpg'),

-- Побутова техніка
('Холодильник Samsung RB38T7762SA/UA', 1, 4, '1 шт в коробці', 28999.00, 8, 4, 2, false, 'Двокамерний холодильник No Frost 385л', 'https://example.com/samsung-fridge.jpg'),
('Пральна машина LG F4V5VS6W 9кг', 4, 4, '1 шт в коробці', 18999.00, 12, 6, 3, false, 'Пральна машина з прямим приводом та паровими функціями', 'https://example.com/lg-washer.jpg'),
('Мікрохвильова піч Panasonic NN-ST45KW', 3, 4, '1 шт в коробці', 4999.00, 25, 15, 10, false, 'Соло мікрохвильова піч 32л з сенсорним керуванням', 'https://example.com/panasonic-microwave.jpg'),

-- Планшети
('iPad Air M2 11" 128GB Синій', 2, 7, '1 шт в коробці', 23999.00, 15, 8, 5, false, 'Планшет Apple з процесором M2 та підтримкою Apple Pencil', 'https://example.com/ipad-air.jpg'),
('Samsung Galaxy Tab S9+ 256GB', 1, 7, '1 шт в коробці', 32999.00, 9, 3, 2, false, 'Android планшет преміум класу з S Pen', 'https://example.com/galaxy-tab-s9.jpg'),

-- Аксесуари
('Навушники Apple AirPods Pro 2', 2, 8, '1 пара в коробці', 8999.00, 30, 20, 15, false, 'Бездротові навушники з активним шумозаглушенням', 'https://example.com/airpods-pro.jpg'),
('Зарядний кабель USB-C 2м', 8, 8, '1 шт в упаковці', 699.00, 100, 50, 20, false, 'Швидкий зарядний кабель USB-C to USB-C', 'https://example.com/usb-c-cable.jpg'),
('Бездротова клавіатура Logitech MX Keys', 6, 8, '1 шт в коробці', 3999.00, 18, 10, 8, false, 'Професійна бездротова клавіатура для продуктивності', 'https://example.com/mx-keys.jpg'),

-- Ігрові консолі
('PlayStation 5 825GB', 3, 6, '1 шт в коробці', 17999.00, 3, 5, 2, false, 'Ігрова консоль нового покоління Sony', 'https://example.com/ps5.jpg'),
('Xbox Series X 1TB', 5, 6, '1 шт в коробці', 16999.00, 5, 3, 2, false, 'Найпотужніша ігрова консоль Microsoft', 'https://example.com/xbox-series-x.jpg'),
('Nintendo Switch OLED 64GB', 1, 6, '1 шт в коробці', 12999.00, 12, 8, 5, false, 'Гібридна ігрова консоль з OLED екраном', 'https://example.com/nintendo-switch.jpg');

-- Співробітники
INSERT INTO employees (last_name, first_name, middle_name, title, birth_date, hire_date, address, city, region_id, postal_code, phone, email, salary, reports_to) VALUES
('Петренко', 'Олександр', 'Іванович', 'Генеральний директор', '1978-03-15', '2020-01-15', 'вул. Володимирська, 45', 'Київ', 25, '01030', '+380671234567', 'petrenko@technomart.ua', 45000.00, NULL),
('Коваленко', 'Марія', 'Петрівна', 'Менеджер з продажу', '1985-07-22', '2021-03-01', 'вул. Саксаганського, 78', 'Київ', 25, '01032', '+380671234568', 'kovalenko@technomart.ua', 25000.00, 1),
('Іваненко', 'Сергій', 'Олександрович', 'Менеджер з закупівель', '1982-11-08', '2020-09-15', 'вул. Антоновича, 12', 'Київ', 25, '01033', '+380671234569', 'ivanenko@technomart.ua', 28000.00, 1),
('Шевченко', 'Ольга', 'Миколаївна', 'Головний бухгалтер', '1980-05-30', '2020-04-01', 'вул. Лесі Українки, 23', 'Київ', 25, '01034', '+380671234570', 'shevchenko@technomart.ua', 32000.00, 1),
('Мельник', 'Андрій', 'Васильович', 'Менеджер з продажу', '1990-12-12', '2022-06-01', 'вул. Стрийська, 156', 'Львів', 2, '79000', '+380671234571', 'melnyk@technomart.ua', 22000.00, 2),
('Гриценко', 'Наталія', 'Сергіївна', 'Менеджер з продажу', '1988-09-18', '2021-11-15', 'вул. Сумська, 67', 'Харків', 3, '61000', '+380671234572', 'grytsenko@technomart.ua', 24000.00, 2),
('Білоус', 'Дмитро', 'Ігорович', 'Менеджер зі складу', '1995-02-28', '2023-01-10', 'вул. Червонозоряна, 89', 'Київ', 25, '01035', '+380671234573', 'bilous@technomart.ua', 20000.00, 3),
('Сидоренко', 'Тетяна', 'Володимирівна', 'Спеціаліст з логістики', '1992-08-05', '2022-09-01', 'вул. Дерибасівська, 34', 'Одеса', 5, '65000', '+380671234574', 'sydorenko@technomart.ua', 23000.00, 3);

-- Клієнти
INSERT INTO customers (company_name, contact_name, contact_title, address, city, region_id, postal_code, phone, email, registration_date, customer_type) VALUES
(NULL, 'Петров Іван Миколайович', NULL, 'вул. Хрещатик, 15, кв. 25', 'Київ', 25, '01001', '+380501234567', 'petrov.ivan@gmail.com', '2023-01-15', 'individual'),
(NULL, 'Іванова Марія Сергіївна', NULL, 'вул. Пушкінська, 45, кв. 12', 'Харків', 3, '61000', '+380661234568', 'ivanova.maria@ukr.net', '2023-02-20', 'individual'),
('ТОВ "Бізнес Сістемс"', 'Коваленко Андрій Петрович', 'ІТ-директор', 'вул. Лесі Українки, 78', 'Київ', 25, '01030', '+380441234569', 'kovalenko@bizasystems.ua', '2023-01-10', 'company'),
(NULL, 'Мельник Ольга Іванівна', NULL, 'вул. Городоцька, 123, кв. 67', 'Львів', 2, '79000', '+380631234570', 'melnyk.olga@gmail.com', '2023-03-05', 'individual'),
('ПП "Комп''ютерний сервіс"', 'Шевченко Віктор Олександрович', 'Власник', 'пр. Науки, 34', 'Харків', 3, '61001', '+380571234571', 'shevchenko@compservice.ua', '2022-11-15', 'company'),
(NULL, 'Гриценко Наталія Володимирівна', NULL, 'вул. Дерибасівська, 56, кв. 89', 'Одеса', 5, '65000', '+380481234572', 'grytsenko.natalia@outlook.com', '2023-04-12', 'individual'),
('ТОВ "Офіс Технології"', 'Білоус Дмитро Сергійович', 'Менеджер з закупівель', 'вул. Соборна, 45', 'Дніпро', 4, '49000', '+380561234573', 'bilous@officetech.ua', '2023-02-28', 'company'),
(NULL, 'Сидоренко Тетяна Миколаївна', NULL, 'вул. Стрийська, 234, кв. 15', 'Львів', 2, '79001', '+380321234574', 'sydorenko.tetyana@gmail.com', '2023-05-18', 'individual'),
(NULL, 'Павленко Олексій Іванович', NULL, 'вул. Сумська, 156, кв. 78', 'Харків', 3, '61002', '+380501234575', 'pavlenko.oleksiy@meta.ua', '2023-03-22', 'individual'),
('ТОВ "Медіа Продакшн"', 'Федоренко Ірина Петрівна', 'Креативний директор', 'вул. Володимирська, 89', 'Київ', 25, '01033', '+380441234576', 'fedorenko@mediaproduction.ua', '2022-12-08', 'company'),
(NULL, 'Кравченко Максим Олександрович', NULL, 'пр. Свободи, 67, кв. 34', 'Львів', 2, '79002', '+380671234577', 'kravchenko.max@gmail.com', '2023-06-10', 'individual'),
(NULL, 'Ткаченко Анна Сергіївна', NULL, 'вул. Грушевського, 123, кв. 45', 'Дніпро', 4, '49001', '+380991234578', 'tkachenko.anna@ukr.net', '2023-04-25', 'individual'),
('ПАТ "Фінанс Груп"', 'Лисенко Володимир Іванович', 'Фінансовий директор', 'вул. Банкова, 12', 'Київ', 25, '01001', '+380441234579', 'lysenko@financegroup.ua', '2023-01-05', 'company'),
(NULL, 'Бойко Світлана Петрівна', NULL, 'вул. Французький бульвар, 78, кв. 12', 'Одеса', 5, '65001', '+380631234580', 'boyko.svitlana@gmail.com', '2023-07-03', 'individual'),
('ТОВ "Логістика Плюс"', 'Морозенко Сергій Миколайович', 'Логістик', 'пр. Гагаріна, 156', 'Дніпро', 4, '49002', '+380561234581', 'morozenko@logisticsplus.ua', '2023-02-14', 'company');

-- Замовлення
INSERT INTO orders (customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region_id, ship_postal_code, order_status) VALUES
(1, 2, '2024-01-15', '2024-01-18', '2024-01-17', 'Нова Пошта', 120.00, 'Петров Іван Миколайович', 'вул. Хрещатик, 15, кв. 25', 'Київ', 25, '01001', 'delivered'),
(3, 2, '2024-01-20', '2024-01-25', '2024-01-23', 'УкрПошта', 180.00, 'ТОВ "Бізнес Сістемс"', 'вул. Лесі Українки, 78', 'Київ', 25, '01030', 'delivered'),
(2, 6, '2024-01-22', '2024-01-26', '2024-01-25', 'Делівері', 150.00, 'Іванова Марія Сергіївна', 'вул. Пушкінська, 45, кв. 12', 'Харків', 3, '61000', 'delivered'),
(4, 5, '2024-02-01', '2024-02-05', '2024-02-04', 'Нова Пошта', 95.00, 'Мельник Ольга Іванівна', 'вул. Городоцька, 123, кв. 67', 'Львів', 2, '79000', 'delivered'),
(5, 6, '2024-02-10', '2024-02-15', '2024-02-14', 'САТ', 220.00, 'ПП "Комп''ютерний сервіс"', 'пр. Науки, 34', 'Харків', 3, '61001', 'delivered'),
(6, 8, '2024-02-18', '2024-02-22', '2024-02-21', 'Нова Пошта', 85.00, 'Гриценко Наталія Володимирівна', 'вул. Дерибасівська, 56, кв. 89', 'Одеса', 5, '65000', 'delivered'),
(7, 2, '2024-02-25', '2024-03-01', '2024-02-28', 'УкрПошта', 350.00, 'ТОВ "Офіс Технології"', 'вул. Соборна, 45', 'Дніпро', 4, '49000', 'delivered'),
(8, 5, '2024-03-05', '2024-03-10', '2024-03-08', 'Делівері', 130.00, 'Сидоренко Тетяна Миколаївна', 'вул. Стрийська, 234, кв. 15', 'Львів', 2, '79001', 'delivered'),
(9, 6, '2024-03-12', '2024-03-16', '2024-03-15', 'Нова Пошта', 110.00, 'Павленко Олексій Іванович', 'вул. Сумська, 156, кв. 78', 'Харків', 3, '61002', 'delivered'),
(10, 2, '2024-03-18', '2024-03-22', '2024-03-21', 'САТ', 280.00, 'ТОВ "Медіа Продакшн"', 'вул. Володимирська, 89', 'Київ', 25, '01033', 'delivered'),
(11, 5, '2024-03-25', '2024-03-29', '2024-03-28', 'Нова Пошта', 75.00, 'Кравченко Максим Олександрович', 'пр. Свободи, 67, кв. 34', 'Львів', 2, '79002', 'delivered'),
(12, 2, '2024-04-02', '2024-04-06', '2024-04-05', 'УкрПошта', 160.00, 'Ткаченко Анна Сергіївна', 'вул. Грушевського, 123, кв. 45', 'Дніпро', 4, '49001', 'delivered'),
(13, 2, '2024-04-08', '2024-04-12', '2024-04-11', 'Делівері', 420.00, 'ПАТ "Фінанс Груп"', 'вул. Банкова, 12', 'Київ', 25, '01001', 'delivered'),
(14, 8, '2024-04-15', '2024-04-19', '2024-04-18', 'Нова Пошта', 95.00, 'Бойко Світлана Петрівна', 'вул. Французький бульвар, 78, кв. 12', 'Одеса', 5, '65001', 'delivered'),
(15, 2, '2024-04-22', '2024-04-26', '2024-04-25', 'САТ', 380.00, 'ТОВ "Логістика Плюс"', 'пр. Гагаріна, 156', 'Дніпро', 4, '49002', 'delivered'),
(1, 2, '2024-05-01', '2024-05-05', '2024-05-04', 'Нова Пошта', 140.00, 'Петров Іван Миколайович', 'вул. Хрещатик, 15, кв. 25', 'Київ', 25, '01001', 'delivered'),
(2, 6, '2024-05-10', '2024-05-14', '2024-05-13', 'Делівері', 180.00, 'Іванова Марія Сергіївна', 'вул. Пушкінська, 45, кв. 12', 'Харків', 3, '61000', 'delivered'),
(4, 5, '2024-05-18', '2024-05-22', '2024-05-21', 'УкрПошта', 90.00, 'Мельник Ольга Іванівна', 'вул. Городоцька, 123, кв. 67', 'Львів', 2, '79000', 'delivered'),
(6, 8, '2024-05-25', '2024-05-29', '2024-05-28', 'Нова Пошта', 125.00, 'Гриценко Наталія Володимирівна', 'вул. Дерибасівська, 56, кв. 89', 'Одеса', 5, '65000', 'delivered'),
(9, 6, '2024-06-05', '2024-06-09', '2024-06-08', 'САТ', 200.00, 'Павленко Олексій Іванович', 'вул. Сумська, 156, кв. 78', 'Харків', 3, '61002', 'delivered'),
(11, 5, '2024-06-12', '2024-06-16', '2024-06-15', 'Делівері', 105.00, 'Кравченко Максим Олександрович', 'пр. Свободи, 67, кв. 34', 'Львів', 2, '79002', 'delivered'),
(3, 2, '2024-06-20', '2024-06-24', '2024-06-23', 'Нова Пошта', 320.00, 'ТОВ "Бізнес Сістемс"', 'вул. Лесі Українки, 78', 'Київ', 25, '01030', 'delivered'),
(5, 6, '2024-07-01', '2024-07-05', '2024-07-04', 'УкрПошта', 250.00, 'ПП "Комп''ютерний сервіс"', 'пр. Науки, 34', 'Харків', 3, '61001', 'delivered'),
(8, 5, '2024-07-08', '2024-07-12', '2024-07-11', 'САТ', 115.00, 'Сидоренко Тетяна Миколаївна', 'вул. Стрийська, 234, кв. 15', 'Львів', 2, '79001', 'delivered'),
(12, 2, '2024-07-15', '2024-07-19', '2024-07-18', 'Нова Пошта', 190.00, 'Ткаченко Анна Сергіївна', 'вул. Грушевського, 123, кв. 45', 'Дніпро', 4, '49001', 'delivered'),
(14, 8, '2024-07-22', '2024-07-26', '2024-07-25', 'Делівері', 135.00, 'Бойко Світлана Петрівна', 'вул. Французький бульвар, 78, кв. 12', 'Одеса', 5, '65001', 'delivered'),
-- Поточні замовлення (в процесі)
(10, 2, '2024-08-01', '2024-08-05', NULL, 'Нова Пошта', 290.00, 'ТОВ "Медіа Продакшн"', 'вул. Володимирська, 89', 'Київ', 25, '01033', 'processing'),
(1, 2, '2024-08-10', '2024-08-14', NULL, 'САТ', 150.00, 'Петров Іван Миколайович', 'вул. Хрещатик, 15, кв. 25', 'Київ', 25, '01001', 'pending'),
(7, 2, '2024-08-15', '2024-08-19', '2024-08-17', 'УкрПошта', 380.00, 'ТОВ "Офіс Технології"', 'вул. Соборна, 45', 'Дніпро', 4, '49000', 'shipped'),
(13, 2, '2024-08-18', '2024-08-22', NULL, 'Делівері', 450.00, 'ПАТ "Фінанс Груп"', 'вул. Банкова, 12', 'Київ', 25, '01001', 'processing'),
(15, 2, '2024-08-20', '2024-08-24', NULL, 'Нова Пошта', 320.00, 'ТОВ "Логістика Плюс"', 'пр. Гагаріна, 156', 'Дніпро', 4, '49002', 'pending');

-- Деталі замовлень
INSERT INTO order_items (order_id, product_id, unit_price, quantity, discount) VALUES
-- Замовлення 1 (Петров Іван)
(1, 3, 12999.00, 1, 0.05), -- Xiaomi Redmi Note 13 Pro зі знижкою 5%
(1, 17, 699.00, 2, 0.00),   -- USB-C кабель 2 шт

-- Замовлення 2 (ТОВ "Бізнес Сістемс")
(2, 6, 45999.00, 2, 0.10),  -- MacBook Air M2 2 шт зі знижкою 10%
(2, 18, 3999.00, 2, 0.05),  -- Бездротова клавіатура 2 шт

-- Замовлення 3 (Іванова Марія)
(3, 1, 29999.00, 1, 0.00),  -- iPhone 15
(3, 16, 8999.00, 1, 0.00),  -- AirPods Pro 2

-- Замовлення 4 (Мельник Ольга)
(4, 16, 8999.00, 1, 0.00),  -- AirPods Pro 2
(4, 17, 699.00, 1, 0.00),   -- USB-C кабель

-- Замовлення 5 (ПП "Комп'ютерний сервіс")
(5, 8, 42999.00, 1, 0.08),  -- ASUS ROG Strix G15 зі знижкою 8%
(5, 7, 52999.00, 1, 0.08),  -- Dell XPS 13 Plus зі знижкою 8%

-- Замовлення 6 (Гриценко Наталія)
(6, 19, 17999.00, 1, 0.00), -- PlayStation 5

-- Замовлення 7 (ТОВ "Офіс Технології")
(7, 9, 48999.00, 3, 0.12),  -- Lenovo ThinkPad X1 Carbon 3 шт зі знижкою 12%
(7, 18, 3999.00, 3, 0.10),  -- Клавіатури 3 шт

-- Замовлення 8 (Сидоренко Тетяна)
(8, 14, 23999.00, 1, 0.00), -- iPad Air M2
(8, 17, 699.00, 2, 0.00),   -- USB-C кабелі 2 шт

-- Замовлення 9 (Павленко Олексій)
(9, 2, 27999.00, 1, 0.03),  -- Samsung Galaxy S24 зі знижкою 3%

-- Замовлення 10 (ТОВ "Медіа Продакшн")
(10, 11, 34999.00, 2, 0.15), -- Samsung QLED телевізори 2 шт зі знижкою 15%
(10, 5, 22999.00, 1, 0.10),  -- OnePlus 12 зі знижкою 10%

-- Замовлення 11 (Кравченко Максим)
(11, 21, 12999.00, 1, 0.00), -- Nintendo Switch OLED

-- Замовлення 12 (Ткаченко Анна)
(12, 10, 28999.00, 1, 0.05), -- HP Pavilion 15 зі знижкою 5%
(12, 16, 8999.00, 1, 0.00),  -- AirPods Pro 2

-- Замовлення 13 (ПАТ "Фінанс Груп")
(13, 6, 45999.00, 5, 0.15),  -- MacBook Air M2 5 шт зі знижкою 15%
(13, 18, 3999.00, 5, 0.10),  -- Клавіатури 5 шт

-- Замовлення 14 (Бойко Світлана)
(14, 15, 32999.00, 1, 0.00), -- Samsung Galaxy Tab S9+

-- Замовлення 15 (ТОВ "Логістика Плюс")
(15, 7, 52999.00, 2, 0.12),  -- Dell XPS 13 Plus 2 шт зі знижкою 12%
(15, 8, 42999.00, 1, 0.10),  -- ASUS ROG Strix G15 зі знижкою 10%

-- Замовлення 16 (Петров Іван - друге замовлення)
(16, 12, 62999.00, 1, 0.08), -- LG OLED C3 65" зі знижкою 8%

-- Замовлення 17 (Іванова Марія - друге замовлення)
(17, 4, 24999.00, 1, 0.05),  -- Google Pixel 8 зі знижкою 5%
(17, 17, 699.00, 3, 0.00),   -- USB-C кабелі 3 шт

-- Замовлення 18 (Мельник Ольга - друге замовлення)
(18, 18, 3999.00, 1, 0.00),  -- Бездротова клавіатура

-- Замовлення 19 (Гриценко Наталія - друге замовлення)
(19, 20, 16999.00, 1, 0.00), -- Xbox Series X

-- Замовлення 20 (Павленко Олексій - друге замовлення)
(20, 3, 12999.00, 2, 0.10),  -- Xiaomi Redmi Note 13 Pro 2 шт зі знижкою 10%

-- Замовлення 21 (Кравченко Максим - друге замовлення)
(21, 16, 8999.00, 1, 0.00),  -- AirPods Pro 2

-- Замовлення 22 (ТОВ "Бізнес Сістемс" - друге замовлення)
(22, 9, 48999.00, 4, 0.15),  -- Lenovo ThinkPad X1 Carbon 4 шт зі знижкою 15%

-- Замовлення 23 (ПП "Комп'ютерний сервіс" - друге замовлення)
(23, 1, 29999.00, 3, 0.12),  -- iPhone 15 3 шт зі знижкою 12%
(23, 2, 27999.00, 2, 0.10),  -- Samsung Galaxy S24 2 шт зі знижкою 10%

-- Замовлення 24 (Сидоренко Тетяна - друге замовлення)
(24, 17, 699.00, 5, 0.15),   -- USB-C кабелі 5 шт зі знижкою 15%

-- Замовлення 25 (Ткаченко Анна - друге замовлення)
(25, 13, 58999.00, 1, 0.10), -- Sony Bravia XR A80L зі знижкою 10%

-- Замовлення 26 (Бойко Світлана - друге замовлення)
(26, 14, 23999.00, 1, 0.05), -- iPad Air M2 зі знижкою 5%

-- Поточні замовлення
-- Замовлення 27 (ТОВ "Медіа Продакшн" - друге замовлення)
(27, 11, 34999.00, 3, 0.18), -- Samsung QLED телевізори 3 шт зі знижкою 18%

-- Замовлення 28 (Петров Іван - третє замовлення)
(28, 16, 8999.00, 2, 0.05),  -- AirPods Pro 2 2 шт зі знижкою 5%

-- Замовлення 29 (ТОВ "Офіс Технології" - друге замовлення)
(29, 6, 45999.00, 8, 0.20),  -- MacBook Air M2 8 шт зі знижкою 20%
(29, 18, 3999.00, 8, 0.15),  -- Клавіатури 8 шт зі знижкою 15%

-- Замовлення 30 (ПАТ "Фінанс Груп" - друге замовлення)
(30, 12, 62999.00, 2, 0.12), -- LG OLED C3 65" 2 шт зі знижкою 12%
(30, 13, 58999.00, 1, 0.10), -- Sony Bravia XR A80L зі знижкою 10%

-- Замовлення 31 (ТОВ "Логістика Плюс" - друге замовлення)
(31, 7, 52999.00, 3, 0.15),  -- Dell XPS 13 Plus 3 шт зі знижкою 15%
(31, 8, 42999.00, 2, 0.12);  -- ASUS ROG Strix G15 2 шт зі знижкою 12%

-- Створення індексів для покращення продуктивності
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_products_price ON products(unit_price);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_employee ON orders(employee_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_type ON customers(customer_type);
CREATE INDEX idx_employees_reports_to ON employees(reports_to);

-- Створення представлень (views) для зручності роботи
CREATE VIEW customer_orders_summary AS
SELECT
    c.customer_id,
    c.contact_name,
    c.customer_type,
    c.city,
    r.region_name,
    COUNT(o.order_id) as total_orders,
    COALESCE(SUM(oi.unit_price * oi.quantity * (1 - oi.discount)), 0) as total_amount,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN regions r ON c.region_id = r.region_id
GROUP BY c.customer_id, c.contact_name, c.customer_type, c.city, r.region_name;

CREATE VIEW product_sales_summary AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.company_name as supplier_name,
    p.unit_price,
    p.units_in_stock,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    COALESCE(SUM(oi.unit_price * oi.quantity * (1 - oi.discount)), 0) as total_revenue,
    COUNT(DISTINCT oi.order_id) as order_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status = 'delivered'
GROUP BY p.product_id, p.product_name, c.category_name, s.company_name, p.unit_price, p.units_in_stock;

CREATE VIEW monthly_sales_report AS
SELECT
    EXTRACT(YEAR FROM o.order_date) as year,
    EXTRACT(MONTH FROM o.order_date) as month,
    TO_CHAR(o.order_date, 'YYYY-MM') as year_month,
    COUNT(DISTINCT o.order_id) as orders_count,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(oi.quantity) as total_items,
    SUM(oi.unit_price * oi.quantity * (1 - oi.discount)) as total_revenue,
    AVG(oi.unit_price * oi.quantity * (1 - oi.discount)) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date), TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY year, month;

CREATE VIEW employee_performance AS
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) as full_name,
    e.title,
    e.city,
    r.region_name,
    COUNT(o.order_id) as orders_handled,
    COALESCE(SUM(oi.unit_price * oi.quantity * (1 - oi.discount)), 0) as sales_amount,
    COALESCE(AVG(oi.unit_price * oi.quantity * (1 - oi.discount)), 0) as avg_order_value
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN regions r ON e.region_id = r.region_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title, e.city, r.region_name;

-- Додавання коментарів до таблиць
COMMENT ON TABLE regions IS 'Регіони України';
COMMENT ON TABLE suppliers IS 'Постачальники товарів';
COMMENT ON TABLE categories IS 'Категорії товарів';
COMMENT ON TABLE products IS 'Каталог товарів';
COMMENT ON TABLE employees IS 'Співробітники компанії';
COMMENT ON TABLE customers IS 'Клієнти (фізичні особи та юридичні особи)';
COMMENT ON TABLE orders IS 'Замовлення клієнтів';
COMMENT ON TABLE order_items IS 'Позиції в замовленнях';

-- Додавання обмежень цілісності
ALTER TABLE products ADD CONSTRAINT chk_products_price_positive
    CHECK (unit_price >= 0);

ALTER TABLE products ADD CONSTRAINT chk_products_stock_positive
    CHECK (units_in_stock >= 0);

ALTER TABLE order_items ADD CONSTRAINT chk_order_items_quantity_positive
    CHECK (quantity > 0);

ALTER TABLE order_items ADD CONSTRAINT chk_order_items_price_positive
    CHECK (unit_price >= 0);

ALTER TABLE order_items ADD CONSTRAINT chk_order_items_discount_valid
    CHECK (discount >= 0 AND discount <= 1);

ALTER TABLE orders ADD CONSTRAINT chk_orders_dates
    CHECK (required_date >= order_date);

-- Статистична інформація для тестування
SELECT 'База даних "ТехноМарт" успішно створена!' as status;

SELECT
    'Регіонів' as entity, COUNT(*) as count FROM regions
UNION ALL
SELECT
    'Постачальників' as entity, COUNT(*) as count FROM suppliers
UNION ALL
SELECT
    'Категорій' as entity, COUNT(*) as count FROM categories
UNION ALL
SELECT
    'Товарів' as entity, COUNT(*) as count FROM products
UNION ALL
SELECT
    'Співробітників' as entity, COUNT(*) as count FROM employees
UNION ALL
SELECT
    'Клієнтів' as entity, COUNT(*) as count FROM customers
UNION ALL
SELECT
    'Замовлень' as entity, COUNT(*) as count FROM orders
UNION ALL
SELECT
    'Позицій в замовленнях' as entity, COUNT(*) as count FROM order_items;
