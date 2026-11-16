// ==============================================================================
// Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
// Скрипт 01: Створення бази даних blog_system та налаштування JSON Schema валідації
// ==============================================================================

const dbTarget = db.getSiblingDB("blog_system");
print("\n>>> 🚀 Підключення до бази даних 'blog_system'...");

// Очищення попередніх колекцій для повторюваності
const collectionsToDrop = ["users", "categories", "posts", "notifications", "post_history"];
collectionsToDrop.forEach(col => {
  if (dbTarget.getCollectionNames().includes(col)) {
    dbTarget[col].drop();
    print(`   - Колекцію '${col}' очищено.`);
  }
});

// ------------------------------------------------------------------------------
// 1. Колекція users з валідацією схеми
// ------------------------------------------------------------------------------
dbTarget.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["username", "email", "password_hash", "role", "created_at", "status"],
      properties: {
        username: {
          bsonType: "string",
          minLength: 3,
          maxLength: 30,
          description: "Ім'я користувача (3-30 символів)"
        },
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Валідна адреса електронної пошти"
        },
        password_hash: {
          bsonType: "string",
          minLength: 60,
          description: "Bcrypt-хеш пароля (мінімум 60 символів)"
        },
        role: {
          enum: ["admin", "author", "reader"],
          description: "Роль користувача: admin, author, reader"
        },
        status: {
          enum: ["active", "suspended", "deleted"],
          description: "Статус облікового запису"
        },
        profile: {
          bsonType: "object",
          properties: {
            full_name: { bsonType: "string" },
            bio: { bsonType: "string" },
            avatar_url: { bsonType: "string" },
            website: { bsonType: ["string", "null"] }
          }
        },
        statistics: {
          bsonType: "object",
          properties: {
            posts_count: { bsonType: "int" },
            comments_count: { bsonType: "int" }
          }
        },
        created_at: { bsonType: "date" },
        last_login: { bsonType: ["date", "null"] }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});
print(">>> ✅ Колекцію 'users' з JSON Schema валідацією створено.");

// ------------------------------------------------------------------------------
// 2. Колекція categories з валідацією схеми
// ------------------------------------------------------------------------------
dbTarget.createCollection("categories", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "slug", "created_at"],
      properties: {
        name: {
          bsonType: "string",
          minLength: 2,
          maxLength: 50,
          description: "Назва категорії (2-50 символів)"
        },
        slug: {
          bsonType: "string",
          pattern: "^[a-z0-9-]+$",
          description: "URL-friendly ідентифікатор"
        },
        description: { bsonType: "string" },
        parent_id: { bsonType: ["objectId", "null"] },
        statistics: {
          bsonType: "object",
          properties: {
            posts_count: { bsonType: "int" }
          }
        },
        created_at: { bsonType: "date" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});
print(">>> ✅ Колекцію 'categories' з JSON Schema валідацією створено.");

// ------------------------------------------------------------------------------
// 3. Колекція posts з валідацією схеми
// ------------------------------------------------------------------------------
dbTarget.createCollection("posts", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "slug", "content", "author", "category", "created_at", "status"],
      properties: {
        title: {
          bsonType: "string",
          minLength: 3,
          maxLength: 200,
          description: "Заголовок статті (3-200 символів)"
        },
        slug: {
          bsonType: "string",
          pattern: "^[a-z0-9-]+$",
          description: "Унікальний URL-ідентифікатор"
        },
        content: {
          bsonType: "string",
          minLength: 100,
          description: "Зміст статті (мінімум 100 символів)"
        },
        excerpt: { bsonType: "string" },
        author: {
          bsonType: "object",
          required: ["user_id", "username"],
          properties: {
            user_id: { bsonType: "objectId" },
            username: { bsonType: "string" },
            avatar_url: { bsonType: "string" }
          }
        },
        category: {
          bsonType: "object",
          required: ["category_id", "name"],
          properties: {
            category_id: { bsonType: "objectId" },
            name: { bsonType: "string" }
          }
        },
        tags: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        status: {
          enum: ["draft", "published", "archived"],
          description: "Статус публікації"
        },
        featured_image: { bsonType: "string" },
        location: {
          bsonType: "object",
          properties: {
            type: { enum: ["Point"] },
            coordinates: {
              bsonType: "array",
              minItems: 2,
              maxItems: 2,
              items: { bsonType: ["double", "int", "decimal"] }
            }
          }
        },
        comments: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["comment_id", "author", "text", "created_at", "status"],
            properties: {
              comment_id: { bsonType: "objectId" },
              parent_id: { bsonType: ["objectId", "null"] },
              author: {
                bsonType: "object",
                required: ["user_id", "username"],
                properties: {
                  user_id: { bsonType: "objectId" },
                  username: { bsonType: "string" }
                }
              },
              text: { bsonType: "string", minLength: 1 },
              created_at: { bsonType: "date" },
              status: { enum: ["pending", "approved", "rejected"] },
              likes: { bsonType: "int" }
            }
          }
        },
        statistics: {
          bsonType: "object",
          properties: {
            views: { bsonType: "int" },
            likes: { bsonType: "int" },
            comments_count: { bsonType: "int" }
          }
        },
        version: { bsonType: "int" },
        created_at: { bsonType: "date" },
        updated_at: { bsonType: "date" },
        published_at: { bsonType: ["date", "null"] }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});
print(">>> ✅ Колекцію 'posts' з JSON Schema валідацією створено.");

// ------------------------------------------------------------------------------
// 4. Додаткові колекції (Рівень 3: notifications, post_history)
// ------------------------------------------------------------------------------
dbTarget.createCollection("notifications");
dbTarget.createCollection("post_history");
print(">>> ✅ Колекції 'notifications' та 'post_history' створено.");

print("\n>>> 🎉 Структуру бази даних blog_system успішно ініціалізовано!");
