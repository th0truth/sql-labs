# Лабораторна робота 07 Повний цикл розробки NoSQL застосунку з інтеграцією

## 🎯 Мета роботи

Застосувати знання роботи з NoSQL базами даних для створення повноцінного вебзастосунку, навчитися проєктувати документні схеми для реальних предметних областей, опанувати інтеграцію MongoDB з клієнтськими вебтехнологіями, розвинути навички аналізу та оптимізації продуктивності документо-орієнтованих систем.

## ✅ Завдання

### Рівень 1

1. Спроєктувати схему документів для блог-системи з колекціями:
    - `users` (користувачі з ролями: автор, читач, адміністратор)
    - `posts` (статті з вбудованими коментарями та метаданими)
    - `categories` (категорії та теги)
2. Створити колекції з валідацією схеми для забезпечення цілісності даних.
3. Заповнити базу даних реалістичними даними:
    - Мінімум 50 постів
    - Мінімум 200 коментарів
    - 20 користувачів
    - 10 категорій
4. Розробити агрегаційні запити для:
    - Топ 10 авторів за кількістю постів
    - Популярні категорії за кількістю постів
    - Статистика коментарів (загальна, середня на пост)
5. Створити індекси для оптимізації пошуку постів за автором, категорією та датою.
6. Реалізувати простий HTML інтерфейс з JavaScript для відображення списку постів та детальної інформації.

### Рівень 2

Додатково до рівня 1:

1. Реалізувати систему тегів з можливістю пошуку постів за множинними тегами.
2. Додати повнотекстовий пошук за назвою та змістом постів.
3. Створити систему рейтингів постів з можливістю лайків/дизлайків.
4. Реалізувати пагінацію для списку постів через агрегаційний pipeline.
5. Додати статистику переглядів постів з інкрементацією лічильників.
6. Створити систему модерації коментарів з статусами (очікує перевірки, схвалено, відхилено).
7. Реалізувати вебінтерфейс з можливістю додавання нових постів через форму.

### Рівень 3

Додатково до рівня 2:

1. Розробити систему версіонування постів з збереженням історії редагувань.
2. Реалізувати вкладені коментарі (відповіді на коментарі) з рекурсивною структурою.
3. Створити систему сповіщень для авторів про нові коментарі під їх постами.
4. Додати геолокацію для постів з можливістю пошуку за координатами.
5. Реалізувати аналітичну панель з візуалізацією статистики через графіки.
6. Створити RESTful API для взаємодії з системою через HTTP запити.
7. Додати систему кешування популярних запитів для підвищення продуктивності.
8. Розробити порівняльний аналіз з еквівалентною реляційною схемою та тестами продуктивності.


## 🖥️ Програмне забезпечення

