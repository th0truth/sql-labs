// ==============================================================================
// Лабораторна робота №6. Робота з СУБД MongoDB та реалізація операцій
// Скрипт 01: Ініціалізація бази даних library та початкове наповнення даними
// Рівні 1-3: Створення колекцій authors, books, users, locations
// ==============================================================================

const dbName = "library";
const targetDb = db.getSiblingDB(dbName);

print(`\n>>> 🚀 Підключення до бази даних "${dbName}"...`);

// Очищення попередніх колекцій для повторюваності результатів
targetDb.books.drop();
targetDb.authors.drop();
targetDb.users.drop();
targetDb.locations.drop();
targetDb.book_history.drop();
if (targetDb.getCollectionNames().includes("available_books")) {
    targetDb.available_books.drop();
}

print(">>> 🧹 Попередні колекції очищено.");

// ------------------------------------------------------------------------------
// 1. Колекція: authors (10 авторів із вкладеними об'єктами та масивами)
// ------------------------------------------------------------------------------
const authorsData = [
  {
    name: "Тарас Шевченко",
    birth_year: 1814,
    death_year: 1861,
    nationality: "українська",
    genre_focus: ["поезія", "драматургія", "проза"],
    biography: {
      birth_place: "Моринці, Черкащина",
      education: "Петербурзька академія мистецтв",
      era: "Романтизм"
    },
    awards: ["Академік гравюри", "Національний пророк"],
    created_at: new Date("2024-01-01T10:00:00Z")
  },
  {
    name: "Леся Українка",
    birth_year: 1871,
    death_year: 1913,
    nationality: "українська",
    genre_focus: ["драма-феєрія", "поезія", "публіцистика"],
    biography: {
      birth_place: "Звягель, Житомирщина",
      education: "Приватна освіта, самоосвіта",
      era: "Модернізм"
    },
    awards: ["Орден національної класики"],
    created_at: new Date("2024-01-02T10:00:00Z")
  },
  {
    name: "Іван Франко",
    birth_year: 1856,
    death_year: 1916,
    nationality: "українська",
    genre_focus: ["роман", "повість", "поезія", "філософія"],
    biography: {
      birth_place: "Нагуєвичі, Львівщина",
      education: "Львівський та Віденський університети (доктор філософії)",
      era: "Реалізм, модернізм"
    },
    awards: ["Номінант на Нобелівську премію з літератури 1916"],
    created_at: new Date("2024-01-03T10:00:00Z")
  },
  {
    name: "Михайло Коцюбинський",
    birth_year: 1864,
    death_year: 1913,
    nationality: "українська",
    genre_focus: ["психологічна новела", "імпресіонізм", "повість"],
    biography: {
      birth_place: "Вінниця",
      education: "Шаргородське духовне училище",
      era: "Імпресіонізм"
    },
    awards: ["Майстер психологічної прози"],
    created_at: new Date("2024-01-04T10:00:00Z")
  },
  {
    name: "Панас Мирний",
    birth_year: 1849,
    death_year: 1920,
    nationality: "українська",
    genre_focus: ["соціально-психологічний роман", "повість"],
    biography: {
      birth_place: "Миргород, Полтавщина",
      education: "Гадяцьке повітове училище",
      era: "Критичний реалізм"
    },
    awards: ["Корифей української прози"],
    created_at: new Date("2024-01-05T10:00:00Z")
  },
  {
    name: "Григорій Квітка-Основ'яненко",
    birth_year: 1778,
    death_year: 1843,
    nationality: "українська",
    genre_focus: ["сентиментальна повість", "комедія"],
    biography: {
      birth_place: "Основа, Харківщина",
      education: "Курязький монастир, домашня освіта",
      era: "Сентименталізм"
    },
    awards: ["Батько української художньої прози"],
    created_at: new Date("2024-01-06T10:00:00Z")
  },
  {
    name: "Василь Стефаник",
    birth_year: 1871,
    death_year: 1936,
    nationality: "українська",
    genre_focus: ["психологічна новела", "експресіонізм"],
    biography: {
      birth_place: "Русів, Івано-Франківщина",
      education: "Ягеллонський університет (Краків)",
      era: "Експресіонізм"
    },
    awards: ["Майстер експресіоністичної новели"],
    created_at: new Date("2024-01-07T10:00:00Z")
  },
  {
    name: "Микола Хвильовий",
    birth_year: 1893,
    death_year: 1933,
    nationality: "українська",
    genre_focus: ["романтична новела", "памфлет", "модернізм"],
    biography: {
      birth_place: "Тростянець, Сумщина",
      education: "Охтирська гімназія",
      era: "Розстріляне відродження"
    },
    awards: ["Лідер ВАПЛІТЕ"],
    created_at: new Date("2024-01-08T10:00:00Z")
  },
  {
    name: "Валер'ян Підмогильний",
    birth_year: 1901,
    death_year: 1937,
    nationality: "українська",
    genre_focus: ["урбаністичний роман", "екзистенціалізм"],
    biography: {
      birth_place: "Чаплі, Дніпропетровщина",
      education: "Катеринославське реальне училище",
      era: "Розстріляне відродження"
    },
    awards: ["Засновник українського урбаністичного роману"],
    created_at: new Date("2024-01-09T10:00:00Z")
  },
  {
    name: "Олександр Довженко",
    birth_year: 1894,
    death_year: 1956,
    nationality: "українська",
    genre_focus: ["кіноповість", "автобіографічна проза"],
    biography: {
      birth_place: "Сосниця, Чернігівщина",
      education: "Глухівський учительський інститут",
      era: "Поетичний реалізм"
    },
    awards: ["Класик світового кінематографа", "Ленінська премія"],
    created_at: new Date("2024-01-10T10:00:00Z")
  }
];

