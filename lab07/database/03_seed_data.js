// ==============================================================================
// Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
// Скрипт 03: Генерація 20 користувачів, 10 категорій, 50 постів та 250+ коментарів
// ==============================================================================

const dbTarget = db.getSiblingDB("blog_system");
print("\n>>> 🚀 Початок генерації тестового датасету для 'blog_system'...");

// ------------------------------------------------------------------------------
// 1. Створення 20 користувачів
// ------------------------------------------------------------------------------
const userNames = [
  { username: "taras_admin", name: "Тарас Шевчук", role: "admin", bio: "Головний системний адміністратор та DBA" },
  { username: "ivan_dev", name: "Іван Петренко", role: "author", bio: "Senior Fullstack Developer (Node.js & MongoDB)" },
  { username: "maria_ai", name: "Марія Коваль", role: "author", bio: "Data Scientist та дослідниця LLM систем" },
  { username: "oleg_devops", name: "Олег Бойко", role: "author", bio: "DevOps Engineer, Cloud Architect (K8s & Docker)" },
  { username: "anna_sec", name: "Анна Мельник", role: "author", bio: "Cybersecurity Specialist, PenTester" },
  { username: "dmytro_arch", name: "Дмитро Бондар", role: "author", bio: "Solutions Architect, шанувальник мікросервісів" },
  { username: "olena_ui", name: "Олена Кравець", role: "author", bio: "Lead Product Designer & UX Researcher" },
  { username: "serhii_db", name: "Сергій Ткаченко", role: "author", bio: "Database Performance Tuning Guru" },
  { username: "yulia_qa", name: "Юлія Мороз", role: "author", bio: "QA Automation Lead (Cypress, Playwright)" },
  { username: "andriy_mobile", name: "Андрій Романюк", role: "author", bio: "Mobile App Developer (Flutter & Swift)" },
  { username: "reader_viktor", name: "Віктор Павлюк", role: "reader", bio: "Студент комп'ютерних наук" },
  { username: "reader_natalia", name: "Наталія Савчук", role: "reader", bio: "Frontend розробниця-початківиця" },
  { username: "reader_maksym", name: "Максим Демченко", role: "reader", bio: "Ентузіаст відкритого коду" },
  { username: "reader_khrystyna", name: "Христина Лисенко", role: "reader", bio: "Технічна авторка та перекладачка" },
  { username: "reader_denys", name: "Денис Гриценко", role: "reader", bio: "Backend розробник (Python & Django)" },
  { username: "reader_svitlana", name: "Світлана Сидоренко", role: "reader", bio: "Аналітикиня бізнес-процесів" },
  { username: "reader_yaroslav", name: "Ярослав Вовк", role: "reader", bio: "Системний інженер Linux" },
  { username: "reader_iryna", name: "Ірина Костенко", role: "reader", bio: "Junior Data Analyst" },
  { username: "reader_artur", name: "Артур Білик", role: "reader", bio: "Студент факультету кібербезпеки" },
  { username: "reader_daria", name: "Дарія Клименко", role: "reader", bio: "Початківиця в UI/UX дизайні" }
];

const mockBcryptHash = "$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW"; // 60 chars bcrypt hash

const usersToInsert = userNames.map((u, idx) => ({
  username: u.username,
  email: `${u.username}@itblog.ua`,
  password_hash: mockBcryptHash,
  role: u.role,
  status: "active",
  profile: {
    full_name: u.name,
    bio: u.bio,
    avatar_url: `https://api.dicebear.com/9.x/avataaars/svg?seed=${u.username}`,
    website: idx % 3 === 0 ? `https://${u.username}.dev` : null
  },
  statistics: {
    posts_count: NumberInt(0),
    comments_count: NumberInt(0)
  },
  created_at: new Date(Date.now() - (180 - idx * 5) * 24 * 3600 * 1000),
  last_login: new Date()
}));

dbTarget.users.insertMany(usersToInsert);
print(`>>> ✅ Вставлено ${dbTarget.users.countDocuments()} користувачів.`);

