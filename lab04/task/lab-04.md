# Лабораторна робота 04 Розробка реляційної бази даних з простою інтеграцією

## 🎯 Мета роботи

Здобути практичні навички повного циклу розробки реляційної бази даних від аналізу предметної області до створення функціонального застосунку з веб-інтерфейсом, що включає проєктування нормалізованої структури, реалізацію в PostgreSQL та інтеграцію з програмним додатком.

## ✅ Завдання

### Рівень 1

Розробити базу даних для обраної предметної області та створити консольний застосунок для роботи з нею.

**Вимоги:**

1. Обрати предметну область зі списку або запропонувати власну
2. Створити концептуальну модель у вигляді ER-діаграми з мінімум 5 сутностями
3. Розробити логічну схему бази даних у третій нормальній формі
4. Реалізувати фізичну структуру в PostgreSQL з усіма обмеженнями цілісності
5. Наповнити базу тестовими даними (мінімум 10 записів на таблицю)
6. Створити мінімум 5 SQL-запитів різної складності для отримання даних
7. Реалізувати консольний застосунок мовою Python для базових операцій CRUD

**Предметні області на вибір:**

- Система обліку книжкового магазину
- База даних кінотеатру
- Облік медичної клініки
- Система управління спортивним клубом
- База даних ресторану
- Система обліку автосервісу
- Управління навчальним закладом
- Електронна бібліотека
- Система бронювання готелів
- Облік виробничого підприємства

### Рівень 2

Розширити функціональність бази даних та створити вебзастосунок з повноцінним інтерфейсом користувача.

**Додаткові вимоги:**

1. Створити мінімум 3 збережені процедури для складних операцій
2. Реалізувати мінімум 2 тригери для автоматизації процесів
3. Додати мінімум 2 представлення для спрощення доступу до даних
4. Створити вебзастосунок з використанням Flask або FastAPI
5. Реалізувати HTML-шаблони для всіх основних операцій
6. Додати базову валідацію введених даних на стороні сервера
7. Створити мінімум 3 складні аналітичні запити з агрегацією

### Рівень 3

Створити повноцінну інформаційну систему з розширеними можливостями та сучасним інтерфейсом.

**Розширені вимоги:**

1. Реалізувати систему аутентифікації користувачів з різними ролями
2. Додати механізм логування всіх операцій з даними
3. Створити систему генерації звітів у форматі PDF або Excel
4. Реалізувати пошук з фільтрацією та сортуванням
5. Додати графічну візуалізацію статистичних даних
6. Створити API endpoints для інтеграції з іншими системами
7. Реалізувати механізм резервного копіювання бази даних
8. Додати валідацію на стороні клієнта з використанням JavaScript
9. Оптимізувати продуктивність через створення ефективних індексів


## 🖥️ Програмне забезпечення