- СКБД MongoDB [Download MongoDB Community Server | MongoDB](https://www.mongodb.com/try/download/community)
- MongoDB Atlas https://www.mongodb.com/atlas/database
- MongoDB Shell (`mongosh`) та MongoDB Compass — https://www.mongodb.com/try/download
- Node.js (актуальна LTS-версія) та менеджер пакетів npm — https://nodejs.org (потрібні для сервера в кроці 6)
- Редактор VS Code [Download Visual Studio Code - Mac, Linux, Windows](https://code.visualstudio.com/Download)
- Система керування версіями git https://git-scm.com/downloads


## 👥 Форма виконання роботи

Форма виконання роботи **індивідуальна**.

## 📝 Критерії оцінювання

### Рівень 1 - Основна функціональність

- Коректна схема документів для всіх колекцій з валідацією (12 балів).
- Заповнення бази даних реалістичними даними згідно вимог (12 балів).
- Розробка агрегаційних запитів для статистики (12 балів).
- Створення індексів для оптимізації (4 бали).
- Робочий HTML інтерфейс для відображення постів (9 балів).




### Рівень 2 - Додаткова функціональність

Усі завдання рівня 1 плюс:

- Система тегів з пошуком за множинними тегами (4 бали).
- Повнотекстовий пошук за назвою та змістом (4 бали).
- Система рейтингів з лайками (3 бали).
- Пагінація через агрегаційний pipeline (4 бали).
- Статистика переглядів з інкрементацією (3 бали).
- Модерація коментарів (3 бали).
- Вебформа для додавання постів (4 бали).


### Рівень 3 - Творче розширення

Усі завдання рівня 2 плюс:

- Версіонування постів з історією редагувань (4 бали).
- Вкладені коментарі з рекурсивною структурою (4 бали).
- Система сповіщень для авторів (3 бали).
- Геолокація постів з пошуком (3 бали).
- Аналітична панель з візуалізацією (4 бали).
- RESTful API для взаємодії (4 бали).
- Система кешування (3 бали).
- Детальний порівняльний аналіз з тестами продуктивності (3 бали).


### Розподіл оцінок за шкалою

* 35-49 балів - **"задовільно"**
* 50-74 бали - **"добре"**
* 75-100 балів - **"відмінно"**


## ⏰ Політика щодо дедлайнів

При порушенні встановленого терміну здачі лабораторної роботи максимальна можлива оцінка становить "добре", незалежно від якості виконаної роботи. Винятки можливі лише за поважних причин, підтверджених документально.

## 📚 Теоретичні відомості

### Проєктування документних схем

Проєктування схеми в NoSQL вимагає іншого підходу порівняно з реляційними базами даних. Замість нормалізації та розбиття на таблиці, документний підхід фокусується на патернах доступу до даних та оптимізації для найпоширеніших запитів.

**Основні принципи проєктування:**

**Модель "один до кількох" — вбудовані документи:**

Коли одна сутність тісно пов'язана з іншою та завжди отримується разом, краще вбудовувати дані в один документ.

```javascript
// Пост з вбудованими коментарями
{
  _id: ObjectId("..."),
  title: "Вступ до NoSQL",
  content: "Текст статті...",
  author: {
    user_id: ObjectId("..."),
    username: "ivan_developer",
    avatar: "avatar.jpg"
  },
  comments: [
    {
      comment_id: ObjectId("..."),
      author: {
        user_id: ObjectId("..."),
        username: "maria_reader"
      },
      text: "Чудова стаття!",
      created_at: ISODate("2024-03-15T10:30:00Z")
    }
  ],
  tags: ["mongodb", "nosql", "database"],
  created_at: ISODate("2024-03-10T12:00:00Z"),
  updated_at: ISODate("2024-03-10T12:00:00Z")
}
```

**Модель "багато до багатьох" — посилання:**

Коли сутності мають складні зв'язки або використовуються незалежно, краще зберігати посилання.

```javascript
// Пост з посиланням на автора
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  title: "Архітектура мікросервісів",
  author_id: ObjectId("507f1f77bcf86cd799439012"),
  category_ids: [
    ObjectId("507f1f77bcf86cd799439013"),
    ObjectId("507f1f77bcf86cd799439014")
  ]
}

// Окремий документ користувача
{
  _id: ObjectId("507f1f77bcf86cd799439012"),
  username: "ivan_developer",
  email: "ivan@example.com",
  role: "author"
}
```

**Гібридний підхід:**

Часто оптимально поєднувати обидва підходи, вбудовуючи найважливіші дані та зберігаючи посилання для детальної інформації.

```javascript
{
  _id: ObjectId("..."),
  title: "Сучасний JavaScript",
  author: {
    id: ObjectId("..."),
    username: "ivan_developer",
    // Основна інформація вбудована для швидкого доступу
  },
  category: {
    id: ObjectId("..."),
    name: "Веброзробка"
  },
  comments_count: 42,
  // Самі коментарі можуть бути в окремій колекції для великої кількості
}
```

### Патерни проєктування документних схем

**Патерн "Bucket":**

Використовується для зберігання часових рядів або подій, групуючи їх в бакети за періодами.

```javascript
{
  _id: ObjectId("..."),
  post_id: ObjectId("..."),
  month: "2024-03",
  views: [
    { date: ISODate("2024-03-01"), count: 150 },
    { date: ISODate("2024-03-02"), count: 230 },
    // ... інші дні місяця
  ],
  total_views: 4580
}
```

**Патерн "Computed":**

Попереднє обчислення та зберігання агрегованих даних для швидкого доступу.

```javascript
{
  _id: ObjectId("..."),
  author_id: ObjectId("..."),
  statistics: {
    total_posts: 47,
    total_comments: 312,
    total_likes: 1205,
    avg_likes_per_post: 25.6,
    last_updated: ISODate("2024-03-20T10:00:00Z")
  }
}
```

**Патерн "Polymorphic":**

Зберігання документів різних типів в одній колекції з полем-дискримінатором.

```javascript
// Пост-стаття
{
  _id: ObjectId("..."),
  type: "article",
  title: "...",
  content: "...",
  author_id: ObjectId("...")
}

// Пост-відео
{
  _id: ObjectId("..."),
  type: "video",
  title: "...",
  video_url: "...",
  duration: 360,
  author_id: ObjectId("...")
}
```

### Інтеграція MongoDB з вебзастосунками

**Підключення через Node.js Driver:**

```javascript
const { MongoClient } = require('mongodb');

// URL підключення
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);

// Підключення до бази даних
async function connectDB() {
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    const db = client.db('blog_system');
    return db;
  } catch (error) {
    console.error('Connection error:', error);
  }
}

// Приклад запиту
async function getRecentPosts(limit = 10) {
  const db = await connectDB();
  const posts = await db.collection('posts')
    .find({})
    .sort({ created_at: -1 })
    .limit(limit)
    .toArray();
  return posts;
}
```

!!! note "Одне підключення на весь застосунок"
    `MongoClient` має власний пул з'єднань, тому підключатися слід один раз під час запуску, а не в кожній функції (у прикладі вище це спрощено для наочності). У драйвері версії 4.7 і новіших виклик `client.connect()` перед першим запитом необов'язковий.

**Використання з вебфреймворком Express.js:**

```javascript
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);

let db;

// Підключення до БД при старті сервера
client.connect().then(() => {
  db = client.db('blog_system');
  console.log('Connected to MongoDB');
});

// API endpoint для отримання постів
app.get('/api/posts', async (req, res) => {
  try {
    const posts = await db.collection('posts')
      .find({})
      .sort({ created_at: -1 })
      .limit(10)
      .toArray();
    res.json(posts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API endpoint для створення посту
app.post('/api/posts', express.json(), async (req, res) => {
  try {
    const { title, content, author_id } = req.body;
    if (!title || !content || !ObjectId.isValid(author_id)) {
      return res.status(400).json({ error: 'Некоректні дані запиту' });
    }
    const result = await db.collection('posts').insertOne({
      title,
      content,
      author_id: new ObjectId(author_id),
      created_at: new Date(),
      comments: [],
      likes: 0,
      views: 0
    });
    res.status(201).json({ id: result.insertedId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Оптимізація продуктивності

**Стратегії індексування:**

```javascript
// Складений індекс для сортування та фільтрації
db.posts.createIndex({ category_id: 1, created_at: -1 });

// Текстовий індекс для пошуку
// Української мови серед мов текстових індексів немає, тому default_language: "none"
// (розбиття на слова без стемінгу; пошук чутливий до словоформ)
db.posts.createIndex({ title: "text", content: "text" }, { default_language: "none" });

// Унікальний індекс
db.users.createIndex({ email: 1 }, { unique: true });

// Часткові індекси для опублікованих постів
db.posts.createIndex(
  { created_at: -1 },
  { partialFilterExpression: { status: "published" } }
);
```

**Projection для обмеження полів:**

```javascript
// Отримання тільки необхідних полів
db.posts.find(
  { category_id: categoryId },
  { title: 1, author: 1, created_at: 1, _id: 1 }
);

// Виключення великих полів
db.posts.find(
  {},
  { content: 0, comments: 0 }
);
```

**Пагінація з skip та limit:**

```javascript
// Проста пагінація (не рекомендується для великих offset)
const page = 2;
const perPage = 20;
db.posts.find()
  .skip((page - 1) * perPage)
  .limit(perPage)
  .toArray();

// Краща пагінація через курсор: сортування за _id і вибірка «після останнього побаченого»
const lastId = ObjectId("...");
db.posts.find({ _id: { $gt: lastId } })
  .sort({ _id: 1 })
  .limit(20)
  .toArray();
```

**Пагінація через агрегаційний pipeline** (потрібна для завдання рівня 2): один запит повертає і сторінку, і загальну кількість документів.

```javascript
const page = 2;
const perPage = 10;

db.posts.aggregate([
  { $match: { status: "published" } },
  { $sort: { published_at: -1, _id: -1 } },
  {
    $facet: {
      items: [
        { $skip: (page - 1) * perPage },
        { $limit: perPage },
        { $project: { title: 1, author: 1, published_at: 1 } }
      ],
      total: [{ $count: "count" }]
    }
  }
]);
```

## ▶️ Хід роботи


### Крок 1. Проєктування схеми бази даних

Створіть документ з детальним описом схеми для кожної колекції.

**Колекція `users`:**

```javascript
{
  _id: ObjectId,
  username: String (унікальний, 3-30 символів),
  email: String (унікальний, валідний email),
  password_hash: String (хеш пароля),
  role: String (enum: "admin", "author", "reader"),
  profile: {
    full_name: String,
    bio: String,
    avatar_url: String,
    website: String
  },
  statistics: {
    posts_count: Number (для авторів),
    comments_count: Number
  },
  created_at: Date,
  last_login: Date,
  status: String (enum: "active", "suspended", "deleted")
}
```

**Колекція `posts`:**

```javascript
{
  _id: ObjectId,
  title: String (3-200 символів),
  slug: String (унікальний URL-friendly ідентифікатор),
  content: String (текст статті),
  excerpt: String (короткий опис),
  author: {
    user_id: ObjectId,
    username: String,
    avatar_url: String
  },
  category: {
    category_id: ObjectId,
    name: String
  },
  tags: [String] (масив тегів),
  featured_image: String (URL зображення),
  status: String (enum: "draft", "published", "archived"),
  comments: [
    {
      comment_id: ObjectId,
      author: {
        user_id: ObjectId,
        username: String
      },
      text: String,
      created_at: Date,
      status: String (enum: "pending", "approved", "rejected"),
      likes: Number
    }
  ],
  statistics: {
    views: Number,
    likes: Number,
    comments_count: Number
  },
  created_at: Date,
  updated_at: Date,
  published_at: Date
}
```

**Колекція `categories`:**

```javascript
{
  _id: ObjectId,
  name: String (унікальна назва),
  slug: String (URL-friendly назва),
  description: String,
  parent_id: ObjectId (для вкладених категорій),
  statistics: {
    posts_count: Number
  },
  created_at: Date
}
```

### Крок 2. Створення колекцій з валідацією

```javascript
// Підключення до бази даних
use blog_system

// Створення колекції користувачів
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["username", "email", "password_hash", "role", "created_at"],
      properties: {
        username: {
          bsonType: "string",
          minLength: 3,
          maxLength: 30,
          description: "Ім'я користувача має бути рядком від 3 до 30 символів"
        },
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Email має відповідати стандартному формату"
        },
        password_hash: {
          bsonType: "string",
          minLength: 60,
          description: "Хеш пароля обов'язковий"
        },
        role: {
          enum: ["admin", "author", "reader"],
          description: "Роль має бути одна з: admin, author, reader"
        },
        status: {
          enum: ["active", "suspended", "deleted"],
          description: "Статус користувача"
        },
        created_at: {
          bsonType: "date",
          description: "Дата створення обов'язкова"
        }
      }
    }
  }
});