const authorInsertResult = targetDb.authors.insertMany(authorsData);
print(`>>> ✅ Додано ${Object.keys(authorInsertResult.insertedIds).length} авторів.`);

// Створення карти авторів: name -> ObjectId
const authorMap = {};
targetDb.authors.find().forEach(a => {
  authorMap[a.name] = a._id;
});

// ------------------------------------------------------------------------------
// 2. Колекція: books (15 книг із вкладеними рейтингами, жанрами, посиланням на автора)
// ------------------------------------------------------------------------------
const booksData = [
  {
    title: "Кобзар",
    author: "Тарас Шевченко",
    author_id: authorMap["Тарас Шевченко"],
    publication_year: NumberInt(1840),
    pages: NumberInt(238),
    price: 320.00,
    isbn: "978-966-03-8201-1",
    genres: ["поезія", "романтизм", "класика"],
    available: true,
    stock_quantity: NumberInt(25),
    borrowed_count: NumberInt(142),
    description: "Перше видання збірки поетичних творів Тараса Шевченка 1840 року в Петербурзі, що започаткувало нову епоху української літератури.",
    ratings: [
      { user: "ivan_petrov", score: NumberInt(5), date: new Date("2024-01-10") },
      { user: "maria_koval", score: NumberInt(5), date: new Date("2024-01-15") },
      { user: "oleg_boyko", score: NumberInt(5), date: new Date("2024-02-01") }
    ]
  },
  {
    title: "Гайдамаки",
    author: "Тарас Шевченко",
    author_id: authorMap["Тарас Шевченко"],
    publication_year: NumberInt(1841),
    pages: NumberInt(160),
    price: 180.00,
    isbn: "978-966-03-8202-8",
    genres: ["поезія", "історична поема"],
    available: true,
    stock_quantity: NumberInt(15),
    borrowed_count: NumberInt(84),
    description: "Героїко-історична епічна поема про коліївщину та боротьбу українського селянства.",
    ratings: [
      { user: "anna_melnyk", score: NumberInt(4), date: new Date("2024-01-12") }
    ]
  },
  {
    title: "Лісова пісня",
    author: "Леся Українка",
    author_id: authorMap["Леся Українка"],
    publication_year: NumberInt(1911),
    pages: NumberInt(128),
    price: 210.00,
    isbn: "978-966-03-8203-5",
    genres: ["драма", "феєрія", "фольклор", "романтизм"],
    available: true,
    stock_quantity: NumberInt(20),
    borrowed_count: NumberInt(119),
    description: "Драма-феєрія в трьох діях про взаємини людини і природи, кохання Мавки та Лукаша в поліських хащах.",
    ratings: [
      { user: "maria_koval", score: NumberInt(5), date: new Date("2024-02-05") },
      { user: "dmytro_bondar", score: NumberInt(4), date: new Date("2024-02-18") }
    ]
  },
  {
    title: "Бояриня",
    author: "Леся Українка",
    author_id: authorMap["Леся Українка"],
    publication_year: NumberInt(1910),
    pages: NumberInt(96),
    price: 150.00,
    isbn: "978-966-03-8204-2",
    genres: ["драма", "історична п'єса"],
    available: false,
    stock_quantity: NumberInt(0),
    borrowed_count: NumberInt(62),
    description: "Драматична поема про психологічну прірву між українською та московською ментальністю XVII століття.",
    ratings: [
      { user: "ivan_petrov", score: NumberInt(5), date: new Date("2024-01-20") }
    ]
  },
  {
    title: "Захар Беркут",
    author: "Іван Франко",
    author_id: authorMap["Іван Франко"],
    publication_year: NumberInt(1883),
    pages: NumberInt(256),
    price: 240.00,
    isbn: "978-966-03-8205-9",
    genres: ["роман", "історична проза", "пригоди"],
    available: true,
    stock_quantity: NumberInt(18),
    borrowed_count: NumberInt(97),
    description: "Історична повість про героїчну боротьбу тухольської громади проти монголо-татарської навали 1241 року.",
    ratings: [
      { user: "dmytro_bondar", score: NumberInt(5), date: new Date("2024-01-25") },
      { user: "oleg_boyko", score: NumberInt(4), date: new Date("2024-02-11") }
    ]
  },
  {
    title: "Каменярі",
    author: "Іван Франко",
    author_id: authorMap["Іван Франко"],
    publication_year: NumberInt(1878),
    pages: NumberInt(64),
    price: 120.00,
    isbn: "978-966-03-8206-6",
    genres: ["поезія", "громадянська лірика"],
    available: true,
    stock_quantity: NumberInt(12),
    borrowed_count: NumberInt(45),
    description: "Програмний вірш-алегорія про руйнування скелі неволі заради побудови нового вільного шляху.",
    ratings: [
      { user: "anna_melnyk", score: NumberInt(5), date: new Date("2024-02-14") }
    ]
  },
  {
    title: "Тіні забутих предків",
    author: "Михайло Коцюбинський",
    author_id: authorMap["Михайло Коцюбинський"],
    publication_year: NumberInt(1911),
    pages: NumberInt(112),
    price: 190.00,
    isbn: "978-966-03-8207-3",
    genres: ["повість", "імпресіонізм", "містика", "романтизм"],
    available: true,
    stock_quantity: NumberInt(30),
    borrowed_count: NumberInt(135),
    description: "Гуцульська трагедія вічного кохання Івана та Марічки посеред мальовничих та містичних Карпатських гір.",
    ratings: [
      { user: "maria_koval", score: NumberInt(5), date: new Date("2024-01-18") },
      { user: "ivan_petrov", score: NumberInt(5), date: new Date("2024-02-02") },
      { user: "volodymyr_tkach", score: NumberInt(4), date: new Date("2024-02-28") }
    ]
  },
  {
    title: "Intermezzo",
    author: "Михайло Коцюбинський",
    author_id: authorMap["Михайло Коцюбинський"],
    publication_year: NumberInt(1909),
    pages: NumberInt(72),
    price: 140.00,
    isbn: "978-966-03-8208-0",
    genres: ["психологічна новела", "імпресіонізм"],
    available: true,
    stock_quantity: NumberInt(10),
    borrowed_count: NumberInt(53),
    description: "Шедевр українського психологічного імпресіонізму про зцілення втомленої душі серед конопель, нив та сонця.",
    ratings: [
      { user: "volodymyr_tkach", score: NumberInt(5), date: new Date("2024-03-01") }
    ]
  },
  {
    title: "Хіба ревуть воли, як ясла повні",
    author: "Панас Мирний",
    author_id: authorMap["Панас Мирний"],
    publication_year: NumberInt(1880),
    pages: NumberInt(384),
    price: 290.00,
    isbn: "978-966-03-8209-7",
    genres: ["роман", "реалізм", "соціальна проза"],
    available: true,
    stock_quantity: NumberInt(14),
    borrowed_count: NumberInt(76),
    description: "Перший монументальний соціально-психологічний роман про долю бунтівника Чіпки Варениченка.",
    ratings: [
      { user: "anna_melnyk", score: NumberInt(4), date: new Date("2024-01-28") }
    ]
  },
  {
    title: "Конотопська відьма",
    author: "Григорій Квітка-Основ'яненко",
    author_id: authorMap["Григорій Квітка-Основ'яненко"],
    publication_year: NumberInt(1837),
    pages: NumberInt(112),
    price: 160.00,
    isbn: "978-966-03-8210-3",
    genres: ["сатирична повість", "бурлеск", "містика"],
    available: true,
    stock_quantity: NumberInt(22),
    borrowed_count: NumberInt(89),
    description: "Сатирично-фантастична повість про сотника Забрьоху, писаря Пістряка та полювання на відьом у Конотопі.",
    ratings: [
      { user: "ivan_petrov", score: NumberInt(5), date: new Date("2024-02-19") }
    ]
  },
  {
    title: "Маруся",
    author: "Григорій Квітка-Основ'яненко",
    author_id: authorMap["Григорій Квітка-Основ'яненко"],
    publication_year: NumberInt(1834),
    pages: NumberInt(96),
    price: 130.00,
    isbn: "978-966-03-8211-0",
    genres: ["сентименталізм", "повість"],
    available: false,
    stock_quantity: NumberInt(0),
    borrowed_count: NumberInt(38),
    description: "Перша україномовна сентиментальна повість про зворушливе кохання Марусі та Василя.",
    ratings: [
      { user: "maria_koval", score: NumberInt(4), date: new Date("2024-01-08") }
    ]
  },
  {
    title: "Камінний хрест",
    author: "Василь Стефаник",
    author_id: authorMap["Василь Стефаник"],
    publication_year: NumberInt(1900),
    pages: NumberInt(48),
    price: 110.00,
    isbn: "978-966-03-8212-7",
    genres: ["психологічна новела", "експресіонізм"],
    available: true,
    stock_quantity: NumberInt(16),
    borrowed_count: NumberInt(68),
    description: "Драматична новела про трагедію еміграції галицьких селян за океан на прикладі Івана Дідуха.",
    ratings: [
      { user: "oleg_boyko", score: NumberInt(5), date: new Date("2024-02-22") }
    ]
  },
  {
    title: "Я (Романтика)",
    author: "Микола Хвильовий",
    author_id: authorMap["Микола Хвильовий"],
    publication_year: NumberInt(1924),
    pages: NumberInt(64),
    price: 150.00,
    isbn: "978-966-03-8213-4",
    genres: ["психологічна новела", "експресіонізм", "модернізм"],
    available: true,
    stock_quantity: NumberInt(20),
    borrowed_count: NumberInt(92),
    description: "Психологічна новела про фатальний розкол людської душі між фанатичною вірністю революції та синівською любов'ю.",
    ratings: [
      { user: "volodymyr_tkach", score: NumberInt(5), date: new Date("2024-03-05") }
    ]
  },
  {
    title: "Місто",
    author: "Валер'ян Підмогильний",
    author_id: authorMap["Валер'ян Підмогильний"],
    publication_year: NumberInt(1928),
    pages: NumberInt(320),
    price: 310.00,
    isbn: "978-966-03-8214-1",
    genres: ["урбаністичний роман", "екзистенціалізм", "модернізм"],
    available: true,
    stock_quantity: NumberInt(25),
    borrowed_count: NumberInt(165),
    description: "Перший український урбаністичний роман про підкорення Києва молодим провінціалом Степаном Радченком.",
    ratings: [
      { user: "ivan_petrov", score: NumberInt(5), date: new Date("2024-02-10") },
      { user: "maria_koval", score: NumberInt(5), date: new Date("2024-02-25") }
    ]
  },
  {
    title: "Зачарована Десна",
    author: "Олександр Довженко",
    author_id: authorMap["Олександр Довженко"],
    publication_year: NumberInt(1956),
    pages: NumberInt(128),
    price: 190.00,
    isbn: "978-966-03-8215-8",
    genres: ["автобіографічна повість", "поетичний реалізм"],
    available: true,
    stock_quantity: NumberInt(18),
    borrowed_count: NumberInt(108),
    description: "Автобіографічна кіноповість — гімн річці Десні, рідному селу Сосниця, працьовитим людям і поетичному дитинству.",
    ratings: [
      { user: "dmytro_bondar", score: NumberInt(5), date: new Date("2024-03-02") }
    ]
  }
];