// ------------------------------------------------------------------------------
// 2. Створення 10 тематичних IT-категорій
// ------------------------------------------------------------------------------
const categoriesData = [
  { name: "Веброзробка", slug: "web-development", description: "Сучасний стек веброзробки: React, Vue, Node.js та мікрофронтенди" },
  { name: "Бази даних", slug: "databases", description: "Проєктування, оптимізація та порівняння SQL та NoSQL систем (PostgreSQL, MongoDB)" },
  { name: "DevOps та CI/CD", slug: "devops", description: "Автоматизація інфраструктури, Docker, Kubernetes та хмарні конвеєри" },
  { name: "Штучний інтелект", slug: "artificial-intelligence", description: "Машинне навчання, генеративні LLM моделі та інженерія промптів" },
  { name: "Мобільні технології", slug: "mobile-development", description: "Створення нативних та кросплатформних додатків для iOS та Android" },
  { name: "Хмарні сервіси", slug: "cloud-computing", description: "Архітектура та сервіси AWS, Google Cloud Platform, Microsoft Azure" },
  { name: "Кібербезпека", slug: "cybersecurity", description: "Захист вебзастосунків, криптографія, OWASP Top 10 та автентифікація" },
  { name: "UX/UI Дизайн", slug: "ux-ui-design", description: "Дослідження користувацького досвіду, ергономіка інтерфейсів та Figma" },
  { name: "Архітектура ПЗ", slug: "software-architecture", description: "Шаблони проєктування, чиста архітектура, DDD та асинхронні черги" },
  { name: "Тестування та QA", slug: "testing-qa", description: "Автоматизоване тестування, навантажувальні тести та забезпечення якості" }
];

const categoriesToInsert = categoriesData.map(c => ({
  name: c.name,
  slug: c.slug,
  description: c.description,
  parent_id: null,
  statistics: { posts_count: NumberInt(0) },
  created_at: new Date(Date.now() - 200 * 24 * 3600 * 1000)
}));

dbTarget.categories.insertMany(categoriesToInsert);
print(`>>> ✅ Вставлено ${dbTarget.categories.countDocuments()} категорій.`);

// Кешування користувачів та категорій
const allAuthors = dbTarget.users.find({ role: { $in: ["admin", "author"] } }).toArray();
const allUsersList = dbTarget.users.find().toArray();
const allCategories = dbTarget.categories.find().toArray();

// ------------------------------------------------------------------------------
// 3. Генерація 50 повноцінних IT-статей
// ------------------------------------------------------------------------------
const tagsLibrary = [
  "mongodb", "nosql", "nodejs", "express", "javascript", "typescript",
  "docker", "kubernetes", "postgresql", "python", "react", "architecture",
  "devops", "cloud", "security", "jwt", "testing", "ai", "machine-learning"
];

// Координати українських міст (Київ, Львів, Харків, Дніпро, Одеса, Луцьк, Вінниця)
const cityCoordinates = [
  [30.5238, 50.4471], // Київ (Хрещатик)
  [30.5186, 50.4678], // Київ (Поділ)
  [24.0311, 49.8355], // Львів (Центр)
  [36.2304, 49.9935], // Харків
  [35.0462, 48.4647], // Дніпро
  [30.7233, 46.4825], // Одеса
  [25.3254, 50.7472], // Луцьк
  [28.4682, 49.2331]  // Вінниця
];