// Створення колекції постів
db.createCollection("posts", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "content", "author", "created_at", "status"],
      properties: {
        title: {
          bsonType: "string",
          minLength: 3,
          maxLength: 200,
          description: "Назва має бути від 3 до 200 символів"
        },
        slug: {
          bsonType: "string",
          pattern: "^[a-z0-9-]+$",
          description: "Slug має містити тільки малі літери, цифри та дефіси"
        },
        content: {
          bsonType: "string",
          minLength: 100,
          description: "Контент має містити мінімум 100 символів"
        },
        author: {
          bsonType: "object",
          required: ["user_id", "username"],
          properties: {
            user_id: { bsonType: "objectId" },
            username: { bsonType: "string" }
          }
        },
        status: {
          enum: ["draft", "published", "archived"],
          description: "Статус посту"
        },
        created_at: {
          bsonType: "date"
        }
      }
    }
  }
});

// Створення колекції категорій
db.createCollection("categories", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "slug", "created_at"],
      properties: {
        name: {
          bsonType: "string",
          minLength: 2,
          maxLength: 50
        },
        slug: {
          bsonType: "string",
          pattern: "^[a-z0-9-]+$"
        },
        created_at: {
          bsonType: "date"
        }
      }
    }
  }
});
```

### Крок 3. Створення унікальних індексів

```javascript
// Індекси для користувачів
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ created_at: -1 });

