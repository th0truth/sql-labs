# Лабораторна робота 06 Робота з СУБД MongoDB та реалізація операцій

## 🎯 Мета роботи

Освоїти принципи роботи з NoSQL документо-орієнтованою базою даних MongoDB, навчитися виконувати базові операції створення, читання, оновлення та видалення документів, опанувати механізми запитів та індексування, розвинути розуміння відмінностей між реляційним та документним підходами до зберігання даних.

## ✅ Завдання

### Рівень 1

1. Встановити MongoDB Community Edition та MongoDB Compass.
2. Створити базу даних `library` з колекціями `books`, `authors`, `users`.
3. Додати по 10 документів в кожну колекцію з використанням різних структур (вкладені документи, масиви).
4. Виконати базові CRUD операції:
    - Вставка одного та багатьох документів.
    - Пошук документів з різними умовами (рівність, порівняння, логічні оператори).
    - Оновлення полів документів.
    - Видалення документів за умовами.
5. Створити три різних індекси для оптимізації пошуку.
6. Порівняти швидкість виконання запитів з індексами та без них.

### Рівень 2

Додатково до рівня 1:

1. Реалізувати складні запити з використанням операторів `$and`, `$or`, `$in`, `$regex`.
2. Виконати агрегаційні запити з використанням pipeline:
    - Підрахунок кількості документів за категоріями.
    - Обчислення середніх значень.
    - Групування та сортування результатів.
3. Створити складені (compound) індекси для оптимізації складних запитів.
4. Реалізувати текстовий пошук з індексом типу `text`.
5. Використати оператор `$lookup` для об'єднання даних з різних колекцій (аналог JOIN).
6. Створити представлення (view) для часто використовуваних запитів.

### Рівень 3

Додатково до рівня 2:

1. Реалізувати валідацію схеми документів з використанням JSON Schema.
2. Створити геопросторові індекси та виконати запити на основі координат.
3. Розробити систему версіонування документів з збереженням історії змін.
4. Реалізувати повнотекстовий пошук з підтримкою української мови.
5. Налаштувати реплікацію даних між кількома інстансами MongoDB (якщо можливо).
6. Створити скрипт для автоматизованого резервного копіювання з використанням `mongodump`.
7. Розробити порівняльний аналіз між реляційним та документним підходом для конкретної предметної області.

## 🖥️ Програмне забезпечення