const booksInsertResult = targetDb.books.insertMany(booksData);
print(`>>> ✅ Додано ${Object.keys(booksInsertResult.insertedIds).length} книг.`);

// ------------------------------------------------------------------------------
// 3. Колекція: users (10 читачів бібліотеки з історією абонемента)
// ------------------------------------------------------------------------------
const usersData = [
  {
    username: "ivan_petrov",
    full_name: "Іван Петров",
    email: "ivan.petrov@library.ua",
    role: "reader",
    registration_date: new Date("2023-09-01T08:30:00Z"),
    status: "active",
    borrowed_books: ["Кобзар", "Тіні забутих предків", "Місто"],
    preferences: ["поезія", "модернізм", "урбанізм"]
  },
  {
    username: "maria_koval",
    full_name: "Марія Коваленко",
    email: "maria.koval@library.ua",
    role: "reader",
    registration_date: new Date("2023-10-15T12:00:00Z"),
    status: "active",
    borrowed_books: ["Лісова пісня", "Маруся"],
    preferences: ["драма", "сентименталізм"]
  },
  {
    username: "dmytro_bondar",
    full_name: "Дмитро Бондар",
    email: "dmytro.bondar@library.ua",
    role: "reader",
    registration_date: new Date("2023-11-20T14:15:00Z"),
    status: "active",
    borrowed_books: ["Захар Беркут", "Зачарована Десна"],
    preferences: ["історична проза", "пригоди"]
  },
  {
    username: "anna_melnyk",
    full_name: "Анна Мельник",
    email: "anna.melnyk@library.ua",
    role: "reader",
    registration_date: new Date("2023-12-05T09:45:00Z"),
    status: "active",
    borrowed_books: ["Хіба ревуть воли, як ясла повні"],
    preferences: ["соціальна проза", "реалізм"]
  },
  {
    username: "oleg_boyko",
    full_name: "Олег Бойко",
    email: "oleg.boyko@library.ua",
    role: "reader",
    registration_date: new Date("2024-01-10T16:20:00Z"),
    status: "active",
    borrowed_books: ["Камінний хрест", "Кобзар"],
    preferences: ["експресіонізм", "класика"]
  },
  {
    username: "volodymyr_tkach",
    full_name: "Володимир Ткач",
    email: "volodymyr.tkach@library.ua",
    role: "reader",
    registration_date: new Date("2024-01-18T11:00:00Z"),
    status: "active",
    borrowed_books: ["Я (Романтика)", "Intermezzo"],
    preferences: ["імпресіонізм", "модернізм"]
  },
  {
    username: "olena_kravets",
    full_name: "Олена Кравець",
    email: "olena.kravets@library.ua",
    role: "reader",
    registration_date: new Date("2024-02-01T15:30:00Z"),
    status: "active",
    borrowed_books: [],
    preferences: ["поезія", "драма"]
  },
  {
    username: "taras_shevchuk",
    full_name: "Тарас Шевчук",
    email: "taras.shevchuk@library.ua",
    role: "librarian",
    registration_date: new Date("2023-01-10T08:00:00Z"),
    status: "active",
    borrowed_books: [],
    preferences: ["бібліографія", "архівна справа"]
  },
  {
    username: "svitlana_moroz",
    full_name: "Світлана Мороз",
    email: "svitlana.moroz@library.ua",
    role: "reader",
    registration_date: new Date("2023-05-12T13:40:00Z"),
    status: "suspended",
    borrowed_books: ["Бояриня"],
    preferences: ["історія", "драма"]
  },
  {
    username: "admin_librarian",
    full_name: "Адміністратор Бібліотеки",
    email: "admin@library.ua",
    role: "admin",
    registration_date: new Date("2022-01-01T00:00:00Z"),
    status: "active",
    borrowed_books: [],
    preferences: ["управління", "безпека"]
  }
];

