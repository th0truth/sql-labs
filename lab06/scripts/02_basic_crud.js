// ==============================================================================
// Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
// Скрипт 02: Базові CRUD операції (Рівень 1)
// ==============================================================================

const dbTarget = db.getSiblingDB("library");

print("\n=======================================================");
print(">>> 1. ОПЕРАЦІЇ ВСТАВКИ (CREATE)");
print("=======================================================");

// 1.1. Вставка одного документа (insertOne)
const singleBook = {
  title: "Сонячна машина",
  author: "Володимир Винниченко",
  publication_year: NumberInt(1928),
  pages: NumberInt(640),
  price: 450.00,
  isbn: "978-966-03-9999-1",
  genres: ["наукова фантастика", "соціальний роман", "утопія"],
  available: true,
  stock_quantity: NumberInt(8),
  borrowed_count: NumberInt(15),
  description: "Перший український науково-фантастичний та філософський роман про винахід машини, що живиться сонячною енергією.",
  ratings: [
    { user: "ivan_petrov", score: NumberInt(5), date: new Date() }
  ]
};

const insertOneRes = dbTarget.books.insertOne(singleBook);
print(`[insertOne] Вставлено книгу з _id: ${insertOneRes.insertedId}`);

// 1.2. Вставка декількох документів (insertMany) - тестові записи
const tempBooks = [
  {
    title: "Тестовий довідник бібліографа №1",
    author: "Тестовий автор А",
    publication_year: NumberInt(2020),
    pages: NumberInt(120),
    available: false,
    is_temporary: true
  },
  {
    title: "Тестовий довідник бібліографа №2",
    author: "Тестовий автор Б",
    publication_year: NumberInt(2021),
    pages: NumberInt(150),
    available: false,
    is_temporary: true
  }
];

const insertManyRes = dbTarget.books.insertMany(tempBooks);
print(`[insertMany] Вставлено ${Object.keys(insertManyRes.insertedIds).length} тимчасових книг.`);

print("\n=======================================================");
print(">>> 2. ОПЕРАЦІЇ ПОШУКУ ТА ЧИТАННЯ (READ)");
print("=======================================================");

// 2.1. Пошук за точною рівністю
print("\n--- 2.1. Доступні книги (available: true) [limit 3] ---");
dbTarget.books.find({ available: true }, { title: 1, author: 1, price: 1, _id: 0 }).limit(3).forEach(printjson);

// 2.2. Пошук за діапазоном значень ($gt, $lte)
print("\n--- 2.2. Книги з кількістю сторінок від 150 до 350 ---");
dbTarget.books.find(
  { pages: { $gte: NumberInt(150), $lte: NumberInt(350) } },
  { title: 1, author: 1, pages: 1, _id: 0 }
).forEach(printjson);

// 2.3. Пошук за входженням до масиву ($in)
print("\n--- 2.3. Книги авторів: Тарас Шевченко або Леся Українка ---");
dbTarget.books.find(
  { author: { $in: ["Тарас Шевченко", "Леся Українка"] } },
  { title: 1, author: 1, publication_year: 1, _id: 0 }
).forEach(printjson);

// 2.4. Пошук із логічним оператором $or та фільтром масиву
print("\n--- 2.4. Логічне АБО ($or: роман або автор Василь Стефаник) ---");
dbTarget.books.find(
  {
    $or: [
      { genres: "роман" },
      { author: "Василь Стефаник" }
    ]
  },
  { title: 1, author: 1, genres: 1, _id: 0 }
).limit(4).forEach(printjson);

// 2.5. Регулярний вираз ($regex) — пошук без урахування регістру
print("\n--- 2.5. Пошук за шаблоном regex (/пісня|тіні/i) ---");
dbTarget.books.find(
  { title: { $regex: /пісня|тіні/i } },
  { title: 1, author: 1, publication_year: 1, _id: 0 }
).forEach(printjson);

// 2.6. Сортування та проєкція (Топ-3 найдорожчі книги)
print("\n--- 2.6. Топ-3 найдорожчі видання (sort price: -1) ---");
dbTarget.books.find(
  {},
  { title: 1, author: 1, price: 1, _id: 0 }
).sort({ price: -1 }).limit(3).forEach(printjson);

print("\n=======================================================");
print(">>> 3. ОПЕРАЦІЇ ОНОВЛЕННЯ (UPDATE)");
print("=======================================================");

// 3.1. updateOne з $set (зміна ціни та наявності)
const updateSetRes = dbTarget.books.updateOne(
  { title: "Сонячна машина" },
  { $set: { price: 420.00, last_inspected: new Date() } }
);
print(`[updateOne $set] Змінено документів: ${updateSetRes.modifiedCount}`);

// 3.2. updateOne з $push (додавання нового відгуку до масиву ratings)
const updatePushRes = dbTarget.books.updateOne(
  { title: "Сонячна машина" },
  {
    $push: {
      ratings: {
        user: "maria_koval",
        score: NumberInt(5),
        comment: "Чудовий філософсько-утопічний роман!",
        date: new Date()
      }
    }
  }
);
print(`[updateOne $push] Додано відгук до масиву ratings: ${updatePushRes.modifiedCount}`);

// 3.3. updateOne з $inc (інкремент кількості видач)
const updateIncRes = dbTarget.books.updateOne(
  { title: "Сонячна машина" },
  { $inc: { borrowed_count: NumberInt(1), stock_quantity: NumberInt(-1) } }
);
print(`[updateOne $inc] Інкрементовано лічильник видач: ${updateIncRes.modifiedCount}`);

// 3.4. updateMany (масове оновлення категорії класичних видань)
const updateManyRes = dbTarget.books.updateMany(
  { publication_year: { $lt: NumberInt(1900) } },
  { $set: { century_era: "Класична література XIX ст." } }
);
print(`[updateMany] Оновлено категорію для видань XIX ст.: ${updateManyRes.modifiedCount}`);

// 3.5. replaceOne (повна заміна документа крім _id)
const replaceRes = dbTarget.books.replaceOne(
  { title: "Тестовий довідник бібліографа №1" },
  {
    title: "Тестовий довідник бібліографа №1 (Оновлене перевидання)",
    author: "Тестовий автор А",
    publication_year: NumberInt(2024),
    pages: NumberInt(160),
    available: true,
    is_temporary: true,
    replaced_at: new Date()
  }
);
print(`[replaceOne] Повністю замінено документ: ${replaceRes.modifiedCount}`);

print("\n=======================================================");
print(">>> 4. ОПЕРАЦІЇ ВИДАЛЕННЯ (DELETE)");
print("=======================================================");

// 4.1. deleteOne (видалення одного документа)
const deleteOneRes = dbTarget.books.deleteOne({ title: "Тестовий довідник бібліографа №1 (Оновлене перевидання)" });
print(`[deleteOne] Видалено документ: ${deleteOneRes.deletedCount}`);

// 4.2. deleteMany (видалення всіх тимчасових документів за фільтром)
const deleteManyRes = dbTarget.books.deleteMany({ is_temporary: true });
print(`[deleteMany] Видалено тимчасових документів: ${deleteManyRes.deletedCount}`);

print("\n>>> ✅ Базові CRUD операції виконано успішно!");
