// ==============================================================================
// Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
// Скрипт 06: Творче розширення (Рівень 3)
// 1. Валідація схеми JSON Schema
// 2. Геопросторовий індекс 2dsphere та пошук $near
// 3. Система версіонування документів (Audit & History Tracking)
// ==============================================================================

const dbTarget = db.getSiblingDB("library");

print("\n=======================================================");
print(">>> 1. ВАЛІДАЦІЯ СХЕМИ ДОКУМЕНТІВ (JSON SCHEMA)");
print("=======================================================");

// Застосування суворої валідації до колекції books
const collModResult = dbTarget.runCommand({
  collMod: "books",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "author", "publication_year", "isbn", "available"],
      properties: {
        title: {
          bsonType: "string",
          minLength: 1,
          maxLength: 200,
          description: "Назва книги є обов'язковою та має бути рядком (1-200 символів)"
        },
        author: {
          bsonType: "string",
          minLength: 2,
          description: "Автор є обов'язковим рядком"
        },
        publication_year: {
          bsonType: "int",
          minimum: 1000,
          maximum: 2100,
          description: "Рік видання має бути цілим числом в діапазоні 1000..2100"
        },
        pages: {
          bsonType: "int",
          minimum: 1,
          description: "Кількість сторінок має бути додатнім цілим числом"
        },
        price: {
          bsonType: ["double", "int", "decimal"],
          minimum: 0,
          description: "Ціна має бути невід'ємним числовим значенням"
        },
        isbn: {
          bsonType: "string",
          pattern: "^978-\\d{1,5}-\\d{1,7}-\\d{1,7}-\\d{1}$",
          description: "Формат ISBN має відповідати стандарту 978-XXX-XXX-XXX-X"
        },
        available: {
          bsonType: "bool",
          description: "Ознака доступності книги має бути булевим значенням"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

print(`>>> ✅ JSON Schema валідацію успішно налаштовано (ok: ${collModResult.ok}).`);

// 1.1. Тест: Спроба вставки некоректного документа (рік 3050 та некоректний ISBN)
print("\n--- 1.1. Тест відхилення невалідного документа (publication_year: 3050): ---");
try {
  dbTarget.books.insertOne({
    title: "Некоректна футуристична книга",
    author: "Фейковий автор",
    publication_year: NumberInt(3050), // Порушення: maximum 2100
    isbn: "123-INVALID-ISBN",         // Порушення: pattern regex
    available: true
  });
  print("❌ Помилка: валідатор пропустив невалідний документ!");
} catch (err) {
  print("✅ УСПІШНЕ ПЕРЕХОПЛЕННЯ: СУБД відхилила вставку невалідного документа!");
  print(`Повідомлення валідатора: ${err.message}`);
}

// 1.2. Тест: Вставка повністю валідного документа
print("\n--- 1.2. Тест успішної вставки валідного документа за схемою: ---");
const validBook = {
  title: "Сад Гетсиманський",
  author: "Іван Багряний",
  publication_year: NumberInt(1950),
  pages: NumberInt(560),
  price: 380.00,
  isbn: "978-966-03-8299-9",
  genres: ["роман", "політична проза", "історична драма"],
  available: true,
  stock_quantity: NumberInt(12),
  borrowed_count: NumberInt(40),
  description: "Автобіографічний роман про трагедію радянських репресій та силу людського духу в катівнях НКВС."
};

const validInsertRes = dbTarget.books.insertOne(validBook);
print(`[Валідний insert] Успішно додано книгу з _id: ${validInsertRes.insertedId}`);

print("\n=======================================================");
print(">>> 2. ГЕОПРОСТОРОВИЙ ІНДЕКС ТА ЗАПИТ НА ОСНОВІ КООРДИНАТ");
print("=======================================================");

// Створення індексу 2dsphere на поле location колекції locations
const geoIdx = dbTarget.locations.createIndex(
  { location: "2dsphere" },
  { name: "idx_locations_geospatial" }
);
print(`>>> ✅ Створено геопросторовий індекс 2dsphere: ${geoIdx}`);

// Географічна точка запиту: Майдан Незалежності / Хрещатик (Київ)
const kyivCenterGeoPoint = {
  type: "Point",
  coordinates: [30.5238, 50.4471] // [довгота, широта]
};

print("\n--- Пошук філій бібліотеки в радіусі 5 км від центру Києва ($near / $maxDistance): ---");
const nearbyBranches = dbTarget.locations.find({
  location: {
    $near: {
      $geometry: kyivCenterGeoPoint,
      $maxDistance: 5000 // 5 кілометрів
    }
  }
}).toArray();

nearbyBranches.forEach((branch, idx) => {
  printjson({
    rank: idx + 1,
    name: branch.branch_name,
    city: branch.city,
    address: branch.address,
    coordinates: branch.location.coordinates,
    phone: branch.contact_phone
  });
});

print("\n=======================================================");
print(">>> 3. СИСТЕМА ВЕРСІОНУВАННЯ ДОКУМЕНТІВ (DOCUMENT VERSIONING)");
print("=======================================================");

// Ініціалізація початкової версії 1 для всіх існуючих книг
dbTarget.books.updateMany(
  { version: { $exists: false } },
  { $set: { version: NumberInt(1), updated_at: new Date() } }
);

/**
 * Оновлення документа книги зі збереженням зліпка попередньої версії в book_history
 */
function updateBookWithVersioning(isbn, updateFields, changedBy) {
  const currentDoc = dbTarget.books.findOne({ isbn: isbn });
  if (!currentDoc) {
    throw new Error(`Книгу з ISBN ${isbn} не знайдено!`);
  }

  // 1. Запис зліпка поточного стану в історію версій
  dbTarget.book_history.insertOne({
    book_id: currentDoc._id,
    isbn: currentDoc.isbn,
    title: currentDoc.title,
    version: currentDoc.version || NumberInt(1),
    snapshot: currentDoc,
    changed_by: changedBy,
    changed_at: new Date(),
    applied_changes: updateFields
  });

  // 2. Оновлення документа та інкремент лічильника версії
  dbTarget.books.updateOne(
    { isbn: isbn },
    {
      $set: Object.assign({}, updateFields, { updated_at: new Date() }),
      $inc: { version: NumberInt(1) }
    }
  );

  const updatedDoc = dbTarget.books.findOne({ isbn: isbn });
  print(`[Версіонування] Книгу «${updatedDoc.title}» оновлено до версії v${updatedDoc.version} користувачем ${changedBy}.`);
  return updatedDoc;
}

// Виконаємо 2 послідовні оновлення ціни та наявності книги "Сад Гетсиманський"
print("\n--- Оновлення №1: зміна ціни з 380 на 420 грн та кількості залишку ---");
updateBookWithVersioning(
  "978-966-03-8299-9",
  { price: 420.00, stock_quantity: NumberInt(15) },
  "librarian_taras"
);

print("\n--- Оновлення №2: видача частини тиражу та зміна опису ---");
updateBookWithVersioning(
  "978-966-03-8299-9",
  { stock_quantity: NumberInt(10), borrowed_count: NumberInt(45) },
  "admin_librarian"
);

print("\n--- Журнал історії версій для книги 'Сад Гетсиманський' (book_history): ---");
dbTarget.book_history
  .find({ isbn: "978-966-03-8299-9" })
  .sort({ version: 1 })
  .forEach(h => {
    printjson({
      history_id: h._id,
      version: `v${h.version}`,
      changed_by: h.changed_by,
      changed_at: h.changed_at,
      snapshot_price: h.snapshot.price,
      snapshot_stock: h.snapshot.stock_quantity,
      changes: h.applied_changes
    });
  });

print("\n--- Поточний актуальний стан книги в колекції books: ---");
const finalBook = dbTarget.books.findOne(
  { isbn: "978-966-03-8299-9" },
  { title: 1, author: 1, price: 1, stock_quantity: 1, version: 1, updated_at: 1, _id: 0 }
);
printjson(finalBook);

print("\n>>> 🎉 Творче розширення Рівня 3 виконано бездоганно!");