const usersInsertResult = targetDb.users.insertMany(usersData);
print(`>>> ✅ Додано ${Object.keys(usersInsertResult.insertedIds).length} користувачів.`);

// ------------------------------------------------------------------------------
// 4. Колекція: locations (5 філій бібліотеки з GeoJSON координатами для Рівня 3)
// ------------------------------------------------------------------------------
const locationsData = [
  {
    branch_name: "Центральна міська бібліотека ім. Лесі Українки",
    city: "Київ",
    address: "вул. Велика Васильківська, 136",
    contact_phone: "+380445290001",
    location: {
      type: "Point",
      coordinates: [30.5234, 50.4172] // [longitude, latitude]
    },
    reading_halls: NumberInt(4),
    capacity: NumberInt(250)
  },
  {
    branch_name: "Філія №1 'Подільська книгозбірня'",
    city: "Київ",
    address: "вул. Спаська, 12",
    contact_phone: "+380444250002",
    location: {
      type: "Point",
      coordinates: [30.5186, 50.4678]
    },
    reading_halls: NumberInt(2),
    capacity: NumberInt(80)
  },
  {
    branch_name: "Філія №2 'Шевченківський читальний зал'",
    city: "Київ",
    address: "б-р Тараса Шевченка, 22",
    contact_phone: "+380442340003",
    location: {
      type: "Point",
      coordinates: [30.5055, 50.4431]
    },
    reading_halls: NumberInt(3),
    capacity: NumberInt(120)
  },
  {
    branch_name: "Львівська наукова філія",
    city: "Львів",
    address: "вул. Драгоманова, 5",
    contact_phone: "+380322390004",
    location: {
      type: "Point",
      coordinates: [24.0311, 49.8355]
    },
    reading_halls: NumberInt(5),
    capacity: NumberInt(300)
  },
  {
    branch_name: "Волинська обласна юнацька філія",
    city: "Луцьк",
    address: "пр. Волі, 2",
    contact_phone: "+380332720005",
    location: {
      type: "Point",
      coordinates: [25.3254, 50.7472]
    },
    reading_halls: NumberInt(2),
    capacity: NumberInt(100)
  }
];

const locationsInsertResult = targetDb.locations.insertMany(locationsData);
print(`>>> ✅ Додано ${Object.keys(locationsInsertResult.insertedIds).length} філій бібліотеки (GeoJSON).`);

print("\n>>> 🎉 Ініціалізація бази даних library успішно завершена!");