// Індекси для постів
db.posts.createIndex({ slug: 1 }, { unique: true });
db.posts.createIndex({ "author.user_id": 1, created_at: -1 });
db.posts.createIndex({ "category.category_id": 1, status: 1 });
db.posts.createIndex({ status: 1, published_at: -1 });
db.posts.createIndex({ tags: 1 });
// default_language: "none" — для українських текстів (стемінгу для української немає)
db.posts.createIndex(
  { title: "text", content: "text", excerpt: "text" },
  { default_language: "none" }
);

// Індекси для категорій
db.categories.createIndex({ slug: 1 }, { unique: true });
db.categories.createIndex({ name: 1 }, { unique: true });
```

### Крок 4. Заповнення тестовими даними

```javascript
// Функція для генерації випадкових користувачів
function generateUsers(count) {
  const roles = ["admin", "author", "reader"];
  const users = [];

  for (let i = 0; i < count; i++) {
    users.push({
      username: `user${i + 1}`,
      email: `user${i + 1}@blog.com`,
      password_hash: "$2b$10$" + "x".repeat(53), // імітація 60-символьного bcrypt-хешу (схема вимагає minLength: 60); у реальному застосунку пароль хешують бібліотекою bcrypt
      role: roles[i % roles.length], // ролі розподіляються по колу, тож автори гарантовано будуть
      profile: {
        full_name: `Користувач ${i + 1}`,
        bio: `Біографія користувача ${i + 1}`,
        avatar_url: `https://api.dicebear.com/9.x/avataaars/svg?seed=${i}`,
        website: i % 3 === 0 ? `https://user${i + 1}.com` : null
      },
      statistics: {
        posts_count: 0,
        comments_count: 0
      },
      created_at: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
      last_login: new Date(),
      status: "active"
    });
  }

  return users;
}

// Вставка користувачів
const users = generateUsers(20);
db.users.insertMany(users);

// Отримання ID авторів для постів
const authors = db.users.find({ role: "author" }).toArray();

// Генерація категорій
const categories = [
  { name: "Веброзробка", slug: "web-development", description: "Статті про веброзробку" },
  { name: "Мобільні додатки", slug: "mobile-apps", description: "Розробка мобільних додатків" },
  { name: "Бази даних", slug: "databases", description: "NoSQL та SQL бази даних" },
  { name: "DevOps", slug: "devops", description: "Автоматизація та CI/CD" },
  { name: "Штучний інтелект", slug: "ai", description: "ML та AI технології" },
  { name: "Хмарні технології", slug: "cloud", description: "AWS, Azure, Google Cloud" },
  { name: "Безпека", slug: "security", description: "Кібербезпека та захист даних" },
  { name: "UX/UI", slug: "ux-ui", description: "Дизайн інтерфейсів" },
  { name: "Архітектура ПЗ", slug: "architecture", description: "Patterns та Best Practices" },
  { name: "Тестування", slug: "testing", description: "Методології тестування" }
];

categories.forEach(cat => {
  cat.created_at = new Date();
  cat.statistics = { posts_count: 0 };
});

db.categories.insertMany(categories);

