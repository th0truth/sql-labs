// ==============================================================================
// Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
// Скрипт 03: Індексування та порівняльний аналіз продуктивності (explain)
// ==============================================================================

const dbTarget = db.getSiblingDB("library");

print("\n=======================================================");
print(">>> 1. АНАЛІЗ ПЛАНУ ВИКОНАННЯ ДО СТВОРЕННЯ ІНДЕКСІВ");
print("=======================================================");

// Видаляємо всі створені користувачем індекси (крім _id_), якщо вони були
dbTarget.books.dropIndexes();

print("\n--- Запит 1 (ДО індексу): Пошук за автором 'Іван Франко' ---");
const explainBeforeAuthor = dbTarget.books
  .find({ author: "Іван Франко" })
  .explain("executionStats");

print(`Етап виконання (stage): ${explainBeforeAuthor.executionStats.executionStages.stage}`);
print(`Повернуто документів (nReturned): ${explainBeforeAuthor.executionStats.nReturned}`);
print(`Перевірено документів (totalDocsExamined): ${explainBeforeAuthor.executionStats.totalDocsExamined}`);
print(`Час виконання (executionTimeMillis): ${explainBeforeAuthor.executionStats.executionTimeMillis} ms`);

print("\n--- Запит 2 (ДО індексу): Пошук за складеним ключем (автор + рік) ---");
const explainBeforeCompound = dbTarget.books
  .find({ author: "Михайло Коцюбинський", publication_year: { $gte: NumberInt(1900) } })
  .sort({ publication_year: -1 })
  .explain("executionStats");

print(`Етап виконання (stage): ${explainBeforeCompound.executionStats.executionStages.stage}`);
print(`Перевірено документів (totalDocsExamined): ${explainBeforeCompound.executionStats.totalDocsExamined}`);
print(`Час виконання (executionTimeMillis): ${explainBeforeCompound.executionStats.executionTimeMillis} ms`);

print("\n=======================================================");
print(">>> 2. СТВОРЕННЯ ІНДЕКСІВ РІЗНИХ ТИПІВ");
print("=======================================================");

// 2.1. Простий одноколонковий індекс
const idx1 = dbTarget.books.createIndex({ author: 1 }, { name: "idx_books_author" });
print(`[Індекс 1] Створено простий індекс: ${idx1}`);

// 2.2. Складений (compound) індекс з різним напрямком сортування
const idx2 = dbTarget.books.createIndex(
  { author: 1, publication_year: -1 },
  { name: "idx_books_author_year" }
);
print(`[Індекс 2] Створено складений індекс: ${idx2}`);

// 2.3. Унікальний індекс для міжнародного коду ISBN
const idx3 = dbTarget.books.createIndex(
  { isbn: 1 },
  { unique: true, name: "idx_books_isbn_unique" }
);
print(`[Індекс 3] Створено унікальний індекс: ${idx3}`);

print("\n--- Список активних індексів колекції books ---");
dbTarget.books.getIndexes().forEach(idx => {
  printjson({ name: idx.name, key: idx.key, unique: !!idx.unique });
});

print("\n=======================================================");
print(">>> 3. АНАЛІЗ ПЛАНУ ВИКОНАННЯ ПІСЛЯ СТВОРЕННЯ ІНДЕКСІВ");
print("=======================================================");

print("\n--- Запит 1 (ПІСЛЯ індексу): Пошук за автором 'Іван Франко' ---");
const explainAfterAuthor = dbTarget.books
  .find({ author: "Іван Франко" })
  .explain("executionStats");

const stageAuthor = explainAfterAuthor.executionStats.executionStages.stage;
const inputStageAuthor = explainAfterAuthor.executionStats.executionStages.inputStage
  ? explainAfterAuthor.executionStats.executionStages.inputStage.stage
  : "N/A";
print(`Головний етап (stage): ${stageAuthor}`);
print(`Дочірній етап пошуку (inputStage): ${inputStageAuthor}`);
print(`Повернуто документів (nReturned): ${explainAfterAuthor.executionStats.nReturned}`);
print(`Перевірено документів (totalDocsExamined): ${explainAfterAuthor.executionStats.totalDocsExamined}`);
print(`Зчитано ключів індексу (totalKeysExamined): ${explainAfterAuthor.executionStats.totalKeysExamined}`);
print(`Час виконання (executionTimeMillis): ${explainAfterAuthor.executionStats.executionTimeMillis} ms`);

print("\n--- Запит 2 (ПІСЛЯ індексу): Пошук та сортування за складеним ключем ---");
const explainAfterCompound = dbTarget.books
  .find({ author: "Михайло Коцюбинський", publication_year: { $gte: NumberInt(1900) } })
  .sort({ publication_year: -1 })
  .explain("executionStats");

const stageComp = explainAfterCompound.executionStats.executionStages.stage;
const inputStageComp = explainAfterCompound.executionStats.executionStages.inputStage
  ? explainAfterCompound.executionStats.executionStages.inputStage.stage
  : "N/A";
print(`Головний етап (stage): ${stageComp}`);
print(`Дочірній етап пошуку (inputStage): ${inputStageComp}`);
print(`Перевірено документів (totalDocsExamined): ${explainAfterCompound.executionStats.totalDocsExamined}`);
print(`Зчитано ключів індексу (totalKeysExamined): ${explainAfterCompound.executionStats.totalKeysExamined}`);
print(`Час виконання (executionTimeMillis): ${explainAfterCompound.executionStats.executionTimeMillis} ms`);

print("\n=======================================================");
print(">>> 4. ТЕСТУВАННЯ УНІКАЛЬНОГО ІНДЕКСУ (DUPLICATE KEY ERROR)");
print("=======================================================");

try {
  print("Спроба вставити книгу з уже існуючим ISBN '978-966-03-8201-1' (Кобзар)...");
  dbTarget.books.insertOne({
    title: "Кобзар (Фальшивий дублікат)",
    author: "Невідомий",
    publication_year: NumberInt(2024),
    isbn: "978-966-03-8201-1",
    available: true
  });
  print("❌ Помилка: дублікат не мав вставитися!");
} catch (err) {
  print(`✅ УСПІШНЕ ПЕРЕХОПЛЕННЯ: Унікальний індекс заблокував дублікат!`);
  print(`Код помилки MongoDB: ${err.code} (${err.codeName})`);
}

print("\n>>> ✅ Тестування та бенчмаркінг індексів завершено успішно!");
