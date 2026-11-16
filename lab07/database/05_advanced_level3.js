// ==============================================================================
// Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
// Скрипт 05: Творче розширення Рівня 3
// 1. Версіонування постів (post_history)
// 2. Вкладені коментарі (Nested Replies)
// 3. Система сповіщень (notifications)
// 4. Геолокаційний пошук ($near на posts.location)
// 5. Демонстрація кешування запитів
// ==============================================================================

const dbTarget = db.getSiblingDB("blog_system");
print("\n=======================================================");
print(">>> 1. СИСТЕМА ВЕРСІОНУВАННЯ ПОСТІВ (DOCUMENT VERSIONING)");
print("=======================================================");

/**
 * Оновлення посту із фіксацією повної історичної копії у post_history
 */
function updatePostWithHistory(slug, updateData, changedBy) {
  const currentPost = dbTarget.posts.findOne({ slug: slug });
  if (!currentPost) {
    throw new Error(`Статтю зі slug '${slug}' не знайдено!`);
  }

  const currentVersion = currentPost.version || NumberInt(1);

  // 1. Збереження поточної версії в архів post_history
  dbTarget.post_history.insertOne({
    post_id: currentPost._id,
    slug: currentPost.slug,
    version: currentVersion,
    snapshot: currentPost,
    applied_changes: updateData,
    changed_by: changedBy,
    changed_at: new Date()
  });

  // 2. Оновлення основного документа
  dbTarget.posts.updateOne(
    { slug: slug },
    {
      $set: Object.assign({}, updateData, { updated_at: new Date() }),
      $inc: { version: NumberInt(1) }
    }
  );

  const updated = dbTarget.posts.findOne({ slug: slug });
  print(`[Версіонування] Статтю '${updated.title}' оновлено до версії v${updated.version} (редактор: ${changedBy}).`);
  return updated;
}

// Демонстрація: 2 послідовних оновлення статті #1
const targetSlug = "article-1-web-development";
print(`\n--- Оновлення №1: редагування заголовка та excerpt ---`);
updatePostWithHistory(
  targetSlug,
  {
    title: "Повний практичний посібник з документної моделі MongoDB (Оновлено для v8.0)",
    excerpt: "Оновлена редакція: впровадження нових операторів агрегації та масштабування."
  },
  "taras_admin"
);

print(`\n--- Оновлення №2: коригування тегів та статусу ---`);
updatePostWithHistory(
  targetSlug,
  {
    tags: ["mongodb", "nosql", "database", "mongodb-8", "performance"]
  },
  "ivan_dev"
);

print(`\n--- Зріз історії версій для '${targetSlug}' з post_history: ---`);
dbTarget.post_history.find({ slug: targetSlug }).sort({ version: 1 }).forEach(h => {
  printjson({
    history_id: h._id,
    version: `v${h.version}`,
    changed_by: h.changed_by,
    changed_at: h.changed_at,
    changes: h.applied_changes
  });
});

print("\n=======================================================");
print(">>> 2. ВКЛАДЕНІ КОМЕНТАРІ (РЕКУРСИВНІ ВІДПОВІДІ parent_id)");
print("=======================================================");

const postWithComments = dbTarget.posts.findOne({ slug: targetSlug });
const rootComment = postWithComments.comments[0];
const replyCommentId = new ObjectId();

// Додавання дочірнього коментаря-відповіді
const replyComment = {
  comment_id: replyCommentId,
  parent_id: rootComment.comment_id, // Вказує на батьківський коментар
  author: {
    user_id: postWithComments.author.user_id,
    username: postWithComments.author.username
  },
  text: `@${rootComment.author.username}, дякую за запитання! Відповідь: так, механізм транзакцій у MongoDB з версії 4.0 повністю підтримує multi-document ACID.`,
  status: "approved",
  likes: NumberInt(8),
  created_at: new Date()
};

dbTarget.posts.updateOne(
  { slug: targetSlug },
  {
    $push: { comments: replyComment },
    $inc: { "statistics.comments_count": NumberInt(1) }
  }
);

print(`>>> ✅ Додано рекурсивну відповідь (parent_id: ${rootComment.comment_id}) від автора.`);

print("\n=======================================================");
print(">>> 3. СИСТЕМА СПОВІЩЕНЬ ДЛЯ АВТОРІВ (NOTIFICATIONS)");
print("=======================================================");

// Створення сповіщення для автора про новий коментар
const newNotification = {
  user_id: postWithComments.author.user_id,
  type: "new_comment",
  post_id: postWithComments._id,
  post_title: postWithComments.title,
  sender: {
    username: rootComment.author.username
  },
  message: `Користувач ${rootComment.author.username} залишив коментар під вашою статтею.`,
  read: false,
  created_at: new Date()
};

dbTarget.notifications.insertOne(newNotification);
print(`>>> ✅ Сповіщення для автора '${postWithComments.author.username}' збережено в базі.`);

print("\n--- Непрочитані сповіщення автора: ---");
dbTarget.notifications.find({ user_id: postWithComments.author.user_id, read: false }).forEach(printjson);

print("\n=======================================================");
print(">>> 4. ГЕОЛОКАЦІЙНИЙ ПОШУК СТАТЕЙ ЗА КООРДИНАТАМИ ($near)");
print("=======================================================");

// Пошук статей, створених авторами в радіусі 30 км від Києва
const kyivPoint = { type: "Point", coordinates: [30.5238, 50.4471] };

const nearbyPosts = dbTarget.posts.find({
  location: {
    $near: {
      $geometry: kyivPoint,
      $maxDistance: 30000 // 30 кілометрів
    }
  }
}, { title: 1, author: "$author.username", location: 1, _id: 0 }).limit(4).toArray();

printjson(nearbyPosts);

print("\n=======================================================");
print(">>> 5. СИСТЕМА КЕШУВАННЯ ЗАПИТІВ (DEMONSTRATION)");
print("=======================================================");

// Імітація кешу в пам'яті (LRU/TTL pattern)
const queryCache = new Map();

function getCachedPopularPosts() {
  const cacheKey = "top_posts_cached";
  const now = Date.now();

  if (queryCache.has(cacheKey)) {
    const entry = queryCache.get(cacheKey);
    if (now - entry.timestamp < 60000) { // 60 секунд TTL
      return { fromCache: true, data: entry.data, timeMs: 0.1 };
    }
  }

  const t0 = Date.now();
  const data = dbTarget.posts.find({ status: "published" }).sort({ "statistics.views": -1 }).limit(5).toArray();
  const t1 = Date.now();

  queryCache.set(cacheKey, { timestamp: now, data: data });
  return { fromCache: false, data: data, timeMs: (t1 - t0) };
}

const req1 = getCachedPopularPosts();
print(`[Запит 1]: З бази даних (Cache MISS) -> знайдено: ${req1.data.length} статей, час: ${req1.timeMs} ms`);

const req2 = getCachedPopularPosts();
print(`[Запит 2]: З оперативної пам'яті (Cache HIT)  -> знайдено: ${req2.data.length} статей, час: ${req2.timeMs} ms`);

print("\n>>> 🎉 Творче розширення Рівня 3 виконано бездоганно!");