- СКБД MongoDB [Download MongoDB Community Server | MongoDB](https://www.mongodb.com/try/download/community)
- MongoDB Shell (`mongosh`) — https://www.mongodb.com/try/download/shell
- MongoDB Compass — https://www.mongodb.com/try/download/compass
- MongoDB Database Tools (`mongodump`, `mongorestore`, `mongoexport`, `mongoimport`) — https://www.mongodb.com/try/download/database-tools
- Редактор VS Code [Download Visual Studio Code - Mac, Linux, Windows](https://code.visualstudio.com/Download)
- Система керування версіями git https://git-scm.com/downloads

## 👥 Форма виконання роботи

Форма виконання роботи **індивідуальна**.

## 📝 Критерії оцінювання

### Рівень 1 (35-49 балів)

- Успішне встановлення та налаштування MongoDB (4 бали).
- Створення бази даних з трьома колекціями (8 балів).
- Додавання по 10 документів у кожну колекцію (12 балів).
- Виконання базових CRUD операцій (вставка, пошук, оновлення, видалення) (15 балів).
- Створення трьох різних індексів (4 бали).
- Порівняння продуктивності запитів з індексами та без них (4 бали).

### Рівень 2 (50-74 балів)

Усі завдання рівня 1 плюс:

- Реалізація складних запитів з логічними операторами (4 бали).
- Виконання агрегаційних запитів з використанням pipeline (8 балів).
- Створення складених індексів для оптимізації (3 бали).
- Реалізація текстового пошуку з text індексом (4 бали).
- Використання $lookup для об'єднання колекцій (4 бали).
- Створення представлення для складних запитів (2 бали).

### Рівень 3 (75-100 балів)

Усі завдання рівня 2 плюс:

- Реалізація валідації схеми з JSON Schema (5 балів).
- Створення геопросторових індексів або TTL індексів (3 бали).
- Розробка системи версіонування документів (4 бали).
- Повнотекстовий пошук з підтримкою української мови (3 бали).
- Налаштування реплікації або шардингу (якщо можливо) (3 бали).
- Автоматизоване резервне копіювання з mongodump (3 бали).
- Детальний порівняльний аналіз реляційного та документного підходів (4 бали).

### Розподіл оцінок за шкалою

* 35-49 балів - **"задовільно"**
* 50-74 бали - **"добре"**
* 75-100 балів - **"відмінно"**



## ⏰ Політика щодо дедлайнів

При порушенні встановленого терміну здачі лабораторної роботи максимальна можлива оцінка становить "добре", незалежно від якості виконаної роботи. Винятки можливі лише за поважних причин, підтверджених документально.

## 📚 Теоретичні відомості


### Основи NoSQL та документо-орієнтованих баз даних

NoSQL (Not Only SQL) це клас систем управління базами даних, які відрізняються від традиційних реляційних СУБД відсутністю жорсткої табличної схеми, горизонтальною масштабованістю та підтримкою розподілених архітектур. Документо-орієнтовані бази даних, такі як MongoDB, зберігають дані у форматі, схожому на JSON (у MongoDB це BSON — Binary JSON), що дозволяє гнучко моделювати складні структури даних без необхідності нормалізації.

**Переваги документного підходу:**

- **Гнучкість схеми** — можливість змінювати структуру документів без міграцій бази даних.
- **Природність моделювання** — структура документів відповідає об'єктам у коді програми.
- **Ефективність** — можливість отримати всі пов'язані дані одним запитом без JOIN операцій.
- **Горизонтальна масштабованість** — легке розподілення даних між серверами (sharding).

**Недоліки порівняно з реляційними СУБД:**

- **Обмежені можливості транзакцій** — хоча MongoDB підтримує ACID транзакції, вони складніші в реалізації.
- **Дублювання даних** — денормалізована природа може призводити до надмірності.
- **Складність складних запитів** — відсутність декларативного SQL може ускладнити деякі операції.

### Структура даних в MongoDB

MongoDB зберігає дані у вигляді документів BSON (Binary JSON), які об'єднуються в колекції. Кожен документ має унікальний ідентифікатор `_id`, який автоматично генерується якщо не вказаний явно.

**Приклад структури документа:**

Нижче наведено документ у нотації mongosh (з типами `ObjectId` та `ISODate`); у форматі Extended JSON ці значення записують як `{"$oid": "..."}` і `{"$date": "..."}`.

```javascript
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "title": "Тигролови",
  "author": {
    "name": "Іван Багряний",
    "birth_year": 1906,
    "nationality": "український"
  },
  "genres": ["роман", "пригоди", "політична проза"],
  "publication_year": 1944,
  "pages": 416,
  "isbn": "978-966-03-3527-6",
  "available": true,
  "ratings": [
    { "user": "user123", "score": 5, "date": ISODate("2024-03-15") },
    { "user": "user456", "score": 4, "date": ISODate("2024-03-20") }
  ]
}
```

Документи можуть містити:

- **Прості типи даних:** string, number, boolean, date, null.
- **Вкладені документи:** об'єкти всередині об'єктів.
- **Масиви:** списки значень або документів.
- **Спеціальні типи:** ObjectId, Binary Data, Regular Expression.

### CRUD операції в MongoDB

**Create (Створення):**

```javascript
// Вставка одного документа
db.books.insertOne({
  title: "Тіні забутих предків",
  author: "Михайло Коцюбинський",
  publication_year: 1911,
  genres: ["повість", "романтизм"],
  available: true
});

// Вставка багатьох документів
db.books.insertMany([
  {
    title: "Кобзар",
    author: "Тарас Шевченко",
    publication_year: 1840,
    genres: ["поезія"]
  },
  {
    title: "Лісова пісня",
    author: "Леся Українка",
    publication_year: 1911,
    genres: ["драма", "феєрія"]
  }
]);
```

**Read (Читання):**

```javascript
// Пошук всіх документів
db.books.find();

// Пошук з умовою
db.books.find({ author: "Тарас Шевченко" });

// Пошук з множинними умовами
db.books.find({
  publication_year: { $gte: 1900 },
  available: true
});

// Пошук одного документа
db.books.findOne({ title: "Кобзар" });

// Проєкція полів (вибір конкретних полів)
db.books.find(
  { genres: "поезія" },
  { title: 1, author: 1, _id: 0 }
);

// Сортування та обмеження
db.books.find().sort({ publication_year: -1 }).limit(5);
```

**Update (Оновлення):**

```javascript
// Оновлення одного документа
db.books.updateOne(
  { title: "Кобзар" },
  { $set: { available: false } }
);

// Оновлення багатьох документів
db.books.updateMany(
  { publication_year: { $lt: 1900 } },
  { $set: { category: "класика" } }
);

// Додавання елементу до масиву
db.books.updateOne(
  { title: "Тигролови" },
  { $push: { genres: "трилер" } }
);

// Інкрементування числового значення
db.books.updateOne(
  { title: "Кобзар" },
  { $inc: { borrowed_count: 1 } }
);
```

Оператор `replaceOne` на відміну від `updateOne` **повністю замінює** документ (окрім `_id`) новим, тому поля, яких немає в новому документі, буде втрачено:

```javascript
db.books.replaceOne(
  { title: "Кобзар" },
  { title: "Кобзар", author: "Тарас Шевченко", publication_year: 1840, available: true }
);
```

**Delete (Видалення):**

```javascript
// Видалення одного документа
db.books.deleteOne({ title: "Застарілий довідник" });

// Видалення багатьох документів
db.books.deleteMany({ available: false });

// Видалення всіх документів з колекції
db.books.deleteMany({});
```

### Оператори запитів

MongoDB підтримує широкий набір операторів для побудови складних запитів:

**Оператори порівняння:**

```javascript
// $eq, $ne - рівність і нерівність
db.books.find({ publication_year: { $eq: 1911 } });
db.books.find({ available: { $ne: false } });

// $gt, $gte, $lt, $lte - більше, більше або дорівнює, менше, менше або дорівнює
db.books.find({ pages: { $gt: 300, $lte: 500 } });

// $in, $nin - входження в список
db.books.find({ genres: { $in: ["поезія", "драма"] } });
```

**Логічні оператори:**

```javascript
// $and - логічне І
db.books.find({
  $and: [
    { publication_year: { $gte: 1900 } },
    { available: true }
  ]
});

// $or - логічне АБО
db.books.find({
  $or: [
    { author: "Тарас Шевченко" },
    { genres: "поезія" }
  ]
});

// $not - логічне НІ
db.books.find({ pages: { $not: { $lt: 200 } } });
```

**Оператори для роботи з масивами:**

```javascript
// $all - всі елементи повинні бути присутні
db.books.find({ genres: { $all: ["роман", "містика"] } });

// $size - розмір масиву
db.books.find({ genres: { $size: 2 } });

// $elemMatch - співпадіння елементу масиву з умовою
db.books.find({
  ratings: {
    $elemMatch: { score: { $gte: 4 }, user: "user123" }
  }
});
```

**Оператор регулярних виразів:**

```javascript
// Пошук за шаблоном
db.books.find({ title: { $regex: /Тигролови/i } });

// З урахуванням регістру
db.books.find({ author: { $regex: "^Михайло" } });
```

### Агрегаційний pipeline

Агрегаційний pipeline дозволяє виконувати складну обробку даних через послідовність етапів (stages).

**Основні етапи pipeline:**

```javascript
// $match - фільтрація документів
db.books.aggregate([
  { $match: { publication_year: { $gte: 1900 } } }
]);

// $group - групування та агрегація
db.books.aggregate([
  {
    $group: {
      _id: "$author",
      total_books: { $sum: 1 },
      avg_pages: { $avg: "$pages" }
    }
  }
]);

// $sort - сортування
db.books.aggregate([
  { $sort: { publication_year: -1 } }
]);

// $limit та $skip - обмеження та пропуск
db.books.aggregate([
  { $sort: { pages: -1 } },
  { $limit: 10 }
]);

// $project - проєкція полів
db.books.aggregate([
  {
    $project: {
      title: 1,
      author: 1,
      century: { $ceil: { $divide: ["$publication_year", 100] } }
    }
  }
]);

// $unwind - розгортання масивів
db.books.aggregate([
  { $unwind: "$genres" },
  { $group: { _id: "$genres", count: { $sum: 1 } } }
]);

// $lookup - об'єднання колекцій (JOIN)
db.books.aggregate([
  {
    $lookup: {
      from: "authors",
      localField: "author_id",
      foreignField: "_id",
      as: "author_details"
    }
  }
]);
```

**Приклад складного pipeline:**

```javascript
db.books.aggregate([
  // Етап 1: Фільтрація книг після 1900 року
  { $match: { publication_year: { $gte: 1900 } } },

  // Етап 2: Розгортання жанрів
  { $unwind: "$genres" },

  // Етап 3: Групування за жанрами
  {
    $group: {
      _id: "$genres",
      count: { $sum: 1 },
      avg_pages: { $avg: "$pages" },
      books: { $push: "$title" }
    }
  },

  // Етап 4: Сортування за кількістю
  { $sort: { count: -1 } },

  // Етап 5: Обмеження результатів
  { $limit: 5 }
]);
```

### Індексування в MongoDB

Індекси в MongoDB працюють аналогічно до реляційних баз даних, прискорюючи операції пошуку, сортування та об'єднання.

**Типи індексів:**

```javascript
// Простий індекс
db.books.createIndex({ title: 1 }); // 1 - зростання, -1 - спадання

// Складений індекс
db.books.createIndex({ author: 1, publication_year: -1 });

// Унікальний індекс
db.books.createIndex({ isbn: 1 }, { unique: true });

// Текстовий індекс для повнотекстового пошуку
db.books.createIndex({ title: "text", description: "text" });

// Геопросторовий індекс
db.locations.createIndex({ coordinates: "2dsphere" });

// TTL індекс для автоматичного видалення
db.sessions.createIndex(
  { created_at: 1 },
  { expireAfterSeconds: 3600 }
);
```

**Перевірка використання індексів:**

```javascript
// Аналіз плану виконання запиту
db.books.find({ author: "Тарас Шевченко" }).explain("executionStats");

// Список всіх індексів колекції
db.books.getIndexes();

// Видалення індексу
db.books.dropIndex("title_1");
```

### Валідація схеми

MongoDB дозволяє визначити правила валідації для документів в колекції з використанням JSON Schema.

```javascript
db.createCollection("books", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "author", "publication_year"],
      properties: {
        title: {
          bsonType: "string",
          description: "Назва книги обов'язкова та має бути рядком"
        },
        author: {
          bsonType: "string",
          description: "Автор обов'язковий та має бути рядком"
        },
        publication_year: {
          bsonType: "int",
          minimum: 1000,
          maximum: 2100,
          description: "Рік видання має бути цілим числом між 1000 та 2100"
        },
        pages: {
          bsonType: "int",
          minimum: 1,
          description: "Кількість сторінок має бути додатнім цілим числом"
        },
        genres: {
          bsonType: "array",
          items: { bsonType: "string" },
          description: "Жанри мають бути масивом рядків"
        },
        available: {
          bsonType: "bool",
          description: "Доступність має бути булевим значенням"
        }
      }
    }
  }
});
```


## ▶️ Хід роботи

### Крок 1. Встановлення MongoDB

!!! note "Версії"
    Команди нижче наведено для MongoDB 8.0. Якщо вийшла новіша версія, скористайтеся інструкцією зі встановлення в [офіційній документації](https://www.mongodb.com/docs/manual/installation/). Утиліти `mongodump`, `mongorestore`, `mongoexport` та `mongoimport` входять до окремого пакета MongoDB Database Tools; у Windows його встановлюють окремо (див. розділ «Програмне забезпечення»).

**Для Windows:**

1. Завантажте MongoDB Community Edition з офіційного сайту: [https://www.mongodb.com/try/download/community](https://www.mongodb.com/try/download/community)
2. Запустіть інсталятор та виберіть Complete installation.
3. Встановіть MongoDB Compass (графічний інтерфейс) під час інсталяції.
4. Після встановлення перевірте роботу MongoDB:

```bash
mongod --version
mongosh --version
```

**Для macOS:**

```bash
# Встановлення через Homebrew
brew tap mongodb/brew
brew install mongodb-community

# Запуск служби MongoDB
brew services start mongodb-community

# Встановлення MongoDB Compass
brew install --cask mongodb-compass
```

**Для Linux (Ubuntu/Debian):**

```bash
# Імпорт публічного ключа (apt-key застарів, ключ зберігаємо в keyrings)
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

# Додавання репозиторію (для Ubuntu 24.04 — noble; для 22.04 замініть на jammy)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Оновлення та встановлення
sudo apt-get update
sudo apt-get install -y mongodb-org

# Запуск служби
sudo systemctl start mongod
sudo systemctl enable mongod
```

### Крок 2. Підключення до MongoDB

Запустіть MongoDB Shell (mongosh):

```bash
mongosh
```

Або використайте MongoDB Compass для графічного інтерфейсу, підключившись до `mongodb://localhost:27017`.

### Крок 3. Створення бази даних та колекцій

```javascript
// Перемикання на нову базу даних (створюється автоматично)
use library

// Створення колекцій з валідацією
db.createCollection("books", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "author", "publication_year"],
      properties: {
        title: { bsonType: "string" },
        author: { bsonType: "string" },
        publication_year: { bsonType: "int", minimum: 1000 },
        pages: { bsonType: "int", minimum: 1 },
        genres: { bsonType: "array", items: { bsonType: "string" } },
        available: { bsonType: "bool" }
      }
    }
  }
});

db.createCollection("authors");
db.createCollection("users");
```

### Крок 4. Заповнення колекцій даними

```javascript
// Вставка авторів (наведено фрагмент — доповніть колекцію до 10 документів)
db.authors.insertMany([
  {
    name: "Тарас Шевченко",
    birth_year: 1814,
    death_year: 1861,
    nationality: "український",
    biography: "Найвідоміший український поет, письменник, художник"
  },
  {
    name: "Леся Українка",
    birth_year: 1871,
    death_year: 1913,
    nationality: "український",
    biography: "Видатна українська письменниця, поетеса"
  },
  {
    name: "Іван Франко",
    birth_year: 1856,
    death_year: 1916,
    nationality: "український",
    biography: "Письменник, поет, публіцист, перекладач"
  },
  {
    name: "Михайло Коцюбинський",
    birth_year: 1864,
    death_year: 1913,
    nationality: "український",
    biography: "Український письменник-модерніст"
  },
  {
    name: "Панас Мирний",
    birth_year: 1849,
    death_year: 1920,
    nationality: "український",
    biography: "Український письменник-реаліст"
  },
  {
    name: "Григорій Квітка-Основ'яненко",
    birth_year: 1778,
    death_year: 1843,
    nationality: "український",
    biography: "Письменник, засновник новітньої української прози"
  },
  {
    name: "Василь Стефаник",
    birth_year: 1871,
    death_year: 1936,
    nationality: "український",
    biography: "Письменник-новеліст, майстер психологічної малої прози"
  }
]);

// Вставка книг
db.books.insertMany([
  {
    title: "Кобзар",
    author: "Тарас Шевченко",
    publication_year: 1840,
    pages: 238,
    isbn: "978-966-03-4421-6",
    genres: ["поезія", "романтизм"],
    available: true,
    description: "Збірка віршів Тараса Шевченка"
  },
  {
    title: "Лісова пісня",
    author: "Леся Українка",
    publication_year: 1911,
    pages: 128,
    isbn: "978-966-03-3918-2",
    genres: ["драма", "феєрія", "романтизм"],
    available: true,
    description: "Драма-феєрія за мотивами українського фольклору"
  },
  {
    title: "Захар Беркут",
    author: "Іван Франко",
    publication_year: 1883,
    pages: 256,
    isbn: "978-966-03-6127-5",
    genres: ["роман", "історична проза"],
    available: false,
    description: "Історичний роман про боротьбу карпатських горян"
  },
  {
    title: "Тіні забутих предків",
    author: "Михайло Коцюбинський",
    publication_year: 1911,
    pages: 96,
    isbn: "978-966-03-5214-3",
    genres: ["повість", "романтизм", "модернізм"],
    available: true,
    description: "Поетична повість про кохання в Карпатах"
  },
  {
    title: "Хіба ревуть воли, як ясла повні",
    author: "Панас Мирний",
    publication_year: 1880,
    pages: 384,
    isbn: "978-966-03-4856-6",
    genres: ["роман", "реалізм"],
    available: true,
    description: "Соціально-побутовий роман про життя селян"
  },
  {
    title: "Каменярі",
    author: "Іван Франко",
    publication_year: 1878,
    pages: 64,
    isbn: "978-966-03-7841-9",
    genres: ["поезія", "реалізм"],
    available: true,
    description: "Збірка соціальної поезії"
  },
  {
    title: "Конотопська відьма",
    author: "Григорій Квітка-Основ'яненко",
    publication_year: 1837,
    pages: 112,
    isbn: "978-966-03-3762-1",
    genres: ["повість", "містика"],
    available: true,
    description: "Перша українська романтична повість"
  },
  {
    title: "Маруся",
    author: "Григорій Квітка-Основ'яненко",
    publication_year: 1834,
    pages: 96,
    isbn: "978-966-03-4125-3",
    genres: ["повість", "сентименталізм"],
    available: false,
    description: "Сентиментальна повість про нещасливе кохання"
  },
  {
    title: "Камінний хрест",
    author: "Василь Стефаник",
    publication_year: 1900,
    pages: 48,
    isbn: "978-966-03-5427-7",
    genres: ["новела", "реалізм"],
    available: true,
    description: "Збірка новел про важке життя селян"
  },
  {
    title: "Intermezzo",
    author: "Михайло Коцюбинський",
    publication_year: 1909,
    pages: 72,
    isbn: "978-966-03-6843-4",
    genres: ["повість", "імпресіонізм"],
    available: true,
    description: "Імпресіоністична повість про кохання"
  }
]);

// Вставка користувачів (наведено фрагмент — доповніть колекцію до 10 документів)
db.users.insertMany([
  {
    username: "ivan_petrov",
    email: "ivan.petrov@email.com",
    registration_date: new Date("2024-01-15"),
    borrowed_books: ["Кобзар", "Тіні забутих предків"],
    status: "active"
  },
  {
    username: "maria_kovalenko",
    email: "maria.kovalenko@email.com",
    registration_date: new Date("2024-02-20"),
    borrowed_books: ["Лісова пісня"],
    status: "active"
  },
  {
    username: "oleksandr_sydorov",
    email: "alex.sydorov@email.com",
    registration_date: new Date("2024-03-10"),
    borrowed_books: [],
    status: "active"
  },
  {
    username: "anna_melnyk",
    email: "anna.melnyk@email.com",
    registration_date: new Date("2023-11-05"),
    borrowed_books: ["Хіба ревуть воли, як ясла повні"],
    status: "active"
  },
  {
    username: "dmytro_bondar",
    email: "dmytro.bondar@email.com",
    registration_date: new Date("2024-01-28"),
    borrowed_books: ["Захар Беркут", "Каменярі"],
    status: "suspended"
  }
]);
```

### Крок 5. Виконання базових CRUD операцій

**Операції читання з різними умовами:**

```javascript
// Пошук всіх доступних книг
db.books.find({ available: true });

// Пошук книг конкретного автора
db.books.find({ author: "Іван Франко" });

// Пошук книг з кількістю сторінок більше 100
db.books.find({ pages: { $gt: 100 } });

// Пошук книг певного жанру
db.books.find({ genres: "поезія" });

// Пошук з логічними операторами
db.books.find({
  $or: [
    { author: "Тарас Шевченко" },
    { genres: "романтизм" }
  ]
});

// Пошук за шаблоном
db.books.find({ title: { $regex: /Лісова/i } });

// Пошук з проєкцією конкретних полів
db.books.find(
  { available: true },
  { title: 1, author: 1, pages: 1, _id: 0 }
);

// Пошук з сортуванням
db.books.find().sort({ publication_year: -1 });

// Пошук з обмеженням результатів
db.books.find({ genres: "роман" }).limit(3);
```

**Операції оновлення:**

```javascript
// Оновлення доступності книги
db.books.updateOne(
  { title: "Кобзар" },
  { $set: { available: false } }
);

// Додавання рейтингу до книги
db.books.updateOne(
  { title: "Лісова пісня" },
  {
    $push: {
      ratings: {
        user: "ivan_petrov",
        score: 5,
        date: new Date()
      }
    }
  }
);

// Оновлення багатьох документів
db.books.updateMany(
  { publication_year: { $lt: 1900 } },
  { $set: { category: "класика XIX століття" } }
);

// Інкрементування лічильника
db.books.updateOne(
  { title: "Тіні забутих предків" },
  { $inc: { borrowed_count: 1 } }
);

// Видалення поля з документа
db.books.updateOne(
  { title: "Захар Беркут" },
  { $unset: { temporary_note: "" } }
);
```

**Операції видалення:**

```javascript
// Видалення одного документа
db.books.deleteOne({ title: "Застарілий довідник" });

// Видалення за умовою. Щоб не втратити основні дані для наступних кроків,
// спочатку додаємо тимчасові документи і видаляємо саме їх
db.books.insertMany([
  { title: "Тимчасова книга 1", author: "Тест", publication_year: 2000, available: false, temp: true },
  { title: "Тимчасова книга 2", author: "Тест", publication_year: 2001, available: false, temp: true }
]);
db.books.deleteMany({ temp: true, available: false });

// Видалення користувача з призупиненим статусом
db.users.deleteOne({ status: "suspended", username: "old_user" });
```

### Крок 6. Створення індексів

```javascript
// Простий індекс для швидкого пошуку за назвою
db.books.createIndex({ title: 1 });

// Складений індекс для пошуку за автором та роком
db.books.createIndex({ author: 1, publication_year: -1 });

// Унікальний індекс для ISBN
db.books.createIndex({ isbn: 1 }, { unique: true });

// Перевірка списку індексів
db.books.getIndexes();

// Аналіз використання індексів
db.books.find({ author: "Тарас Шевченко" }).explain("executionStats");
```

Порівняйте час виконання запиту до та після створення індексів:

```javascript
// Без індексу
db.books.find({ author: "Іван Франко" }).explain("executionStats");

// Створення індексу
db.books.createIndex({ author: 1 });

// З індексом
db.books.find({ author: "Іван Франко" }).explain("executionStats");
```

### Крок 7. Агрегаційні запити (рівень 2)

```javascript
// Підрахунок книг за жанрами
db.books.aggregate([
  { $unwind: "$genres" },
  { $group: { _id: "$genres", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);

// Середня кількість сторінок за автором
db.books.aggregate([
  {
    $group: {
      _id: "$author",
      avg_pages: { $avg: "$pages" },
      total_books: { $sum: 1 }
    }
  },
  { $sort: { avg_pages: -1 } }
]);

// Статистика по століттях
db.books.aggregate([
  {
    $project: {
      title: 1,
      author: 1,
      century: { $ceil: { $divide: ["$publication_year", 100] } }
    }
  },
  {
    $group: {
      _id: "$century",
      books_count: { $sum: 1 },
      authors: { $addToSet: "$author" }
    }
  }
]);

// Топ користувачів за кількістю взятих книг
db.users.aggregate([
  {
    $project: {
      username: 1,
      email: 1,
      borrowed_count: { $size: "$borrowed_books" }
    }
  },
  { $sort: { borrowed_count: -1 } },
  { $limit: 5 }
]);
```

### Крок 8. Об'єднання колекцій з $lookup

```javascript
// Спочатку додамо author_id до книг
db.authors.find().forEach(function(author) {
  db.books.updateMany(
    { author: author.name },
    { $set: { author_id: author._id } }
  );
});

// Тепер виконаємо lookup
db.books.aggregate([
  {
    $lookup: {
      from: "authors",
      localField: "author_id",
      foreignField: "_id",
      as: "author_details"
    }
  },
  { $unwind: "$author_details" },
  {
    $project: {
      title: 1,
      "author_details.name": 1,
      "author_details.birth_year": 1,
      publication_year: 1,
      pages: 1
    }
  }
]);
```

**Представлення (view) для часто використовуваних запитів:**

```javascript
db.createView("available_books", "books", [
  { $match: { available: true } },
  { $project: { title: 1, author: 1, publication_year: 1, pages: 1, _id: 0 } }
]);

// Представлення використовується як звичайна колекція (лише для читання)
db.available_books.find({ publication_year: { $lt: 1900 } });
```

### Крок 9. Текстовий пошук

```javascript
// Створення текстового індексу.
// Української мови серед мов текстових індексів MongoDB немає, тому вказуємо
// default_language: "none" — лише розбиття на слова, без стемінгу англійською
db.books.createIndex(
  { title: "text", description: "text" },
  { default_language: "none" }
);

// Пошук за ключовими словами (збіг за точною формою слова)
db.books.find({ $text: { $search: "кохання Карпатах" } });

// Пошук з оцінкою релевантності
db.books.find(
  { $text: { $search: "повість кохання" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } });
```

!!! note "Обмеження текстового пошуку"
    - У колекції може бути лише **один** текстовий індекс; щоб створити інший, спочатку видаліть попередній (`db.books.dropIndex(...)`).
    - Без стемінгу пошук чутливий до словоформ («Карпати» ≠ «Карпатах»). Для завдання рівня 3 («підтримка української мови») розгляньте MongoDB Atlas Search з аналізатором `lucene.ukrainian`, який враховує морфологію, або опишіть у звіті обмеження вбудованого текстового індексу та способи їх обійти.

### Крок 10. Валідація схеми (рівень 3)

```javascript
// Модифікація колекції з додаванням валідації
db.runCommand({
  collMod: "books",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "author", "publication_year", "available"],
      properties: {
        title: {
          bsonType: "string",
          minLength: 1,
          maxLength: 200,
          description: "Назва книги обов'язкова, від 1 до 200 символів"
        },
        author: {
          bsonType: "string",
          minLength: 1,
          description: "Автор обов'язковий"
        },
        publication_year: {
          bsonType: "int",
          minimum: 1000,
          maximum: 2100,
          description: "Рік видання має бути між 1000 та 2100"
        },
        pages: {
          bsonType: "int",
          minimum: 1,
          maximum: 10000,
          description: "Кількість сторінок має бути додатнім числом"
        },
        isbn: {
          bsonType: "string",
          pattern: "^978-\\d{1,5}-\\d{1,7}-\\d{1,7}-\\d{1}$",
          description: "ISBN має відповідати стандартному формату"
        },
        available: {
          bsonType: "bool",
          description: "Доступність обов'язкова"
        }
      }
    }
  },
  validationLevel: "strict"
});

// Спроба вставити некоректний документ (має бути відхилена)
db.books.insertOne({
  title: "Тестова книга",
  author: "Тестовий автор",
  publication_year: 3000, // Некоректний рік
  available: true
});
```

### Крок 11. Резервне копіювання

```bash
# Шляхи наведено для Linux/macOS; у Windows використовуйте, наприклад, C:\backup\library_backup
# Створення резервної копії всієї бази даних
mongodump --db library --out /backup/library_backup

# Створення резервної копії конкретної колекції
mongodump --db library --collection books --out /backup/books_backup

# Відновлення з резервної копії
mongorestore --nsInclude="library.*" /backup/library_backup

# Експорт в JSON формат
mongoexport --db library --collection books --out books.json --jsonArray --pretty

# Імпорт з JSON
mongoimport --db library --collection books --file books.json --jsonArray
```

### Крок 12. Порівняльний аналіз (рівень 3)

Створіть документ з порівнянням реляційного та документного підходів для бібліотечної системи:

**Реляційний підхід (PostgreSQL):**

```sql
-- Структура таблиць
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_year INT,
    nationality VARCHAR(50)
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author_id INT REFERENCES authors(author_id),
    publication_year INT,
    pages INT,
    available BOOLEAN DEFAULT TRUE
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE book_genres (
    book_id INT REFERENCES books(book_id),
    genre_id INT REFERENCES genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);

-- Запит з JOIN
SELECT b.title, a.name, g.genre_name
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN book_genres bg ON b.book_id = bg.book_id
JOIN genres g ON bg.genre_id = g.genre_id
WHERE b.available = TRUE;
```

**Документний підхід (MongoDB):**

```javascript
// Одна колекція з вкладеними документами
{
  _id: ObjectId("..."),
  title: "Кобзар",
  author: {
    name: "Тарас Шевченко",
    birth_year: 1814,
    nationality: "український"
  },
  genres: ["поезія", "романтизм"],
  publication_year: 1840,
  pages: 238,
  available: true
}

// Запит без JOIN
db.books.find({ available: true });
```

**Порівняння:**

| Аспект | Реляційний підхід | Документний підхід |
|--------|-------------------|-------------------|
| Нормалізація | Висока, розділення на таблиці | Денормалізація, вкладені документи |
| Запити | Складні JOIN операції | Прості запити без об'єднань |
| Гнучкість схеми | Жорстка, потребує міграцій | Гнучка, динамічна схема |
| Масштабованість | Вертикальна (складніше) | Горизонтальна (простіше) |
| Транзакції | ACID гарантії | Обмежена підтримка ACID |
| Продуктивність читання | Залежить від JOIN | Швидше при денормалізації |
| Продуктивність запису | Швидше при нормалізації | Може бути повільніше через дублювання |

[🔼 Здати лабораторну роботу](https://moodle.vcolnuft.volyn.ua/moodle/course/view.php?id=32#section-2)



## ❓ Контрольні запитання

1. У чому полягають основні відмінності між реляційними та документо-орієнтованими базами даних? Коли доцільно використовувати кожен підхід?
2. Що таке BSON і чим він відрізняється від JSON? Які переваги надає використання BSON у MongoDB?
3. Поясніть концепцію денормалізації в контексті NoSQL баз даних. Які переваги та недоліки цього підходу?
4. Як працює агрегаційний pipeline в MongoDB? Опишіть основні етапи та їх призначення.
5. Що таке індекси в MongoDB і як вони впливають на продуктивність запитів? Які типи індексів підтримує MongoDB?
6. Поясніть різницю між операторами updateOne, updateMany та replaceOne. Коли використовувати кожен з них?
7. Що таке валідація схеми в MongoDB і як вона реалізується через JSON Schema?
8. Як реалізувати зв'язки між документами в MongoDB? Порівняйте підходи з вбудованими документами та посиланнями.
9. Що таке текстовий індекс і як він використовується для повнотекстового пошуку?
10. Опишіть стратегії масштабування MongoDB. Що таке sharding і реплікація?