// Генерація постів
function generatePosts(count, authors, categories) {
  const tags = [
    "javascript", "python", "mongodb", "react", "nodejs",
    "docker", "kubernetes", "aws", "typescript", "vue"
  ];
  const posts = [];

  for (let i = 0; i < count; i++) {
    const author = authors[Math.floor(Math.random() * authors.length)];
    const category = categories[Math.floor(Math.random() * categories.length)];
    const postTags = [];
    const tagsCount = Math.floor(Math.random() * 3) + 1;

    for (let j = 0; j < tagsCount; j++) {
      const tag = tags[Math.floor(Math.random() * tags.length)];
      if (!postTags.includes(tag)) postTags.push(tag);
    }

    const createdDate = new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000);

    posts.push({
      title: `Стаття ${i + 1}: Цікава тема про програмування`,
      slug: `article-${i + 1}-programming-topic`,
      content: `Це детальний контент статті номер ${i + 1}. Тут розглядаються важливі аспекти сучасної розробки програмного забезпечення. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.`,
      excerpt: `Короткий опис статті ${i + 1}`,
      author: {
        user_id: author._id,
        username: author.username,
        avatar_url: author.profile.avatar_url
      },
      category: {
        category_id: category._id,
        name: category.name
      },
      tags: postTags,
      featured_image: `https://picsum.photos/800/400?random=${i}`,
      status: "published",
      comments: [],
      statistics: {
        views: Math.floor(Math.random() * 1000),
        likes: Math.floor(Math.random() * 100),
        comments_count: 0
      },
      created_at: createdDate,
      updated_at: createdDate,
      published_at: createdDate
    });
  }

  return posts;
}

const categoryDocs = db.categories.find().toArray();
const posts = generatePosts(50, authors, categoryDocs);
db.posts.insertMany(posts);

// Генерація коментарів
const allPosts = db.posts.find().toArray();
const allUsers = db.users.find().toArray();

allPosts.forEach(post => {
  const commentsCount = Math.floor(Math.random() * 5) + 4; // 4–8 коментарів на пост, тобто щонайменше 200 загалом
  const comments = [];

  for (let i = 0; i < commentsCount; i++) {
    const commentAuthor = allUsers[Math.floor(Math.random() * allUsers.length)];
    comments.push({
      comment_id: new ObjectId(),
      author: {
        user_id: commentAuthor._id,
        username: commentAuthor.username
      },
      text: `Це коментар ${i + 1} до статті. Дуже цікава думка про тему.`,
      created_at: new Date(post.created_at.getTime() + Math.random() * 30 * 24 * 60 * 60 * 1000),
      status: "approved",
      likes: Math.floor(Math.random() * 20)
    });
  }

  db.posts.updateOne(
    { _id: post._id },
    {
      $set: { comments: comments },
      $inc: { "statistics.comments_count": comments.length }
    }
  );
});
```

### Крок 5. Розробка агрегаційних запитів

```javascript
// Топ 10 авторів за кількістю постів
db.posts.aggregate([
  { $match: { status: "published" } },
  {
    $group: {
      _id: "$author.user_id",
      username: { $first: "$author.username" },
      posts_count: { $sum: 1 },
      total_views: { $sum: "$statistics.views" },
      total_likes: { $sum: "$statistics.likes" }
    }
  },
  { $sort: { posts_count: -1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      author_id: "$_id",
      username: 1,
      posts_count: 1,
      total_views: 1,
      total_likes: 1,
      avg_views_per_post: { $divide: ["$total_views", "$posts_count"] }
    }
  }
]);

// Популярні категорії
db.posts.aggregate([
  { $match: { status: "published" } },
  {
    $group: {
      _id: "$category.category_id",
      category_name: { $first: "$category.name" },
      posts_count: { $sum: 1 },
      total_views: { $sum: "$statistics.views" },
      avg_likes: { $avg: "$statistics.likes" }
    }
  },
  { $sort: { posts_count: -1 } },
  {
    $project: {
      _id: 0,
      category_name: 1,
      posts_count: 1,
      total_views: 1,
      avg_likes: { $round: ["$avg_likes", 2] }
    }
  }
]);

// Статистика коментарів
db.posts.aggregate([
  { $match: { status: "published" } },
  {
    $project: {
      title: 1,
      author: 1,
      comments_count: "$statistics.comments_count",
      views: "$statistics.views"
    }
  },
  {
    $group: {
      _id: null,
      total_posts: { $sum: 1 },
      total_comments: { $sum: "$comments_count" },
      avg_comments_per_post: { $avg: "$comments_count" },
      max_comments: { $max: "$comments_count" }
    }
  },
  {
    $project: {
      _id: 0,
      total_posts: 1,
      total_comments: 1,
      avg_comments_per_post: { $round: ["$avg_comments_per_post", 2] },
      max_comments: 1
    }
  }
]);