const articleTemplates = [
  {
    titlePrefix: "Повний практичний посібник з документної моделі MongoDB",
    excerpt: "Як правильно проєктувати схеми BSON без надлишкової денормалізації та досягати пікової швидкості.",
    body: "Документо-орієнтовані бази даних кардинально змінюють підхід до структурування корпоративних даних. На відміну від реляційного світу з жорсткими таблицями та нормалізацією до 3НФ, MongoDB дозволяє вбудовувати пов'язані агрегати безпосередньо у документ статті. Завдяки цьому ми отримуємо атомарні оновлення, відсутність ресурсомістких операцій JOIN та нативну підтримку масивів. У цій статті ми детально розглянемо найкращі практики побудови агрегаційних конвеєрів та створення індексів для оптимізації читання."
  },
  {
    titlePrefix: "Архітектура високопродуктивних RESTful API на Node.js",
    excerpt: "Створення надійних ендпоінтів з валідацією, пагінацією та кешуванням у пам'яті.",
    body: "Розробка корпоративного вебсервера вимагає балансу між гнучкістю та надійністю. Використання мікрофреймворків у поєднанні з пулом з'єднань MongoClient забезпечує обробку тисяч одночасних запитів. Важливо реалізувати ефективну пагінацію через курсори або агрегаційний етап $facet, що повертає як порцію даних, так і загальну кількість записів за один запит до СУБД. Також розглянемо інтеграцію JWT автентифікації та захист від XSS-атак."
  },
  {
    titlePrefix: "Оптимізація запитів та індексація в сучасних NoSQL базах",
    excerpt: "Аналіз виконання запитів через explain executionStats та усунення етапу COLLSCAN.",
    body: "Індексація є наріжним каменем продуктивності будь-якої бази даних. У MongoDB правильне поєднання полів у складеному індексі (Equality, Sort, Range - правило ESR) здатне прискорити запит у сотні разів. Ми детально порівняємо плани виконання запитів до та після створення індексів, розберемо роботу покриваючих індексів (Index Only Scans) та покажемо, як часткові індекси (Partial Indexes) заощаджують оперативну пам'ять сервера."
  },
  {
    titlePrefix: "Контейнеризація вебсервісів за допомогою Docker та Compose",
    excerpt: "Створення відтворюваного виробничого середовища для MongoDB та серверного застосунку.",
    body: "Сучасна інженерія неможлива без ізольованих контейнерів. Налаштування багатоконтейнерної зв'язки через Docker Compose дозволяє однією командою розгорнути базу даних MongoDB з персистентними томами (volumes), healthcheck перевірками та вебсервером. Ми розглянемо налаштування мережевих мостів, конфігурацію змінних середовища через .env та оптимізацію розміру фінальних образів за допомогою multi-stage builds."
  },
  {
    titlePrefix: "Кібербезпека вебінтерфейсів: від валідації схем до захисту API",
    excerpt: "Практичні методи запобігання NoSQL Injection та безпечного зберігання паролів.",
    body: "Безпека інформаційної системи повинна закладатися на архітектурному рівні. Впровадження суворої валідації через JSON Schema безпосередньо у колекціях MongoDB блокує збереження шкідливих або пошкоджених документів ще на рівні ядра СУБД. Крім того, паролі користувачів обов'язково хешуються алгоритмами Argon2 або Bcrypt із додаванням криптографічної солі, унеможливлюючи злам через веселкові таблиці."
  }
];

const postsToInsert = [];

for (let i = 1; i <= 50; i++) {
  const author = allAuthors[(i - 1) % allAuthors.length];
  const category = allCategories[(i - 1) % allCategories.length];
  const template = articleTemplates[(i - 1) % articleTemplates.length];
  const coords = cityCoordinates[(i - 1) % cityCoordinates.length];

  // Вибір 2-4 тегів
  const postTags = [];
  const tagCount = (i % 3) + 2;
  for (let t = 0; t < tagCount; t++) {
    const candidateTag = tagsLibrary[(i + t * 3) % tagsLibrary.length];
    if (!postTags.includes(candidateTag)) postTags.push(candidateTag);
  }

  // Гарантуємо спільні теги для тестування $all
  if (i % 5 === 1) {
    if (!postTags.includes("mongodb")) postTags.push("mongodb");
    if (!postTags.includes("nodejs")) postTags.push("nodejs");
  }

  const postDate = new Date(Date.now() - (60 - i) * 24 * 3600 * 1000);
  const slug = `article-${i}-${category.slug}`;

  postsToInsert.push({
    title: `${template.titlePrefix} (Частина ${i})`,
    slug: slug,
    content: `${template.body} У цьому розділі #${i} ми детально розглядаємо архітектурні рішення, практичні приклади коду та реальні вимірювання продуктивності для вебсистем високої доступності під навантаженням.`,
    excerpt: `${template.excerpt} Випуск №${i}.`,
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
    location: {
      type: "Point",
      coordinates: coords
    },
    comments: [],
    statistics: {
      views: NumberInt(120 + i * 37),
      likes: NumberInt(10 + (i * 7) % 85),
      comments_count: NumberInt(0)
    },
    version: NumberInt(1),
    created_at: postDate,
    updated_at: postDate,
    published_at: postDate
  });
}

