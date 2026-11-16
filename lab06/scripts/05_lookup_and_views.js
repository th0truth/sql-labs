// ==============================================================================
// Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
// Скрипт 05: З'єднання $lookup, Представлення (View) та Текстовий пошук (Рівень 2)
// ==============================================================================

const dbTarget = db.getSiblingDB("library");

print("\n=======================================================");
print(">>> 1. ОБ'ЄДНАННЯ КОЛЕКЦІЙ ЧЕРЕЗ $lookup (АНАЛОГ SQL JOIN)");
print("=======================================================");

// Гарантуємо, що кожна книга має прив'язку author_id до колекції authors
dbTarget.authors.find().forEach(author => {
  dbTarget.books.updateMany(
    { author: author.name },
    { $set: { author_id: author._id } }
  );
});

const lookupPipeline = [
  {
    $lookup: {
      from: "authors",
      localField: "author_id",
      foreignField: "_id",
      as: "author_info"
    }
  },
  { $unwind: "$author_info" },
  {
    $project: {
      title: 1,
      author_name: "$author_info.name",
      author_era: "$author_info.biography.era",
      birth_place: "$author_info.biography.birth_place",
      publication_year: 1,
      price: 1,
      available: 1
    }
  },
  { $sort: { publication_year: 1 } },
  { $limit: 5 }
];

print("\n--- Результат $lookup (Книги + біографічні дані автора): ---");
dbTarget.books.aggregate(lookupPipeline).forEach(item => {
  printjson({
    title: item.title,
    author: item.author_name,
    era: item.author_era,
    birth_place: item.birth_place,
    year: item.publication_year,
    price: `${item.price} грн`,
    available: item.available ? "В наявності" : "Видано"
  });
});

print("\n=======================================================");
print(">>> 2. СТВОРЕННЯ ТА ВИКОРИСТАННЯ ПРЕДСТАВЛЕННЯ (VIEW)");
print("=======================================================");

// Видаляємо представлення, якщо воно існувало
try {
  dbTarget.available_books.drop();
} catch (e) {}

// Створення представлення для доступних книг з розрахунком клубної ціни (знижка 10%)
dbTarget.createView(
  "available_books",
  "books",
  [
    { $match: { available: true } },
    {
      $project: {
        title: 1,
        author: 1,
        genres: 1,
        publication_year: 1,
        regular_price: "$price",
        club_price: { $round: [{ $multiply: ["$price", 0.90] }, 2] },
        stock_quantity: 1
      }
    },
    { $sort: { publication_year: -1 } }
  ]
);

print(">>> ✅ Представлення 'available_books' успішно створено.");

print("\n--- Вибірка з представлення available_books (перші 4 записи): ---");
dbTarget.available_books.find({}, { _id: 0 }).limit(4).forEach(printjson);

print("\n=======================================================");
print(">>> 3. ПОВНОТЕКСТОВИЙ ПОШУК (TEXT INDEX & $text SEARCH)");
print("=======================================================");

// Видаляємо попередній текстовий індекс, якщо він існував
try {
  dbTarget.books.dropIndex("idx_books_text_search");
} catch (e) {}

// Створення текстового індексу по полях title та description
// Використовуємо default_language: "none" для коректної токенізації українських слів без англійського стемінгу
const textIdx = dbTarget.books.createIndex(
  { title: "text", description: "text" },
  { default_language: "none", name: "idx_books_text_search" }
);
print(`>>> ✅ Створено текстовий індекс: ${textIdx}`);

print("\n--- Пошук за ключовими словами: 'кохання Карпатських' ---");
const searchResults1 = dbTarget.books.find(
  { $text: { $search: "кохання Карпатських" } },
  { title: 1, author: 1, score: { $meta: "textScore" }, _id: 0 }
).sort({ score: { $meta: "textScore" } }).toArray();

searchResults1.forEach(res => {
  printjson({
    title: res.title,
    author: res.author,
    relevance_score: Math.round(res.score * 100) / 100
  });
});

print("\n--- Пошук за фразою: 'роман' (з релевантністю) ---");
const searchResults2 = dbTarget.books.find(
  { $text: { $search: "роман" } },
  { title: 1, author: 1, score: { $meta: "textScore" }, _id: 0 }
).sort({ score: { $meta: "textScore" } }).limit(4).toArray();

searchResults2.forEach(res => {
  printjson({
    title: res.title,
    author: res.author,
    relevance_score: Math.round(res.score * 100) / 100
  });
});

print("\n>>> ✅ Скрипт 05 успішно виконано!");