// Розподіл постів за тегами
db.posts.aggregate([
  { $match: { status: "published" } },
  { $unwind: "$tags" },
  {
    $group: {
      _id: "$tags",
      count: { $sum: 1 },
      avg_views: { $avg: "$statistics.views" }
    }
  },
  { $sort: { count: -1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      tag: "$_id",
      posts_count: "$count",
      avg_views: { $round: ["$avg_views", 0] }
    }
  }
]);
```

### Крок 6. Створення вебінтерфейсу

Сторінка в браузері не може напряму звертатися до MongoDB: потрібен серверний прошарок, який читає дані з бази й віддає їх у форматі JSON. Створіть мінімальний сервер на Express.js:

```bash
mkdir blog-app && cd blog-app
npm init -y
npm install express mongodb
mkdir public
```

Файл `server.js`:

```javascript
const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const client = new MongoClient('mongodb://localhost:27017');

app.use(express.static('public')); // у цій теці лежить index.html

app.get('/api/posts', async (req, res) => {
  try {
    const posts = await client.db('blog_system').collection('posts')
      .find({ status: 'published' })
      .sort({ created_at: -1 })
      .limit(50)
      .toArray();
    res.json(posts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Не вдалося отримати пости' });
  }
});

client.connect().then(() => {
  app.listen(3000, () => console.log('Сервер працює: http://localhost:3000'));
});
```

Запустіть сервер командою `node server.js` та відкрийте `http://localhost:3000`. Далі створіть файл `public/index.html`. Сторінка спочатку намагається завантажити пости з `/api/posts`, а якщо API недоступне (наприклад, файл відкрито просто з диска), показує демонстраційні дані `mockPosts`:

```html
<!DOCTYPE html>
<html lang="uk">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Блог на MongoDB</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f4f4f4;
        }

        header {
            background: #2c3e50;
            color: white;
            padding: 1rem 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        h1 {
            font-size: 2rem;
        }

        .search-bar {
            margin: 2rem 0;
            display: flex;
            gap: 1rem;
        }

        .search-bar input {
            flex: 1;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
        }

        .search-bar button {
            padding: 0.8rem 1.5rem;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }

        .search-bar button:hover {
            background: #2980b9;
        }

        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }

        .post-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
        }

        .post-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .post-card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }

        .post-content {
            padding: 1.5rem;
        }

        .post-title {
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }

        .post-meta {
            display: flex;
            gap: 1rem;
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-bottom: 1rem;
        }

        .post-excerpt {
            color: #555;
            margin-bottom: 1rem;
        }

        .post-tags {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .tag {
            background: #ecf0f1;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            color: #2c3e50;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 1000;
        }

        .modal-content {
            position: relative;
            background: white;
            width: 90%;
            max-width: 800px;
            margin: 2rem auto;
            padding: 2rem;
            border-radius: 8px;
            max-height: 90vh;
            overflow-y: auto;
        }

        .close-modal {
            position: absolute;
            top: 1rem;
            right: 1rem;
            font-size: 2rem;
            cursor: pointer;
            color: #7f8c8d;
        }

        .comments {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #ecf0f1;
        }

        .comment {
            padding: 1rem;
            background: #f8f9fa;
            margin-bottom: 1rem;
            border-radius: 4px;
        }

        .comment-author {
            font-weight: bold;
            color: #2c3e50;
        }

        .comment-date {
            font-size: 0.85rem;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>📝 Блог на MongoDB</h1>
        </div>
    </header>

    <div class="container">
        <div class="search-bar">
            <input type="text" id="searchInput" placeholder="Пошук статей...">
            <button onclick="searchPosts()">Шукати</button>
        </div>

        <div id="postsGrid" class="posts-grid">
            <!-- Пости будуть завантажені тут -->
        </div>
    </div>

    <div id="postModal" class="modal">
        <div class="modal-content">
            <span class="close-modal" onclick="closeModal()">&times;</span>
            <div id="postDetails"></div>
        </div>
    </div>

    <script>
        // Резервні демонстраційні дані: використовуються, якщо API недоступне
        const mockPosts = [
            {
                _id: "1",
                title: "Вступ до NoSQL баз даних",
                excerpt: "Детальний огляд переваг NoSQL над традиційними SQL базами даних",
                author: { username: "ivan_developer", avatar_url: "https://api.dicebear.com/9.x/avataaars/svg?seed=1" },
                category: { name: "Бази даних" },
                tags: ["nosql", "mongodb", "database"],
                featured_image: "https://picsum.photos/800/400?random=1",
                statistics: { views: 542, likes: 34, comments_count: 12 },
                created_at: "2024-03-15",
                content: "Повний текст статті про NoSQL бази даних...",
                comments: [
                    { author: { username: "maria_reader" }, text: "Чудова стаття!", created_at: "2024-03-16" },
                    { author: { username: "user3" }, text: "Дуже корисно", created_at: "2024-03-17" }
                ]
            },
            {
                _id: "2",
                title: "React Hooks: Повний гайд",
                excerpt: "Все що потрібно знати про React Hooks для сучасної розробки",
                author: { username: "maria_frontend", avatar_url: "https://api.dicebear.com/9.x/avataaars/svg?seed=2" },
                category: { name: "Веброзробка" },
                tags: ["react", "javascript", "frontend"],
                featured_image: "https://picsum.photos/800/400?random=2",
                statistics: { views: 821, likes: 67, comments_count: 23 },
                created_at: "2024-03-10",
                content: "Детальний розбір React Hooks...",
                comments: [
                    { author: { username: "developer123" }, text: "Дуже допомогло!", created_at: "2024-03-11" }
                ]
            },
            {
                _id: "3",
                title: "Docker для початківців",
                excerpt: "Основи контейнеризації та роботи з Docker",
                author: { username: "oleksandr_devops", avatar_url: "https://api.dicebear.com/9.x/avataaars/svg?seed=3" },
                category: { name: "DevOps" },
                tags: ["docker", "devops", "containers"],
                featured_image: "https://picsum.photos/800/400?random=3",
                statistics: { views: 634, likes: 45, comments_count: 18 },
                created_at: "2024-03-05",
                content: "Вступ до Docker та контейнеризації...",
                comments: []
            }
        ];

        // Екранування тексту перед вставкою в HTML (захист від XSS)
        function esc(value) {
            return String(value ?? '').replace(/[&<>"']/g, ch => ({
                '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
            }[ch]));
        }

        function formatDate(value) {
            const date = new Date(value);
            return isNaN(date) ? '' : date.toLocaleDateString('uk-UA');
        }

        let allPosts = mockPosts;

        // Завантаження постів: з API, а за його відсутності — демонстраційні дані
        async function loadPosts(posts) {
            if (!posts) {
                try {
                    const response = await fetch('/api/posts');
                    if (!response.ok) throw new Error('HTTP ' + response.status);
                    allPosts = await response.json();
                } catch (error) {
                    console.warn('API недоступне, використовуються демонстраційні дані:', error);
                    allPosts = mockPosts;
                }
                posts = allPosts;
            }

            const grid = document.getElementById('postsGrid');
            grid.innerHTML = '';

            posts.forEach(post => {
                const card = createPostCard(post);
                grid.appendChild(card);
            });
        }

        // Створення картки посту
        function createPostCard(post) {
            const card = document.createElement('div');
            card.className = 'post-card';
            card.onclick = () => showPostDetails(post);

            card.innerHTML = `
                <img src="${esc(post.featured_image)}" alt="${esc(post.title)}">
                <div class="post-content">
                    <h2 class="post-title">${esc(post.title)}</h2>
                    <div class="post-meta">
                        <span>👤 ${esc(post.author.username)}</span>
                        <span>📁 ${esc(post.category.name)}</span>
                        <span>👁️ ${post.statistics.views}</span>
                    </div>
                    <p class="post-excerpt">${esc(post.excerpt)}</p>
                    <div class="post-tags">
                        ${post.tags.map(tag => `<span class="tag">#${esc(tag)}</span>`).join('')}
                    </div>
                </div>
            `;

            return card;
        }

        // Відображення деталей посту
        function showPostDetails(post) {
            const modal = document.getElementById('postModal');
            const details = document.getElementById('postDetails');

            details.innerHTML = `
                <img src="${esc(post.featured_image)}" alt="${esc(post.title)}" style="width: 100%; border-radius: 8px; margin-bottom: 1rem;">
                <h2>${esc(post.title)}</h2>
                <div class="post-meta" style="margin: 1rem 0;">
                    <span>👤 ${esc(post.author.username)}</span>
                    <span>📁 ${esc(post.category.name)}</span>
                    <span>📅 ${formatDate(post.created_at)}</span>
                    <span>👁️ ${post.statistics.views}</span>
                    <span>❤️ ${post.statistics.likes}</span>
                </div>
                <div class="post-tags" style="margin-bottom: 1.5rem;">
                    ${post.tags.map(tag => `<span class="tag">#${esc(tag)}</span>`).join('')}
                </div>
                <p>${esc(post.content)}</p>
                <div class="comments">
                    <h3>Коментарі (${post.comments.length})</h3>
                    ${post.comments.map(comment => `
                        <div class="comment">
                            <div class="comment-author">${esc(comment.author.username)}</div>
                            <div class="comment-date">${formatDate(comment.created_at)}</div>
                            <p>${esc(comment.text)}</p>
                        </div>
                    `).join('')}
                </div>
            `;

            modal.style.display = 'block';
        }

        // Закриття модального вікна
        function closeModal() {
            document.getElementById('postModal').style.display = 'none';
        }

        // Пошук постів
        function searchPosts() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const filtered = allPosts.filter(post =>
                post.title.toLowerCase().includes(searchTerm) ||
                post.excerpt.toLowerCase().includes(searchTerm) ||
                (post.tags || []).some(tag => tag.includes(searchTerm))
            );
            loadPosts(filtered);
        }

        // Закриття модального вікна при кліку поза ним
        window.onclick = function(event) {
            const modal = document.getElementById('postModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }

        // Завантаження при старті
        loadPosts();
    </script>
</body>
</html>
```

### Крок 7. Порівняльний аналіз (рівень 3)

Створіть документ з порівнянням реляційної та документної моделі для блог-системи.

**Реляційна схема (PostgreSQL):**

```sql
-- Для автоінкременту використовується GENERATED ... AS IDENTITY (сучасна заміна SERIAL)
-- Таблиця користувачів
CREATE TABLE users (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблиця категорій
CREATE TABLE categories (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Таблиця постів
CREATE TABLE posts (
    post_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    user_id INT REFERENCES users(user_id),
    category_id INT REFERENCES categories(category_id),
    status VARCHAR(20) NOT NULL,
    views INT DEFAULT 0,
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);

-- Таблиця тегів
CREATE TABLE tags (
    tag_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Зв'язок постів і тегів
CREATE TABLE post_tags (
    post_id INT REFERENCES posts(post_id),
    tag_id INT REFERENCES tags(tag_id),
    PRIMARY KEY (post_id, tag_id)
);

-- Таблиця коментарів
CREATE TABLE comments (
    comment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INT REFERENCES posts(post_id),
    user_id INT REFERENCES users(user_id),
    text TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Складний запит для отримання посту з коментарями
SELECT
    p.post_id,
    p.title,
    p.content,
    u.username as author,
    c.name as category,
    array_agg(DISTINCT t.name) as tags,
    COUNT(DISTINCT cm.comment_id) as comments_count
FROM posts p
JOIN users u ON p.user_id = u.user_id
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN post_tags pt ON p.post_id = pt.post_id
LEFT JOIN tags t ON pt.tag_id = t.tag_id
LEFT JOIN comments cm ON p.post_id = cm.post_id
WHERE p.status = 'published'
GROUP BY p.post_id, u.username, c.name;
```

**Документна схема (MongoDB):**

```javascript
// Одна колекція з вбудованими даними
{
  _id: ObjectId("..."),
  title: "Назва статті",
  slug: "nazva-statti",
  content: "Текст статті...",
  excerpt: "Короткий опис...",
  author: {
    user_id: ObjectId("..."),
    username: "ivan_developer",
    avatar_url: "..."
  },
  category: {
    category_id: ObjectId("..."),
    name: "Веброзробка"
  },
  tags: ["mongodb", "nosql", "database"],
  comments: [
    {
      comment_id: ObjectId("..."),
      author: { user_id: ObjectId("..."), username: "maria" },
      text: "Коментар...",
      created_at: ISODate("2024-03-15")
    }
  ],
  statistics: {
    views: 542,
    likes: 34,
    comments_count: 5
  },
  status: "published",
  created_at: ISODate("2024-03-10"),
  published_at: ISODate("2024-03-10")
}

// Простий запит без JOIN
db.posts.find({ status: "published" });
```

**Порівняльна таблиця:**

| Критерій | PostgreSQL | MongoDB |
|----------|------------|---------|
| Кількість таблиць/колекцій | 6 таблиць | 3 колекції |
| Складність запитів | Багато JOIN для складних вибірок | Прості `find()` для даних одного документа; `$lookup` для зв'язків між колекціями |
| Продуктивність читання | Залежить від JOIN та індексів | Швидше для типових запитів, під які спроєктовано схему (дані в одному документі) |
| Продуктивність запису | Дані зберігаються в одному місці — оновлення простіші | Оновлення дубльованих даних зачіпає багато документів |
| Гнучкість схеми | Строга, зміни через міграції (для гнучких полів є JSONB) | Гнучка; за потреби обмежується `$jsonSchema` |
| Цілісність даних | FOREIGN KEY, CHECK, UNIQUE на рівні СУБД | `$jsonSchema`-валідація та унікальні індекси; зовнішніх ключів немає, посилання перевіряє застосунок |
| Масштабованість | Переважно вертикальна; читання масштабують репліками, горизонтальне — секціонуванням або розширеннями | Горизонтальна через вбудований шардинг; репліки для відмовостійкості |
| Консистентність | ACID-транзакції | ACID для операцій над одним документом; багатодокументні транзакції підтримуються з версії 4.0, рівень узгодженості налаштовується через read/write concern |

Таблиця узагальнює типові відмінності; у звіті підтверджуйте висновки власними вимірюваннями на тих самих даних та запитах.

[🔼 Здати лабораторну роботу](https://moodle.vcolnuft.volyn.ua/moodle/course/view.php?id=32#section-2)


## ❓ Контрольні запитання

1. Які принципи слід враховувати при проєктуванні документної схеми для NoSQL баз даних?
2. Коли доцільно використовувати вбудовані документи, а коли посилання між документами?
3. Поясніть переваги та недоліки денормалізації даних в документних базах даних.
4. Як реалізувати ефективну пагінацію в MongoDB для великих обсягів даних?
5. Що таке патерн "Bucket" і для яких завдань він використовується?
6. Як забезпечити консистентність даних при денормалізації в MongoDB?
7. Які стратегії індексування найбільш ефективні для блог-системи?
8. Поясніть різницю між горизонтальним та вертикальним масштабуванням баз даних.
9. Як реалізувати транзакції в MongoDB і які обмеження вони мають?
10. Які метрики продуктивності важливі при порівнянні реляційних та документних баз даних?