dbTarget.posts.insertMany(postsToInsert);
print(`>>> ✅ Вставлено ${dbTarget.posts.countDocuments()} статей.`);

// ------------------------------------------------------------------------------
// 4. Генерація 250+ вкладених коментарів (з ієрархією відповідей parent_id)
// ------------------------------------------------------------------------------
const commentTexts = [
  "Дуже корисний матеріал! Особливо сподобалося пояснення індексації.",
  "Чи планується продовження статті з детальними бенчмарками?",
  "Дякую за статтю, впровадили аналогічну схему в своєму проєкті — працює бездоганно!",
  "Маю питання щодо обробки транзакцій: чи достатньо реплікації для відмовостійкості?",
  "Чудова структурована подача, збережу собі в закладки для підготовки до співбесіди.",
  "Повністю згоден з авторкою щодо денормалізації, це значно спрощує клієнтський код.",
  "Підкажіть, будь ласка, як краще моніторити повільні запити на production сервері?",
  "Цікава ідея з патерном Bucket, обов'язково протестуємо для аналітики переходів."
];

let totalCommentsCount = 0;
const allInsertedPosts = dbTarget.posts.find().toArray();

allInsertedPosts.forEach((post, pIdx) => {
  // Від 4 до 7 коментарів на статтю (50 * 5.5 ~= 275 коментарів)
  const count = 4 + (pIdx % 4);
  const postComments = [];

  for (let c = 0; c < count; c++) {
    const commenter = allUsersList[(pIdx + c * 3) % allUsersList.length];
    const commentId = new ObjectId();
    const isReply = c > 1 && postComments.length > 0 && (c % 2 === 1);
    const parentId = isReply ? postComments[0].comment_id : null;
    const textPrefix = isReply ? `@${postComments[0].author.username}, ` : "";

    postComments.push({
      comment_id: commentId,
      parent_id: parentId,
      author: {
        user_id: commenter._id,
        username: commenter.username
      },
      text: `${textPrefix}${commentTexts[(pIdx + c) % commentTexts.length]}`,
      status: "approved",
      likes: NumberInt(c * 3),
      created_at: new Date(post.created_at.getTime() + (c + 1) * 3600 * 1000)
    });
    totalCommentsCount++;
  }

  // Оновлення коментарів статті та статистики
  dbTarget.posts.updateOne(
    { _id: post._id },
    {
      $set: {
        comments: postComments,
        "statistics.comments_count": NumberInt(postComments.length)
      }
    }
  );
});

print(`>>> ✅ Згенеровано та вбудовано ${totalCommentsCount} коментарів.`);

// ------------------------------------------------------------------------------
// 5. Оновлення лічильників статистики у users та categories
// ------------------------------------------------------------------------------
dbTarget.categories.find().forEach(cat => {
  const pCount = dbTarget.posts.countDocuments({ "category.category_id": cat._id });
  dbTarget.categories.updateOne({ _id: cat._id }, { $set: { "statistics.posts_count": NumberInt(pCount) } });
});

dbTarget.users.find().forEach(u => {
  const pCount = dbTarget.posts.countDocuments({ "author.user_id": u._id });
  let cCount = 0;
  dbTarget.posts.find({ "comments.author.user_id": u._id }).forEach(p => {
    cCount += p.comments.filter(c => c.author.user_id.equals(u._id)).length;
  });
  dbTarget.users.updateOne(
    { _id: u._id },
    {
      $set: {
        "statistics.posts_count": NumberInt(pCount),
        "statistics.comments_count": NumberInt(cCount)
      }
    }
  );
});

print(">>> ✅ Статистику користувачів та категорій успішно перераховано.");
print("\n>>> 🎉 Базу даних blog_system успішно наповнено реалістичними даними!");