- [PostgreSQL](https://www.postgresql.org)

!!! tip "Рекомендації"

    Для виконання лабораторної роботи рекомендується використовувати БД в Docker-контейнері

    - [Docker Desktop](https://www.docker.com/products/docker-desktop)
    - [postgres official images](https://hub.docker.com/_/postgres)

## 👥 Форма виконання роботи

Форма виконання роботи **індивідуальна**.

## 📝 Критерії оцінювання

### Концептуальна модель (10 балів)

- Наявність ER-діаграми з мінімум 5 сутностями (4 бали)
- Правильність визначення атрібутів та зв'язків (4 бали)
- Чіткість та читабельність діаграми (2 бали)

### Логічна схема (10 балів)

- Правильність перетворення ER-діаграми в таблиці (4 бали)
- Відповідність третій нормальній формі (4 бали)
- Коректність визначення ключів (2 бали)

### Реалізація в PostgreSQL (15 балів)

- Створення всіх таблиць з правильними типами даних (6 балів)
- Визначення обмежень цілісності (5 балів)
- Створення зовнішніх ключів (4 бали)

### Тестові дані (5 балів)

- Наявність мінімум 10 записів на таблицю (3 бали)
- Реалістичність та різноманітність даних (2 бали)

### SQL-запити (10 балів)

- Прості запити з фільтрацією (2 бали)
- Запити з JOIN (3 бали)
- Агрегатні запити (3 бали)
- Запити з підзапитами (2 бали)

### Консольний застосунок (10 балів)

- Успішне підключення до бази даних (2 бали)
- Реалізація операції створення (Create) (2 бали)
- Реалізація операції читання (Read) (2 бали)
- Реалізація операції оновлення (Update) (2 бали)
- Реалізація операції видалення (Delete) (2 бали)

**Мінімальний поріг для рівня 1: 35 балів (оцінка "задовільно")**

### Рівень 2 - Додаткова функціональність

### Збережені процедури (6 балів)

- Наявність мінімум 3 процедур (2 бали)
- Складність логіки процедур (3 бали)
- Обробка помилок (1 бал)

### Тригери (6 балів)

- Наявність мінімум 2 тригерів (2 бали)
- Коректність роботи тригерів (3 бали)
- Практична цінність тригерів (1 бал)

### Представлення (3 бали)

- Наявність мінімум 2 представлень (1 бал)
- Практична застосовність (2 бали)

### Вебзастосунок (10 балів)

- Коректність роботи вебінтерфейсу (4 бали)
- Реалізація всіх CRUD-операцій (4 бали)
- Валідація введених даних (2 бали)

**Діапазон для рівня 2: 50-74 бали (оцінка "добре")**

### Рівень 3 - Творче розширення

### Аутентифікація (6 балів)

- Система реєстрації користувачів (2 бали)
- Система входу та виходу (2 бали)
- Розмежування прав доступу (2 бали)

### Розширена функціональність (14 балів)

- Логування операцій (3 бали)
- Генерація звітів (3 бали)
- Пошук та фільтрація (2 бали)
- Візуалізація даних (3 бали)
- API endpoints (3 бали)

### Оптимізація та якість коду (6 балів)

- Ефективність запитів та індекси (2 бали)
- Структурованість коду (2 бали)
- Документація та коментарі (2 бали)

**Діапазон для рівня 3: 75-100 балів (оцінка "відмінно")**

### Розподіл оцінок за шкалою

**35-49 балів - "задовільно":**

Виконано основні вимоги рівня 1. Створено концептуальну та логічну моделі, реалізовано базу даних з основними таблицями та обмеженнями цілісності. Написано прості SQL-запити та консольний застосунок з базовими CRUD-операціями. Є окремі недоліки в нормалізації або реалізації, але загалом робота функціональна.

**50-74 бали - "добре":**

Виконано всі вимоги рівня 1 та більшість вимог рівня 2. База даних добре спроектована та нормалізована. Створено збережені процедури, тригери та представлення. Реалізовано повноцінний вебзастосунок з усіма CRUD-операціями та валідацією. Код структурований, запити оптимізовані. Можуть бути незначні недоліки в окремих аспектах роботи.

**75-100 балів - "відмінно":**

Виконано всі вимоги всіх трьох рівнів. Створено професійну інформаційну систему з розширеними можливостями: аутентифікацією, логуванням, генерацією звітів, API, візуалізацією даних. База даних оптимізована, код добре структурований та задокументований. Робота демонструє глибоке розуміння принципів проєктування баз даних та розробки застосунків.

## ⏰ Політика щодо дедлайнів

При порушенні встановленого терміну здачі лабораторної роботи максимальна можлива оцінка становить "добре", незалежно від якості виконаної роботи. Винятки можливі лише за поважних причин, підтверджених документально.

## 📚 Теоретичні відомості

### Етапи розробки бази даних

Процес створення бази даних складається з кількох послідовних етапів, кожен з яких має своє призначення та результати.

**Концептуальне проєктування** передбачає аналіз предметної області та створення моделі даних незалежно від конкретної СУБД. На цьому етапі використовується модель "сутність-зв'язок", яка відображає основні об'єкти предметної області, їхні атрибути та зв'язки між ними. Результатом є ER-діаграма, що служить основою для подальшого проєктування.

**Логічне проєктування** полягає в перетворенні концептуальної моделі в реляційну схему з дотриманням правил нормалізації. На цьому етапі визначаються таблиці, їхні атрибути, первинні та зовнішні ключі, обмеження цілісності. Схема має задовольняти вимоги третьої нормальної форми для усунення аномалій модифікації.

**Фізичне проєктування** включає реалізацію логічної схеми в конкретній СУБД з урахуванням особливостей її роботи. На цьому етапі визначаються типи даних, створюються індекси для оптимізації запитів, розробляються збережені процедури та тригери. Враховуються вимоги до продуктивності та обсягів даних.

### Нормалізація баз даних

Нормалізація є процесом організації атрибутів та відношень бази даних для мінімізації надмірності та попередження аномалій.

**Перша нормальна форма** вимагає атомарності всіх атрибутів. Кожна комірка таблиці має містити одне неподільне значення. Не допускаються повторювані групи атрибутів або масиви значень в одному полі.

**Друга нормальна форма** додатково до вимог 1НФ вимагає відсутності часткових функціональних залежностей. Кожен неключовий атрибут має повністю залежати від усього первинного ключа, а не від його частини. Це актуально для таблиць з складеними ключами.

**Третя нормальна форма** усуває транзитивні залежності між неключовими атрибутами. Кожен неключовий атрибут має залежати тільки від первинного ключа, а не від інших неключових атрибутів.

### Обмеження цілісності

Обмеження цілісності забезпечують коректність та несуперечливість даних у базі.

**Первинний ключ** однозначно ідентифікує кожен запис у таблиці. Він не може містити Null-значення та має бути унікальним. Первинний ключ може складатися з одного або кількох атрибутів.

**Зовнішній ключ** забезпечує посилальну цілісність між таблицями. Значення зовнішнього ключа має або відповідати значенню первинного ключа в пов'язаній таблиці, або бути Null. Це гарантує відсутність посилань на неіснуючі записи.

**Унікальність** забезпечує відсутність дублікатів для певного атрибута або комбінації атрибутів. На відміну від первинного ключа, унікальні обмеження допускають Null-значення.

**Перевірочні обмеження** визначають допустимі значення для атрібутів через логічні умови. Вони можуть перевіряти діапазони значень, формати даних або складні бізнес-правила.

### Збережені процедури та тригери

**Збережені процедури** є іменованими блоками SQL-коду, що зберігаються на сервері бази даних. Вони можуть приймати параметри, виконувати складну логіку обробки даних та повертати результати. Переваги включають покращення продуктивності через компіляцію, зменшення мережевого трафіку та централізацію бізнес-логіки.

**Тригери** автоматично виконуються у відповідь на певні події в базі даних, такі як вставка, оновлення або видалення записів. Вони використовуються для забезпечення складних правил цілісності, аудиту змін, автоматичного обчислення значень та синхронізації даних між таблицями.

### Інтеграція бази даних з застосунком

Для взаємодії застосунку з базою даних використовуються бібліотеки підключення, що реалізують протоколи обміну даними з СУБД.

**Psycopg2** є найпопулярнішою бібліотекою для роботи з PostgreSQL у Python. Вона надає низькорівневий доступ до функціональності PostgreSQL та підтримує всі основні типи даних. Бібліотека забезпечує ефективну роботу з підготовленими запитами та транзакціями.

**SQLAlchemy** є об'єктно-реляційним відображенням (ORM), що дозволяє працювати з базою даних через об'єкти Python. Це спрощує розробку, забезпечує незалежність від конкретної СУБД та автоматизує багато рутинних операцій. SQLAlchemy підтримує міграції схеми та складні запити.

**Підготовлені запити** захищають від SQL-ін'єкцій та покращують продуктивність при повторному виконанні. Замість конкатенації рядків для формування SQL-запитів використовуються параметризовані запити з placeholder для значень.

### Вебфреймворки для роботи з базами даних

**Flask** є мікрофреймворком, що надає базовий функціонал для створення вебзастосунків. Він не нав'язує структуру проєкту та дозволяє обирати компоненти на власний розсуд. Flask добре підходить для невеликих та середніх застосунків з простою архітектурою.

**FastAPI** є сучасним фреймворком для створення API з автоматичною генерацією документації. Він підтримує асинхронне програмування для високої продуктивності та використовує анотації типів Python для валідації даних. FastAPI ідеально підходить для створення RESTful API.

### Використання Docker для бази даних

**Docker** є платформою контейнеризації, що дозволяє запускати застосунки в ізольованих середовищах. Використання Docker для бази даних має кілька переваг.

**Ізоляція середовища** забезпечує незалежність бази даних від операційної системи хоста. Контейнер містить всі необхідні залежності та конфігурації, що усуває проблеми з сумісністю версій.

**Портативність** дозволяє легко переносити базу даних між різними машинами та середовищами. Один і той самий образ Docker може працювати на локальній машині розробника, тестовому сервері та продакшені.

**Швидке розгортання** спрощує початок роботи над проєктом. Замість складного процесу встановлення PostgreSQL достатньо виконати одну команду для запуску контейнера з базою даних.

**Керування версіями** дозволяє легко перемикатися між різними версіями PostgreSQL для тестування сумісності або використання нових функцій.

**Очищення** забезпечує простоту видалення бази даних разом з усіма даними. При видаленні контейнера повністю очищуються всі ресурси без залишкових файлів у системі.

## ▶️ Хід роботи

### Крок 0. Налаштування Docker для PostgreSQL

Перед початком роботи з базою даних рекомендується встановити Docker та налаштувати контейнер PostgreSQL.

**Встановлення Docker:**

Завантажте та встановіть Docker Desktop з офіційного сайту для вашої операційної системи:
- Windows/Mac: https://www.docker.com/products/docker-desktop
- Linux: використовуйте пакетний менеджер вашого дистрибутива

Перевірте успішність встановлення:

```bash
docker --version
docker compose version
```

**Створення docker-compose.yml:**

У кореневій директорії вашого проєкту створіть файл `docker-compose.yml`:

```yaml
services:
  postgres:
    image: postgres:17-alpine
    container_name: bookstore_db
    environment:
      POSTGRES_DB: bookstore
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database:/docker-entrypoint-initdb.d
    restart: unless-stopped

volumes:
  postgres_data:
```

**Пояснення параметрів:**

- `image: postgres:17-alpine` - використовується офіційний образ PostgreSQL версії 17 (актуальна стабільна лінійка) на базі Alpine Linux для зменшення розміру
- `container_name` - зручна назва контейнера для управління
- `environment` - змінні середовища для налаштування бази даних (назва БД, користувач, пароль)
- `ports` - проброс порту 5432 для доступу до бази даних з хост-машини
- `volumes` - збереження даних та автоматичне виконання SQL-скриптів при ініціалізації
- `restart` - політика перезапуску контейнера

**Запуск контейнера:**

```bash
# Запустити базу даних у фоновому режимі
docker compose up -d

# Перевірити статус контейнера
docker compose ps

# Переглянути логи
docker compose logs -f postgres
```

**Підключення до бази даних:**

```bash
# Через Docker CLI
docker exec -it bookstore_db psql -U postgres -d bookstore

# Через psql на хост-машині (якщо встановлено)
psql -h localhost -U postgres -d bookstore

# Через pgAdmin або інший GUI-клієнт
# Host: localhost
# Port: 5432
# Database: bookstore
# Username: postgres
# Password: password
```

**Корисні команди Docker:**

```bash
# Зупинити контейнер
docker compose stop

# Запустити знову
docker compose start

# Повністю видалити контейнер та volume (очистити всі дані)
docker compose down -v

# Перезапустити з оновленою конфігурацією
docker compose up -d --force-recreate

# Виконати SQL-скрипт в контейнері
docker exec -i bookstore_db psql -U postgres -d bookstore < database/create_tables.sql
```

**Автоматична ініціалізація бази даних:**

Усі SQL-скрипти, розміщені в директорії `./database/`, автоматично виконуються при першому запуску контейнера завдяки volume-маунтингу до `/docker-entrypoint-initdb.d`. Файли виконуються в алфавітному порядку, тому рекомендується використовувати префікси:

```
database/
├── 01_create_tables.sql
├── 02_insert_data.sql
├── 03_create_procedures.sql
├── 04_create_triggers.sql
└── 05_create_views.sql
```

**Розширений docker-compose.yml з pgAdmin:**

Для зручності можна додати pgAdmin для візуального управління базою даних:

```yaml
services:
  postgres:
    image: postgres:17-alpine
    container_name: bookstore_db
    environment:
      POSTGRES_DB: bookstore
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database:/docker-entrypoint-initdb.d
    restart: unless-stopped
    networks:
      - db_network

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: bookstore_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres
    restart: unless-stopped
    networks:
      - db_network

volumes:
  postgres_data:

networks:
  db_network:
    driver: bridge
```

Після запуску pgAdmin буде доступний за адресою http://localhost:5050

**Налаштування підключення в Python:**

При використанні Docker параметри підключення залишаються стандартними:

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",  # або '127.0.0.1'
    port=5432,
    database="bookstore",
    user="postgres",
    password="password",
)
```

**Переваги використання Docker:**

- Швидке розгортання без складного встановлення PostgreSQL
- Ізоляція від системного середовища
- Легке керування версіями PostgreSQL
- Можливість запуску кількох баз даних на різних портах
- Простота очищення та перезапуску
- Однакове середовище для всіх розробників команди
- Легка міграція між машинами

### Крок 1. Аналіз предметної області та вибір теми

Почніть з детального аналізу обраної предметної області. Визначте основні об'єкти, які потрібно відобразити в базі даних, та їхні характеристики. Проаналізуйте бізнес-процеси та зв'язки між об'єктами.

Складіть перелік функціональних вимог до системи. Визначте, які операції користувачі виконуватимуть найчастіше, які звіти потрібно формувати, які обмеження має підтримувати система.

Опишіть основні сутності предметної області та їхні атрибути. Для кожної сутності визначте ключові характеристики, які необхідно зберігати. Врахуйте майбутнє розширення системи.

### Крок 2. Створення концептуальної моделі

Розробіть ER-діаграму, що відображає структуру предметної області. Визначте всі сутності, їхні атрибути та зв'язки між ними.

Для кожної сутності визначте первинний ключ. Він має однозначно ідентифікувати кожен екземпляр сутності. Обирайте прості та стабільні атрибути для первинних ключів.

Визначте типи зв'язків між сутностями: один-до-одного, один-до-багатьох або багато-до-багатьох. Для зв'язків багато-до-багатьох створіть проміжні сутності.

Вкажіть кардинальність зв'язків, визначивши мінімальну та максимальну кількість екземплярів, що можуть брати участь у зв'язку. Це допоможе правильно реалізувати обмеження цілісності.

### Крок 3. Логічне проєктування схеми

Перетворіть ER-діаграму в набір таблиць реляційної бази даних. Кожна сутність стає таблицею, атрибути перетворюються на стовпці таблиці.

Для зв'язків один-до-багатьох додайте зовнішній ключ до таблиці на стороні "багато". Для зв'язків багато-до-багатьох створіть окрему таблицю зв'язків з зовнішніми ключами до обох пов'язаних таблиць.

Перевірте схему на відповідність третій нормальній формі. Переконайтеся, що відсутні часткові та транзитивні залежності. За необхідності розбийте таблиці на менші для усунення надмірності.

Визначте обмеження цілісності для всіх таблиць. Вкажіть обов'язкові поля, унікальні значення, діапазони допустимих значень. Це забезпечить коректність даних.

!!! warning

    Код нижче наведено з демонстраційною метою. Для виконання завдань лабораторної роботи необхідно реалізувати власне рішення.



### Крок 4. Реалізація бази даних в PostgreSQL

Створіть SQL-скрипт для створення всіх таблиць у файлі `database/01_create_tables.sql`. Визначте типи даних для кожного стовпця, враховуючи характер даних та обсяги інформації. Додайте всі обмеження цілісності.

```sql
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    publication_year INT CHECK (publication_year > 1000),
    pages INT CHECK (pages > 0),
    price DECIMAL(10, 2) CHECK (price >= 0),
    author_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);
```

Створіть індекси для полів, що часто використовуються в запитах. Індекси на зовнішніх ключах покращують продуктивність операцій об'єднання таблиць.

```sql
CREATE INDEX idx_books_author_id ON books(author_id);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_publication_year ON books(publication_year);
```

Після запуску Docker контейнера цей скрипт автоматично виконається при першій ініціалізації бази даних.

### Крок 5. Наповнення тестовими даними

Підготуйте набір реалістичних тестових даних у файлі `database/02_insert_data.sql`. Дані мають відображати різноманітні сценарії використання системи.

```sql
INSERT INTO authors (first_name, last_name, birth_date, country) VALUES
('Тарас', 'Шевченко', '1814-03-09', 'Україна'),
('Леся', 'Українка', '1871-02-25', 'Україна'),
('Іван', 'Франко', '1856-08-27', 'Україна');

INSERT INTO books (title, isbn, publication_year, pages, price, author_id) VALUES
('Кобзар', '9780123456789', 1840, 350, 250.00, 1),
('Лісова пісня', '9780123456790', 1912, 120, 150.00, 2),
('Захар Беркут', '9780123456791', 1883, 280, 200.00, 3);
```

Переконайтеся, що тестові дані охоплюють граничні випадки та можливі винятки. Це допоможе виявити проблеми в обмеженнях цілісності.

### Крок 6. Створення SQL-запитів

Розробіть набір SQL-запитів для отримання різноманітної інформації з бази даних у файлі `database/queries.sql`. Запити мають демонструвати різні можливості SQL.

Прості запити на вибірку даних з однієї таблиці з фільтрацією та сортуванням:

```sql
-- Запит 1: Книги, видані після 1900 року, відсортовані за ціною
SELECT title, publication_year, price
FROM books
WHERE publication_year >= 1900
ORDER BY price DESC;
```

Запити з об'єднанням таблиць для отримання пов'язаних даних:

```sql
-- Запит 2: Книги українських авторів
SELECT
    a.first_name || ' ' || a.last_name AS author_name,
    b.title,
    b.publication_year
FROM books b
INNER JOIN authors a ON b.author_id = a.author_id
WHERE a.country = 'Україна';
```

Агрегатні запити для обчислення статистики:

```sql
-- Запит 3: Статистика по авторах
SELECT
    a.last_name,
    COUNT(b.book_id) AS books_count,
    AVG(b.price) AS avg_price
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
GROUP BY a.author_id, a.last_name
HAVING COUNT(b.book_id) > 0;
```

Підзапити для складних умов вибірки:

```sql
-- Запит 4: Книги дорожчі за середню ціну
SELECT title, price
FROM books
WHERE price > (SELECT AVG(price) FROM books)
ORDER BY price;
```

Складні запити з кількома JOIN:

```sql
-- Запит 5: Детальна інформація про книги з їх авторами
SELECT
    b.book_id,
    b.title,
    b.isbn,
    a.first_name || ' ' || a.last_name AS author,
    a.country,
    b.publication_year,
    b.pages,
    b.price
FROM books b
INNER JOIN authors a ON b.author_id = a.author_id
ORDER BY b.publication_year DESC, b.title;
```

### Крок 7. Створення збережених процедур

Для рівня 2 розробіть збережені процедури у файлі `database/03_create_procedures.sql` для складних операцій, що включають кілька кроків або складну логіку.

```sql
-- Процедура 1: Додавання книги з автоматичним створенням автора
CREATE OR REPLACE FUNCTION add_book_with_author(
    p_title VARCHAR,
    p_isbn VARCHAR,
    p_year INT,
    p_pages INT,
    p_price DECIMAL,
    p_author_first VARCHAR,
    p_author_last VARCHAR
) RETURNS INT AS $$
DECLARE
    v_author_id INT;
    v_book_id INT;
BEGIN
    -- Перевірка існування автора
    SELECT author_id INTO v_author_id
    FROM authors
    WHERE first_name = p_author_first AND last_name = p_author_last;

    -- Створення автора, якщо не існує
    IF v_author_id IS NULL THEN
        INSERT INTO authors (first_name, last_name)
        VALUES (p_author_first, p_author_last)
        RETURNING author_id INTO v_author_id;
    END IF;

    -- Створення книги
    INSERT INTO books (title, isbn, publication_year, pages, price, author_id)
    VALUES (p_title, p_isbn, p_year, p_pages, p_price, v_author_id)
    RETURNING book_id INTO v_book_id;

    RETURN v_book_id;
END;
$$ LANGUAGE plpgsql;

-- Процедура 2: Оновлення цін на книги автора з відсотковою знижкою
CREATE OR REPLACE FUNCTION update_author_books_price(
    p_author_id INT,
    p_discount_percent DECIMAL
) RETURNS TABLE(book_id INT, old_price DECIMAL, new_price DECIMAL) AS $$
BEGIN
    RETURN QUERY
    UPDATE books
    SET price = price * (1 - p_discount_percent / 100)
    WHERE author_id = p_author_id
    RETURNING books.book_id,
              price / (1 - p_discount_percent / 100) AS old_price,
              books.price AS new_price;
END;
$$ LANGUAGE plpgsql;

-- Процедура 3: Отримання статистики по авторові
CREATE OR REPLACE FUNCTION get_author_statistics(p_author_id INT)
RETURNS TABLE(
    total_books INT,
    avg_price DECIMAL,
    min_price DECIMAL,
    max_price DECIMAL,
    total_pages INT,
    earliest_year INT,
    latest_year INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INT AS total_books,
        AVG(b.price)::DECIMAL(10,2) AS avg_price,
        MIN(b.price)::DECIMAL(10,2) AS min_price,
        MAX(b.price)::DECIMAL(10,2) AS max_price,
        SUM(b.pages)::INT AS total_pages,
        MIN(b.publication_year)::INT AS earliest_year,
        MAX(b.publication_year)::INT AS latest_year
    FROM books b
    WHERE b.author_id = p_author_id;
END;
$$ LANGUAGE plpgsql;
```

### Крок 8. Створення тригерів

Розробіть тригери у файлі `database/04_create_triggers.sql` для автоматизації процесів та підтримки складних правил цілісності.

```sql
-- Таблиця для аудиту змін цін
CREATE TABLE book_audit (
    audit_id SERIAL PRIMARY KEY,
    book_id INT,
    operation VARCHAR(10),
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    changed_by VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Тригер 1: Логування змін цін книг
CREATE OR REPLACE FUNCTION log_book_price_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.price != NEW.price THEN
        INSERT INTO book_audit (book_id, operation, old_price, new_price, changed_by)
        VALUES (NEW.book_id, 'UPDATE', OLD.price, NEW.price, current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER book_price_audit
AFTER UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION log_book_price_change();

-- Тригер 2: Автоматичне оновлення timestamp при модифікації
CREATE OR REPLACE FUNCTION update_modified_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER book_modified_timestamp
BEFORE UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION update_modified_timestamp();

-- Тригер 3: Валідація даних перед вставкою
CREATE OR REPLACE FUNCTION validate_book_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Перевірка року видання
    IF NEW.publication_year > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'Рік видання не може бути в майбутньому';
    END IF;

    -- Перевірка кількості сторінок
    IF NEW.pages < 1 OR NEW.pages > 10000 THEN
        RAISE EXCEPTION 'Некоректна кількість сторінок';
    END IF;

    -- Перевірка ціни
    IF NEW.price < 0 THEN
        RAISE EXCEPTION 'Ціна не може бути від''ємною';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_book_before_insert
BEFORE INSERT OR UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION validate_book_data();
```

### Крок 9. Створення представлень

Розробіть представлення у файлі `database/05_create_views.sql` для спрощення доступу до часто використовуваних комбінацій даних.

```sql
-- Представлення 1: Книги з інформацією про авторів
CREATE VIEW books_with_authors AS
SELECT
    b.book_id,
    b.title,
    b.isbn,
    b.publication_year,
    b.pages,
    b.price,
    a.author_id,
    a.first_name || ' ' || a.last_name AS author_name,
    a.country AS author_country,
    a.birth_date AS author_birth_date
FROM books b
INNER JOIN authors a ON b.author_id = a.author_id;

-- Представлення 2: Статистика по авторах
CREATE VIEW author_statistics AS
SELECT
    a.author_id,
    a.first_name || ' ' || a.last_name AS author_name,
    a.country,
    COUNT(b.book_id) AS total_books,
    AVG(b.price)::DECIMAL(10,2) AS avg_book_price,
    SUM(b.pages) AS total_pages,
    MIN(b.publication_year) AS first_publication,
    MAX(b.publication_year) AS last_publication
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
GROUP BY a.author_id, a.first_name, a.last_name, a.country;

-- Представлення 3: Найдорожчі книги кожного автора
CREATE VIEW expensive_books_by_author AS
SELECT DISTINCT ON (a.author_id)
    a.author_id,
    a.first_name || ' ' || a.last_name AS author_name,
    b.title AS most_expensive_book,
    b.price AS highest_price
FROM authors a
INNER JOIN books b ON a.author_id = b.author_id
ORDER BY a.author_id, b.price DESC;
```

### Крок 10. Розробка консольного застосунку

Створіть Python-застосунок для базових операцій з базою даних. Встановіть необхідні бібліотеки:

```bash
pip install psycopg2-binary
```

Створіть файл `requirements.txt`:

```
psycopg2-binary==2.9.9
```

Напишіть модуль для підключення до бази даних у файлі `console_app/database.py`:

```python
import psycopg2
from psycopg2 import sql


class DatabaseConnection:
    def __init__(
        self,
        dbname="bookstore",
        user="postgres",
        password="password",
        host="localhost",
        port=5432,
    ):
        self.conn_params = {
            "dbname": dbname,
            "user": user,
            "password": password,
            "host": host,
            "port": port,
        }
        self.conn = None

    def connect(self):
        try:
            self.conn = psycopg2.connect(**self.conn_params)
            print("Успішне підключення до бази даних")
        except Exception as e:
            print(f"Помилка підключення: {e}")

    def disconnect(self):
        if self.conn:
            self.conn.close()
            print("З'єднання закрито")

    def execute_query(self, query, params=None):
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, params)
            self.conn.commit()
            return cursor
        except Exception as e:
            self.conn.rollback()
            print(f"Помилка виконання запиту: {e}")
            return None
```

Реалізуйте функції для операцій CRUD у файлі `console_app/main.py`:

```python
from database import DatabaseConnection


def add_book(db, title, isbn, year, pages, price, author_id):
    query = """
        INSERT INTO books (title, isbn, publication_year, pages, price, author_id)
        VALUES (%s, %s, %s, %s, %s, %s)
        RETURNING book_id
    """
    cursor = db.execute_query(
        query, (title, isbn, year, pages, price, author_id)
    )
    if cursor:
        book_id = cursor.fetchone()[0]
        print(f"Книгу додано з ID: {book_id}")
        return book_id
    return None


def get_all_books(db):
    query = """
        SELECT b.book_id, b.title, b.isbn, b.publication_year,
               b.pages, b.price,
               a.first_name || ' ' || a.last_name AS author
        FROM books b
        INNER JOIN authors a ON b.author_id = a.author_id
        ORDER BY b.title
    """
    cursor = db.execute_query(query)
    if cursor:
        return cursor.fetchall()
    return []


def get_all_authors(db):
    query = "SELECT author_id, first_name, last_name, country FROM authors ORDER BY last_name"
    cursor = db.execute_query(query)
    if cursor:
        return cursor.fetchall()
    return []


def update_book_price(db, book_id, new_price):
    query = "UPDATE books SET price = %s WHERE book_id = %s"
    cursor = db.execute_query(query, (new_price, book_id))
    if cursor:
        print(f"Ціну книги ID {book_id} оновлено")


def delete_book(db, book_id):
    query = "DELETE FROM books WHERE book_id = %s"
    cursor = db.execute_query(query, (book_id,))
    if cursor:
        print(f"Книгу ID {book_id} видалено")


def search_books(db, search_term):
    query = """
        SELECT b.book_id, b.title, b.isbn, b.publication_year,
               a.first_name || ' ' || a.last_name AS author
        FROM books b
        INNER JOIN authors a ON b.author_id = a.author_id
        WHERE LOWER(b.title) LIKE LOWER(%s)
           OR LOWER(a.first_name || ' ' || a.last_name) LIKE LOWER(%s)
        ORDER BY b.title
    """
    search_pattern = f"%{search_term}%"
    cursor = db.execute_query(query, (search_pattern, search_pattern))
    if cursor:
        return cursor.fetchall()
    return []


def main_menu():
    print("\n" + "=" * 50)
    print("СИСТЕМА УПРАВЛІННЯ КНИГАМИ")
    print("=" * 50)
    print("1. Переглянути всі книги")
    print("2. Переглянути всіх авторів")
    print("3. Додати нову книгу")
    print("4. Оновити ціну книги")
    print("5. Видалити книгу")
    print("6. Пошук книг")
    print("7. Статистика по авторах")
    print("0. Вихід")
    print("=" * 50)
    return input("Оберіть опцію: ")


def display_books(books):
    if not books:
        print("Книги не знайдено")
        return

    print("\n" + "-" * 120)
    print(
        f"{'ID':<5} {'Назва':<30} {'ISBN':<15} {'Рік':<6} {'Стор.':<7} {'Ціна':<10} {'Автор':<30}"
    )
    print("-" * 120)
    for book in books:
        print(
            f"{book[0]:<5} {book[1]:<30} {book[2]:<15} {book[3]:<6} {book[4]:<7} {book[5]:<10} {book[6]:<30}"
        )
    print("-" * 120)


def display_authors(authors):
    if not authors:
        print("Автори не знайдено")
        return

    print("\n" + "-" * 80)
    print(f"{'ID':<5} {"Ім'я":<20} {'Прізвище':<20} {'Країна':<30}")
    print("-" * 80)
    for author in authors:
        print(
            f"{author[0]:<5} {author[1]:<20} {author[2]:<20} {author[3]:<30}"
        )
    print("-" * 80)


def main():
    db = DatabaseConnection()
    db.connect()

    if not db.conn:
        print("Не вдалося підключитися до бази даних")
        return

    while True:
        choice = main_menu()

        if choice == "1":
            books = get_all_books(db)
            display_books(books)

        elif choice == "2":
            authors = get_all_authors(db)
            display_authors(authors)

        elif choice == "3":
            print("\n--- Додавання нової книги ---")
            title = input("Назва: ")
            isbn = input("ISBN: ")
            year = int(input("Рік видання: "))
            pages = int(input("Кількість сторінок: "))
            price = float(input("Ціна: "))

            authors = get_all_authors(db)
            display_authors(authors)
            author_id = int(input("\nID автора: "))

            add_book(db, title, isbn, year, pages, price, author_id)

        elif choice == "4":
            books = get_all_books(db)
            display_books(books)
            book_id = int(input("\nID книги для оновлення: "))
            new_price = float(input("Нова ціна: "))
            update_book_price(db, book_id, new_price)

        elif choice == "5":
            books = get_all_books(db)
            display_books(books)
            book_id = int(input("\nID книги для видалення: "))
            confirm = input(
                f"Ви впевнені, що хочете видалити книгу ID {book_id}? (так/ні): "
            )
            if confirm.lower() == "так":
                delete_book(db, book_id)

        elif choice == "6":
            search_term = input("\nВведіть назву книги або автора: ")
            books = search_books(db, search_term)
            display_books(books)

        elif choice == "7":
            query = "SELECT * FROM author_statistics ORDER BY total_books DESC"
            cursor = db.execute_query(query)
            if cursor:
                stats = cursor.fetchall()
                print("\n" + "-" * 100)
                print(
                    f"{'Автор':<30} {'Країна':<15} {'Книг':<8} {'Сер. ціна':<12} {'Всього стор.':<15}"
                )
                print("-" * 100)
                for stat in stats:
                    print(
                        f"{stat[1]:<30} {stat[2]:<15} {stat[3]:<8} {stat[4]:<12} {stat[5]:<15}"
                    )
                print("-" * 100)

        elif choice == "0":
            print("\nДякуємо за використання системи!")
            break

        else:
            print("\n❌ Невірна опція! Спробуйте ще раз.")

        input("\nНатисніть Enter для продовження...")

    db.disconnect()


if __name__ == "__main__":
    main()
```

### Крок 11. Створення вебзастосунку (рівень 2)

Встановіть Flask та необхідні розширення:

```bash
pip install flask flask-wtf
```

Оновіть `requirements.txt`:

```
psycopg2-binary==2.9.9
flask==3.1.0
flask-wtf==1.2.1
```

Створіть структуру проєкту:

```
bookstore_app/
├── app.py
├── database.py
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── books.html
│   ├── add_book.html
│   └── edit_book.html
└── static/
    └── style.css
```

Напишіть основний файл застосунку `web_app/app.py`:

```python
from flask import Flask, render_template, request, redirect, url_for, flash
from database import DatabaseConnection

app = Flask(__name__)
app.secret_key = "your-secret-key-here-change-in-production"

# Підключення до бази даних в Docker контейнері
db = DatabaseConnection(
    dbname="bookstore",
    user="postgres",
    password="password",
    host="localhost",  # Якщо Flask запускається на хості
    port=5432,
)
db.connect()


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/books")
def books():
    query = """
        SELECT b.book_id, b.title, b.isbn, b.publication_year,
               b.pages, b.price,
               a.first_name || ' ' || a.last_name AS author
        FROM books b
        INNER JOIN authors a ON b.author_id = a.author_id
        ORDER BY b.title
    """
    cursor = db.execute_query(query)
    books_list = cursor.fetchall() if cursor else []
    return render_template("books.html", books=books_list)


@app.route("/books/add", methods=["GET", "POST"])
def add_book():
    if request.method == "POST":
        title = request.form["title"]
        isbn = request.form["isbn"]
        year = int(request.form["year"])
        pages = int(request.form["pages"])
        price = float(request.form["price"])
        author_id = int(request.form["author_id"])

        query = """
            INSERT INTO books (title, isbn, publication_year, pages, price, author_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor = db.execute_query(
            query, (title, isbn, year, pages, price, author_id)
        )

        if cursor:
            flash("Книгу успішно додано!", "success")
            return redirect(url_for("books"))
        else:
            flash("Помилка додавання книги", "error")

    authors_query = "SELECT author_id, first_name, last_name FROM authors ORDER BY last_name"
    cursor = db.execute_query(authors_query)
    authors = cursor.fetchall() if cursor else []

    return render_template("add_book.html", authors=authors)


@app.route("/books/edit/<int:book_id>", methods=["GET", "POST"])
def edit_book(book_id):
    if request.method == "POST":
        title = request.form["title"]
        price = float(request.form["price"])
        pages = int(request.form["pages"])

        query = "UPDATE books SET title = %s, price = %s, pages = %s WHERE book_id = %s"
        cursor = db.execute_query(query, (title, price, pages, book_id))

        if cursor:
            flash("Книгу успішно оновлено!", "success")
            return redirect(url_for("books"))
        else:
            flash("Помилка оновлення книги", "error")

    query = """
        SELECT b.*, a.first_name || ' ' || a.last_name AS author_name
        FROM books b
        INNER JOIN authors a ON b.author_id = a.author_id
        WHERE b.book_id = %s
    """
    cursor = db.execute_query(query, (book_id,))
    book = cursor.fetchone() if cursor else None

    return render_template("edit_book.html", book=book)


@app.route("/books/delete/<int:book_id>")
def delete_book(book_id):
    query = "DELETE FROM books WHERE book_id = %s"
    cursor = db.execute_query(query, (book_id,))

    if cursor:
        flash("Книгу успішно видалено!", "success")
    else:
        flash("Помилка видалення книги", "error")

    return redirect(url_for("books"))


@app.route("/authors")
def authors():
    query = "SELECT * FROM author_statistics ORDER BY total_books DESC"
    cursor = db.execute_query(query)
    authors_list = cursor.fetchall() if cursor else []
    return render_template("authors.html", authors=authors_list)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
```

Створіть базовий HTML-шаблон `web_app/templates/base.html`:

```html
<!DOCTYPE html>
<html lang="uk">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Книжковий магазин{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <nav>
        <div class="nav-container">
            <h1>📚 Книжковий магазин</h1>
            <ul>
                <li><a href="{{ url_for('index') }}">Головна</a></li>
                <li><a href="{{ url_for('books') }}">Книги</a></li>
                <li><a href="{{ url_for('authors') }}">Автори</a></li>
            </ul>
        </div>
    </nav>

    <main class="container">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, message in messages %}
                    <div class="alert alert-{{ category }}">
                        {{ message }}
                        <button class="close-btn" onclick="this.parentElement.remove()">×</button>
                    </div>
                {% endfor %}
            {% endif %}
        {% endwith %}

        {% block content %}{% endblock %}
    </main>

    <footer>
        <p>&copy; 2025 Книжковий магазин. Лабораторна робота №4</p>
    </footer>
</body>
</html>
```

Створіть шаблон для відображення списку книг `web_app/templates/books.html`:

```html
{% extends "base.html" %}

{% block title %}Список книг{% endblock %}

{% block content %}
<div class="page-header">
    <h1>📖 Каталог книг</h1>
    <a href="{{ url_for('add_book') }}" class="btn btn-primary">+ Додати книгу</a>
</div>

<div class="table-container">
    <table class="data-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Назва</th>
                <th>ISBN</th>
                <th>Рік</th>
                <th>Сторінок</th>
                <th>Ціна</th>
                <th>Автор</th>
                <th>Дії</th>
            </tr>
        </thead>
        <tbody>
            {% for book in books %}
            <tr>
                <td>{{ book[0] }}</td>
                <td>{{ book[1] }}</td>
                <td>{{ book[2] }}</td>
                <td>{{ book[3] }}</td>
                <td>{{ book[4] }}</td>
                <td>{{ book[5] }} грн</td>
                <td>{{ book[6] }}</td>
                <td class="actions">
                    <a href="{{ url_for('edit_book', book_id=book[0]) }}" class="btn btn-small btn-edit">✏️ Редагувати</a>
                    <a href="{{ url_for('delete_book', book_id=book[0]) }}"
                       class="btn btn-small btn-delete"
                       onclick="return confirm('Ви впевнені, що хочете видалити цю книгу?')">🗑️ Видалити</a>
                </td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
</div>
{% endblock %}
```

Створіть файл стилів `web_app/static/style.css`:

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f5f5f5;
    line-height: 1.6;
}

nav {
    background-color: #2c3e50;
    color: white;
    padding: 1rem 0;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.nav-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

nav h1 {
    font-size: 1.5rem;
}

nav ul {
    list-style: none;
    display: flex;
    gap: 2rem;
}

nav a {
    color: white;
    text-decoration: none;
    transition: color 0.3s;
}

nav a:hover {
    color: #3498db;
}

.container {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 2rem;
    min-height: calc(100vh - 200px);
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.page-header h1 {
    color: #2c3e50;
}

.btn {
    display: inline-block;
    padding: 0.75rem 1.5rem;
    text-decoration: none;
    border-radius: 5px;
    transition: all 0.3s;
    border: none;
    cursor: pointer;
    font-size: 1rem;
}

.btn-primary {
    background-color: #3498db;
    color: white;
}

.btn-primary:hover {
    background-color: #2980b9;
}

.btn-small {
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
}

.btn-edit {
    background-color: #f39c12;
    color: white;
}

.btn-edit:hover {
    background-color: #e67e22;
}

.btn-delete {
    background-color: #e74c3c;
    color: white;
}

.btn-delete:hover {
    background-color: #c0392b;
}

.table-container {
    background: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    overflow: hidden;
}

.data-table {
    width: 100%;
    border-collapse: collapse;
}

.data-table thead {
    background-color: #34495e;
    color: white;
}

.data-table th,
.data-table td {
    padding: 1rem;
    text-align: left;
}

.data-table tbody tr:nth-child(even) {
    background-color: #f8f9fa;
}

.data-table tbody tr:hover {
    background-color: #e8f4f8;
}

.actions {
    display: flex;
    gap: 0.5rem;
}

.alert {
    padding: 1rem;
    border-radius: 5px;
    margin-bottom: 1rem;
    position: relative;
}

.alert-success {
    background-color: #d4edda;
    border-left: 4px solid #28a745;
    color: #155724;
}

.alert-error {
    background-color: #f8d7da;
    border-left: 4px solid #dc3545;
    color: #721c24;
}

.close-btn {
    position: absolute;
    right: 1rem;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: inherit;
}

footer {
    background-color: #2c3e50;
    color: white;
    text-align: center;
    padding: 2rem;
    margin-top: 3rem;
}

.form-container {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    max-width: 600px;
    margin: 0 auto;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    color: #2c3e50;
    font-weight: 500;
}

.form-group input,
.form-group select {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 5px;
    font-size: 1rem;
}

.form-group input:focus,
.form-group select:focus {
    outline: none;
    border-color: #3498db;
}

.form-actions {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
}
```

### Крок 12. Розширена функціональність (рівень 3)

Для досягнення рівня 3 додайте систему аутентифікації користувачів. Створіть таблицю для зберігання облікових записів у файлі `database/06_create_users.sql`:

```sql
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Додавання адміністратора за замовчуванням
-- Пароль: admin123 (у реальному проєкті використовуйте хешування)
INSERT INTO users (username, password_hash, email, role) VALUES
('admin', 'admin123', 'admin@bookstore.com', 'admin');
```

Реалізуйте механізм логування операцій у файлі `database/07_create_audit.sql`:

```sql
CREATE TABLE activity_log (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Функція для логування операцій
CREATE OR REPLACE FUNCTION log_activity(
    p_user_id INT,
    p_action VARCHAR,
    p_table_name VARCHAR,
    p_record_id INT,
    p_details TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO activity_log (user_id, action, table_name, record_id, details)
    VALUES (p_user_id, p_action, p_table_name, p_record_id, p_details);
END;
$$ LANGUAGE plpgsql;
```

Додайте генерацію звітів у форматі PDF у файлі `web_app/reports.py`:

```python
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate,
    Table,
    TableStyle,
    Paragraph,
    Spacer,
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from datetime import datetime


def generate_books_report(books, filename="books_report.pdf"):
    """
    Генерація PDF-звіту зі списком книг
    """
    doc = SimpleDocTemplate(filename, pagesize=A4)
    elements = []
    styles = getSampleStyleSheet()

    # Заголовок звіту
    title_style = ParagraphStyle(
        "CustomTitle",
        parent=styles["Heading1"],
        fontSize=24,
        textColor=colors.HexColor("#2c3e50"),
        spaceAfter=30,
        alignment=1,  # Центрування
    )

    title = Paragraph(f"Звіт про книги", title_style)
    elements.append(title)

    # Дата генерації
    date_text = Paragraph(
        f"Дата формування: {datetime.now().strftime('%d.%m.%Y %H:%M')}",
        styles["Normal"],
    )
    elements.append(date_text)
    elements.append(Spacer(1, 20))

    # Таблиця з даними
    data = [["№", "Назва", "ISBN", "Рік", "Ціна, грн", "Автор"]]

    for idx, book in enumerate(books, 1):
        data.append(
            [
                str(idx),
                str(book[1])[:30],  # Обмеження довжини назви
                str(book[2]),
                str(book[3]),
                f"{book[5]:.2f}",
                str(book[6])[:25],  # Обмеження довжини імені автора
            ]
        )

    # Створення таблиці
    table = Table(
        data,
        colWidths=[
            0.5 * inch,
            2.5 * inch,
            1.2 * inch,
            0.8 * inch,
            1 * inch,
            2 * inch,
        ],
    )

    # Стилізація таблиці
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#34495e")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.whitesmoke),
                ("ALIGN", (0, 0), (-1, -1), "LEFT"),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, 0), 12),
                ("BOTTOMPADDING", (0, 0), (-1, 0), 12),
                ("BACKGROUND", (0, 1), (-1, -1), colors.beige),
                ("GRID", (0, 0), (-1, -1), 1, colors.black),
                (
                    "ROWBACKGROUNDS",
                    (0, 1),
                    (-1, -1),
                    [colors.white, colors.HexColor("#f8f9fa")],
                ),
            ]
        )
    )

    elements.append(table)

    # Статистика
    elements.append(Spacer(1, 20))
    total_books = len(books)
    total_price = sum(book[5] for book in books)
    avg_price = total_price / total_books if total_books > 0 else 0

    stats_text = f"""
    <b>Статистика:</b><br/>
    Всього книг: {total_books}<br/>
    Загальна вартість: {total_price:.2f} грн<br/>
    Середня ціна: {avg_price:.2f} грн
    """

    stats = Paragraph(stats_text, styles["Normal"])
    elements.append(stats)

    # Генерація PDF
    doc.build(elements)
    return filename
```

Створіть API endpoints для інтеграції у файлі `web_app/api.py`:

```python
from flask import jsonify, request
from functools import wraps


def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get("X-API-Key")
        if api_key != "your-secret-api-key-here":
            return jsonify({"error": "Invalid API key"}), 401
        return f(*args, **kwargs)

    return decorated_function


def setup_api_routes(app, db):
    @app.route("/api/books", methods=["GET"])
    @require_api_key
    def api_books():
        query = "SELECT * FROM books_with_authors"
        cursor = db.execute_query(query)

        if cursor:
            books = cursor.fetchall()
            books_list = [
                {
                    "id": book[0],
                    "title": book[1],
                    "isbn": book[2],
                    "year": book[3],
                    "pages": book[4],
                    "price": float(book[5]),
                    "author_id": book[6],
                    "author": book[7],
                    "country": book[8],
                }
                for book in books
            ]
            return jsonify(
                {"success": True, "count": len(books_list), "data": books_list}
            )

        return jsonify({"error": "Failed to fetch books"}), 500

    @app.route("/api/books/<int:book_id>", methods=["GET"])
    @require_api_key
    def api_book_detail(book_id):
        query = "SELECT * FROM books_with_authors WHERE book_id = %s"
        cursor = db.execute_query(query, (book_id,))

        if cursor:
            book = cursor.fetchone()
            if book:
                return jsonify(
                    {
                        "success": True,
                        "data": {
                            "id": book[0],
                            "title": book[1],
                            "isbn": book[2],
                            "year": book[3],
                            "pages": book[4],
                            "price": float(book[5]),
                            "author_id": book[6],
                            "author": book[7],
                            "country": book[8],
                        },
                    }
                )

        return jsonify({"error": "Book not found"}), 404

    @app.route("/api/books", methods=["POST"])
    @require_api_key
    def api_create_book():
        data = request.get_json()

        required_fields = [
            "title",
            "isbn",
            "publication_year",
            "pages",
            "price",
            "author_id",
        ]

        if not all(field in data for field in required_fields):
            return jsonify({"error": "Missing required fields"}), 400

        query = """
            INSERT INTO books (title, isbn, publication_year, pages, price, author_id)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING book_id
        """

        cursor = db.execute_query(
            query,
            (
                data["title"],
                data["isbn"],
                data["publication_year"],
                data["pages"],
                data["price"],
                data["author_id"],
            ),
        )

        if cursor:
            book_id = cursor.fetchone()[0]
            return jsonify(
                {
                    "success": True,
                    "message": "Book created successfully",
                    "book_id": book_id,
                }
            ), 201

        return jsonify({"error": "Failed to create book"}), 500
```

Додайте візуалізацію даних у файлі `web_app/charts.py`:

```python
import matplotlib

matplotlib.use("Agg")  # Використовувати backend без GUI
import matplotlib.pyplot as plt
import io
import base64


def create_author_statistics_chart(db):
    """
    Створення графіка статистики по авторах
    """
    query = """
        SELECT a.last_name, COUNT(b.book_id) as books_count
        FROM authors a
        LEFT JOIN books b ON a.author_id = b.author_id
        GROUP BY a.author_id, a.last_name
        ORDER BY books_count DESC
        LIMIT 10
    """
    cursor = db.execute_query(query)
    data = cursor.fetchall() if cursor else []

    if not data:
        return None

    authors = [row[0] for row in data]
    counts = [row[1] for row in data]

    plt.figure(figsize=(12, 6))
    bars = plt.bar(authors, counts, color="#3498db")

    # Додавання значень над стовпцями
    for bar in bars:
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2.0,
            height,
            f"{int(height)}",
            ha="center",
            va="bottom",
        )

    plt.xlabel("Автори", fontsize=12)
    plt.ylabel("Кількість книг", fontsize=12)
    plt.title(
        "Топ-10 авторів за кількістю книг", fontsize=14, fontweight="bold"
    )
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()

    # Конвертація в base64
    img = io.BytesIO()
    plt.savefig(img, format="png", dpi=100, bbox_inches="tight")
    img.seek(0)
    plot_url = base64.b64encode(img.getvalue()).decode()
    plt.close()

    return plot_url


def create_price_distribution_chart(db):
    """
    Створення графіка розподілу цін
    """
    query = "SELECT price FROM books ORDER BY price"
    cursor = db.execute_query(query)
    data = cursor.fetchall() if cursor else []

    if not data:
        return None

    prices = [row[0] for row in data]

    plt.figure(figsize=(10, 6))
    plt.hist(prices, bins=15, color="#2ecc71", edgecolor="black", alpha=0.7)
    plt.xlabel("Ціна (грн)", fontsize=12)
    plt.ylabel("Кількість книг", fontsize=12)
    plt.title("Розподіл цін на книги", fontsize=14, fontweight="bold")
    plt.grid(axis="y", alpha=0.3)
    plt.tight_layout()

    img = io.BytesIO()
    plt.savefig(img, format="png", dpi=100, bbox_inches="tight")
    img.seek(0)
    plot_url = base64.b64encode(img.getvalue()).decode()
    plt.close()

    return plot_url
```


## Форма здачі роботи

1. Лабораторну роботу здати через систему Moodle у вигляді:
    - Посилання на Git-репозиторій з проєктом (GitHub).
    - Звіт у форматі Markdown. У звіт додати опис виконаних запитів та результатів. Включити скріншоти. Завантажити звіт зі скріншотами в репозиторій на GitHub.
2. Захистити лабораторну перед викладачем.

**Структура репозиторію:**

```
lab04-database/
├── README.md
├── docker-compose.yml
├── docs/
│   ├── conceptual_model.png
│   ├── logical_schema.md
│   └── report.md
├── database/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   ├── 03_create_procedures.sql
│   ├── 04_create_triggers.sql
│   ├── 05_create_views.sql
│   ├── 06_create_users.sql (рівень 3)
│   ├── 07_create_audit.sql (рівень 3)
│   └── queries.sql
├── console_app/
│   ├── main.py
│   ├── database.py
│   └── requirements.txt
└── web_app/
    ├── app.py
    ├── database.py
    ├── api.py (рівень 3)
    ├── reports.py (рівень 3)
    ├── charts.py (рівень 3)
    ├── templates/
    ├── static/
    └── requirements.txt
```

**Структура звіту (report.md):**

```markdown
# Звіт з лабораторної роботи №4

## Загальна інформація
- ПІБ студента:
- Група:
- Варіант (предметна область):
- Рівень виконання:

## Опис предметної області
[Детальний опис обраної предметної області]

## Концептуальна модель
[Опис сутностей, атрибутів та зв'язків]
![ER-діаграма](../docs/conceptual_model.png)

## Логічна схема
[Опис таблиць та зв'язків між ними]

## Реалізація в PostgreSQL
[Основні SQL-скрипти створення таблиць]

## Налаштування Docker
[Опис конфігурації docker-compose.yml та процесу запуску]

## SQL-запити
[Приклади запитів з поясненням]

## Консольний застосунок
[Скріншоти роботи застосунку]

## Вебзастосунок (якщо реалізовано)
[Скріншоти інтерфейсу]

## Розширена функціональність (рівень 3, якщо реалізовано)
[Опис реалізованих додаткових можливостей]

## Висновки
[Що було зроблено, які навички здобуто, які труднощі виникли]
```

[🔼 Здати лабораторну роботу](https://moodle.vcolnuft.volyn.ua/moodle/course/view.php?id=32#section-2)


## ❓ Контрольні запитання

1. Які етапи включає процес розробки бази даних та яке призначення кожного етапу?
2. У чому полягає різниця між концептуальною, логічною та фізичною моделями даних?
3. Що таке нормалізація бази даних і чому вона важлива? Опишіть вимоги третьої нормальної форми.
4. Які типи обмежень цілісності існують у реляційних базах даних та для чого вони використовуються?
5. Чим відрізняється первинний ключ від зовнішнього ключа? Наведіть приклади їх використання.
6. Які типи зв'язків можуть існувати між таблицями в реляційній базі даних? Як вони реалізуються?
7. Що таке збережена процедура і які переваги вона надає порівняно зі звичайними SQL-запитами?
8. Для чого використовуються тригери в базах даних? Наведіть приклади практичного застосування.
9. Яка різниця між операторами JOIN у SQL? Коли використовується кожен з них?
10. Що таке представлення (VIEW) і в яких ситуаціях доцільно його використовувати?
11. Як забезпечується захист від SQL-ін'єкцій при розробці застосунків, що працюють з базами даних?
12. Які переваги та недоліки має використання ORM порівняно з прямим написанням SQL-запитів?
13. Яким чином індекси покращують продуктивність бази даних? Чи завжди варто створювати індекси?
14. Що таке транзакція в контексті баз даних і які властивості ACID вона має забезпечувати?
15. Які кроки необхідно виконати для оптимізації продуктивності SQL-запитів?
16. Які переваги надає використання Docker для розгортання бази даних у проєкті?
17. Як налаштувати підключення до PostgreSQL, що працює в Docker контейнері?
