// ==============================================================================
// Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
// Скрипт 04: Агрегаційні пайплайни (Aggregation Pipelines - Рівень 2)
// ==============================================================================

const dbTarget = db.getSiblingDB("library");

print("\n=======================================================");
print(">>> 1. АГРЕГАЦІЯ: КІЛЬКІСТЬ КНИГ ЗА ЖАНРАМИ ($unwind + $group)");
print("=======================================================");

const pipelineGenres = [
  { $unwind: "$genres" },
  {
    $group: {
      _id: "$genres",
      total_books: { $sum: 1 },
      avg_price: { $avg: "$price" },
      titles: { $push: "$title" }
    }
  },
  { $sort: { total_books: -1, _id: 1 } }
];

const genreResults = dbTarget.books.aggregate(pipelineGenres).toArray();
genreResults.forEach(item => {
  printjson({
    genre: item._id,
    total_books: item.total_books,
    avg_price: Math.round(item.avg_price * 100) / 100,
    sample_titles: item.titles.slice(0, 3)
  });
});

print("\n=======================================================");
print(">>> 2. АГРЕГАЦІЯ: СТАТИСТИКА АВТОРІВ (Кількість сторінок та видань)");
print("=======================================================");

const pipelineAuthors = [
  {
    $group: {
      _id: "$author",
      books_count: { $sum: 1 },
      total_pages: { $sum: "$pages" },
      avg_pages: { $avg: "$pages" },
      max_price: { $max: "$price" },
      total_stock: { $sum: "$stock_quantity" }
    }
  },
  { $sort: { books_count: -1, avg_pages: -1 } }
];

const authorResults = dbTarget.books.aggregate(pipelineAuthors).toArray();
authorResults.forEach(item => {
  printjson({
    author: item._id,
    books_count: item.books_count,
    avg_pages: Math.round(item.avg_pages),
    total_stock: item.total_stock,
    max_price: item.max_price
  });
});

print("\n=======================================================");
print(">>> 3. АГРЕГАЦІЯ: РОЗПОДІЛ КНИГ ПО СТОЛІТТЯХ ($project + $group)");
print("=======================================================");

const pipelineCenturies = [
  {
    $project: {
      title: 1,
      author: 1,
      publication_year: 1,
      century: { $ceil: { $divide: ["$publication_year", 100] } }
    }
  },
  {
    $group: {
      _id: "$century",
      count: { $sum: 1 },
      authors: { $addToSet: "$author" },
      min_year: { $min: "$publication_year" },
      max_year: { $max: "$publication_year" }
    }
  },
  { $sort: { _id: 1 } }
];

const centuryResults = dbTarget.books.aggregate(pipelineCenturies).toArray();
centuryResults.forEach(item => {
  printjson({
    century: `${item._id} століття`,
    books_count: item.count,
    time_span: `${item.min_year} - ${item.max_year}`,
    authors_count: item.authors.length,
    authors: item.authors
  });
});

print("\n=======================================================");
print(">>> 4. АГРЕГАЦІЯ: АКТИВНІСТЬ КОРИСТУВАЧІВ ($size + $match + $sort)");
print("=======================================================");

const pipelineUsers = [
  {
    $project: {
      username: 1,
      full_name: 1,
      status: 1,
      borrowed_count: { $size: "$borrowed_books" },
      borrowed_books: 1
    }
  },
  { $match: { status: "active" } },
  { $sort: { borrowed_count: -1, username: 1 } }
];

const userResults = dbTarget.users.aggregate(pipelineUsers).toArray();
userResults.forEach(item => {
  printjson({
    user: item.username,
    name: item.full_name,
    borrowed_count: item.borrowed_count,
    books: item.borrowed_books
  });
});

print("\n=======================================================");
print(">>> 5. АГРЕГАЦІЯ: ОЦІНКА ВАРТОСТІ СКЛАДСЬКИХ ЗАПАСІВ ЗА ЖАНРАМИ");
print("=======================================================");

const pipelineStockValue = [
  { $unwind: "$genres" },
  {
    $group: {
      _id: "$genres",
      total_stock_items: { $sum: "$stock_quantity" },
      total_inventory_value: {
        $sum: { $multiply: ["$price", "$stock_quantity"] }
      }
    }
  },
  { $sort: { total_inventory_value: -1 } },
  { $limit: 5 }
];

const stockValueResults = dbTarget.books.aggregate(pipelineStockValue).toArray();
stockValueResults.forEach(item => {
  printjson({
    genre: item._id,
    stock_units: item.total_stock_items,
    inventory_value_uah: Math.round(item.total_inventory_value * 100) / 100
  });
});

print("\n>>> ✅ Агрегаційні пайплайни виконано успішно!");
