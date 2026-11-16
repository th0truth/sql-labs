// ==============================================================================
// Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
// Скрипт 02: Створення комплексу індексів (Unique, Compound, Text, 2dsphere)
// ==============================================================================

const dbTarget = db.getSiblingDB("blog_system");
print("\n>>> 🚀 Налаштування комплексу індексів у 'blog_system'...");

// ------------------------------------------------------------------------------
// 1. Індекси колекції users
// ------------------------------------------------------------------------------
dbTarget.users.createIndex({ username: 1 }, { unique: true, name: "idx_users_username_unique" });
dbTarget.users.createIndex({ email: 1 }, { unique: true, name: "idx_users_email_unique" });
dbTarget.users.createIndex({ role: 1, status: 1 }, { name: "idx_users_role_status" });
dbTarget.users.createIndex({ created_at: -1 }, { name: "idx_users_created_at" });
print(">>> ✅ Створено індекси для колекції 'users'.");

// ------------------------------------------------------------------------------
// 2. Індекси колекції categories
// ------------------------------------------------------------------------------
dbTarget.categories.createIndex({ slug: 1 }, { unique: true, name: "idx_categories_slug_unique" });
dbTarget.categories.createIndex({ name: 1 }, { unique: true, name: "idx_categories_name_unique" });
print(">>> ✅ Створено індекси для колекції 'categories'.");

// ------------------------------------------------------------------------------
// 3. Індекси колекції posts
// ------------------------------------------------------------------------------
// 3.1. Унікальний індекс за URL-friendly slug
dbTarget.posts.createIndex({ slug: 1 }, { unique: true, name: "idx_posts_slug_unique" });

// 3.2. Складений індекс для вибірки постів автора з сортуванням за датою
dbTarget.posts.createIndex(
  { "author.user_id": 1, created_at: -1 },
  { name: "idx_posts_author_date" }
);

// 3.3. Складений індекс для фільтрації за категорією та статусом
dbTarget.posts.createIndex(
  { "category.category_id": 1, status: 1 },
  { name: "idx_posts_category_status" }
);

// 3.4. Частковий індекс для опублікованих постів (Partial Index)
dbTarget.posts.createIndex(
  { published_at: -1 },
  {
    name: "idx_posts_published_partial",
    partialFilterExpression: { status: "published" }
  }
);

// 3.5. Мультиключовий індекс (Multikey) для пошуку за тегами
dbTarget.posts.createIndex({ tags: 1 }, { name: "idx_posts_tags_multikey" });

// 3.6. Повнотекстовий індекс (Text Search)
dbTarget.posts.createIndex(
  { title: "text", content: "text", excerpt: "text" },
  {
    name: "idx_posts_fulltext",
    default_language: "none",
    weights: { title: 10, excerpt: 5, content: 1 }
  }
);

// 3.7. Геопросторовий індекс 2dsphere (Рівень 3)
dbTarget.posts.createIndex({ location: "2dsphere" }, { name: "idx_posts_location_2dsphere" });

print(">>> ✅ Створено повний комплекс індексів для колекції 'posts'.");

// ------------------------------------------------------------------------------
// 4. Індекси для notifications та post_history
// ------------------------------------------------------------------------------
dbTarget.notifications.createIndex({ user_id: 1, read: 1, created_at: -1 });
dbTarget.post_history.createIndex({ post_id: 1, version: -1 });
print(">>> ✅ Створено індекси для 'notifications' та 'post_history'.");

print("\n--- Список індексів колекції posts: ---");
dbTarget.posts.getIndexes().forEach(idx => {
  printjson({ name: idx.name, key: idx.key, unique: !!idx.unique });
});

print("\n>>> 🎉 Усі індекси успішно створено!");
