// ==============================================================================
// Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
// Серверний застосунок Express.js + MongoDB Driver (RESTful API & Web Server)
// ==============================================================================

const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';
const DB_NAME = 'blog_system';

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

let db;
let client;

// Проста система кешування в пам'яті з TTL (Рівень 3)
const memoryCache = new Map();
function getFromCache(key) {
  if (!memoryCache.has(key)) return null;
  const item = memoryCache.get(key);
  if (Date.now() - item.time > item.ttl) {
    memoryCache.delete(key);
    return null;
  }
  return item.data;
}

function setToCache(key, data, ttlMs = 30000) {
  memoryCache.set(key, { data, time: Date.now(), ttl: ttlMs });
}

function invalidateCache() {
  memoryCache.clear();
}

// ------------------------------------------------------------------------------
// RESTful API Ендпоінти
// ------------------------------------------------------------------------------

// 1. Отримання списку постів (Пагінація через $facet, пошук, фільтрація)
app.get('/api/posts', async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(50, Math.max(1, parseInt(req.query.limit) || 9));
    const search = req.query.search ? req.query.search.trim() : '';
    const category = req.query.category || '';
    const tag = req.query.tag || '';

    const matchStage = { status: 'published' };

    if (category) {
      matchStage['category.name'] = category;
    }

    if (tag) {
      matchStage.tags = tag;
    }

    if (search) {
      matchStage.$or = [
        { title: { $regex: search, $options: 'i' } },
        { excerpt: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ];
    }

    const facetPipeline = [
      { $match: matchStage },
      { $sort: { published_at: -1, _id: -1 } },
      {
        $facet: {
          items: [
            { $skip: (page - 1) * limit },
            { $limit: limit },
            {
              $project: {
                title: 1,
                slug: 1,
                excerpt: 1,
                author: 1,
                category: 1,
                tags: 1,
                featured_image: 1,
                published_at: 1,
                statistics: 1,
                location: 1
              }
            }
          ],
          meta: [{ $count: 'total' }]
        }
      }
    ];

    const result = await db.collection('posts').aggregate(facetPipeline).toArray();
    const items = result[0]?.items || [];
    const total = result[0]?.meta[0]?.total || 0;

    res.json({
      page,
      limit,
      total_items: total,
      total_pages: Math.ceil(total / limit),
      items
    });
  } catch (err) {
    console.error('Error fetching posts:', err);
    res.status(500).json({ error: 'Помилка отримання постів: ' + err.message });
  }
});

// 2. Детальна інформація про пост (з інкрементом переглядів)
app.get('/api/posts/:slug', async (req, res) => {
  try {
    const slug = req.params.slug;

    // Атомарний інкремент переглядів ($inc)
    const post = await db.collection('posts').findOneAndUpdate(
      { slug: slug },
      { $inc: { 'statistics.views': 1 } },
      { returnDocument: 'after' }
    );

    if (!post) {
      return res.status(404).json({ error: 'Статтю не знайдено' });
    }

    res.json(post);
  } catch (err) {
    console.error('Error fetching post details:', err);
    res.status(500).json({ error: err.message });
  }
});

// 3. Створення нового посту (Рівні 2 та 3)
app.post('/api/posts', async (req, res) => {
  try {
    const { title, content, excerpt, category_id, tags } = req.body;

    if (!title || !content || content.length < 100) {
      return res.status(400).json({
        error: 'Назва та контент обов’язкові. Контент має містити щонайменше 100 символів.'
      });
    }

    // Вибір автора за замовчуванням (або першого автора)
    const author = await db.collection('users').findOne({ role: 'author' }) ||
                   await db.collection('users').findOne();

    // Отримання категорії
    let categoryDoc;
    if (category_id && ObjectId.isValid(category_id)) {
      categoryDoc = await db.collection('categories').findOne({ _id: new ObjectId(category_id) });
    }
    if (!categoryDoc) {
      categoryDoc = await db.collection('categories').findOne();
    }

    // Генерація URL-friendly slug
    const baseSlug = title
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/[\s_-]+/g, '-')
      .replace(/^-+|-+$/g, '') || 'new-article';
    const slug = `${baseSlug}-${Date.now().toString().slice(-4)}`;

    const tagsArray = Array.isArray(tags)
      ? tags
      : (typeof tags === 'string' ? tags.split(',').map(t => t.trim().toLowerCase()).filter(Boolean) : ['general']);

    const newPost = {
      title,
      slug,
      content,
      excerpt: excerpt || content.slice(0, 150) + '...',
      author: {
        user_id: author._id,
        username: author.username,
        avatar_url: author.profile?.avatar_url || `https://api.dicebear.com/9.x/avataaars/svg?seed=${author.username}`
      },
      category: {
        category_id: categoryDoc._id,
        name: categoryDoc.name
      },
      tags: tagsArray,
      featured_image: `https://picsum.photos/800/400?random=${Math.floor(Math.random() * 1000)}`,
      status: 'published',
      location: {
        type: 'Point',
        coordinates: [30.5238, 50.4471] // Київ
      },
      comments: [],
      statistics: {
        views: 1,
        likes: 0,
        comments_count: 0
      },
      version: 1,
      created_at: new Date(),
      updated_at: new Date(),
      published_at: new Date()
    };

    const result = await db.collection('posts').insertOne(newPost);
    await db.collection('categories').updateOne(
      { _id: categoryDoc._id },
      { $inc: { 'statistics.posts_count': 1 } }
    );

    invalidateCache();

    res.status(201).json({
      message: 'Статтю успішно створено!',
      id: result.insertedId,
      slug: slug,
      post: newPost
    });
  } catch (err) {
    console.error('Error creating post:', err);
    res.status(500).json({ error: 'Помилка валідації або збереження: ' + err.message });
  }
});

// 4. Лайк посту ($inc)
app.post('/api/posts/:slug/like', async (req, res) => {
  try {
    const slug = req.params.slug;
    const result = await db.collection('posts').findOneAndUpdate(
      { slug },
      { $inc: { 'statistics.likes': 1 } },
      { returnDocument: 'after' }
    );

    if (!result) {
      return res.status(404).json({ error: 'Статтю не знайдено' });
    }

    res.json({ likes: result.statistics.likes });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Додавання коментаря або відповіді (з вкладеною структурою parent_id)
app.post('/api/posts/:slug/comments', async (req, res) => {
  try {
    const slug = req.params.slug;
    const { username, text, parent_id } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({ error: 'Текст коментаря не може бути порожнім' });
    }

    const post = await db.collection('posts').findOne({ slug });
    if (!post) {
      return res.status(404).json({ error: 'Статтю не знайдено' });
    }

    const commenterName = username && username.trim() ? username.trim() : 'Гість';
    const commentId = new ObjectId();
    const parentCommentId = parent_id && ObjectId.isValid(parent_id) ? new ObjectId(parent_id) : null;

    const newComment = {
      comment_id: commentId,
      parent_id: parentCommentId,
      author: {
        user_id: new ObjectId(),
        username: commenterName
      },
      text: text.trim(),
      status: 'approved',
      likes: 0,
      created_at: new Date()
    };

    // Додавання коментаря та інкремент лічильника
    await db.collection('posts').updateOne(
      { slug },
      {
        $push: { comments: newComment },
        $inc: { 'statistics.comments_count': 1 }
      }
    );

    // Створення сповіщення для автора посту (Рівень 3)
    await db.collection('notifications').insertOne({
      user_id: post.author.user_id,
      type: 'new_comment',
      post_id: post._id,
      post_title: post.title,
      sender: { username: commenterName },
      message: `Новий коментар від ${commenterName} під вашою статтею.`,
      read: false,
      created_at: new Date()
    });

    res.status(201).json({
      message: 'Коментар успішно додано',
      comment: newComment
    });
  } catch (err) {
    console.error('Error adding comment:', err);
    res.status(500).json({ error: err.message });
  }
});

// 6. Отримання категорій
app.get('/api/categories', async (req, res) => {
  try {
    const categories = await db.collection('categories')
      .find({})
      .sort({ 'statistics.posts_count': -1, name: 1 })
      .toArray();
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 7. Аналітична панель та зведена статистика (з кешуванням)
app.get('/api/stats', async (req, res) => {
  try {
    const cached = getFromCache('analytics_summary');
    if (cached) {
      return res.json(Object.assign({}, cached, { from_cache: true }));
    }

    // 1. Агрегація авторів
    const topAuthors = await db.collection('posts').aggregate([
      { $match: { status: 'published' } },
      {
        $group: {
          _id: '$author.user_id',
          username: { $first: '$author.username' },
          posts_count: { $sum: 1 },
          total_views: { $sum: '$statistics.views' },
          total_likes: { $sum: '$statistics.likes' }
        }
      },
      { $sort: { posts_count: -1 } },
      { $limit: 5 }
    ]).toArray();

    // 2. Статистика категорій
    const topCategories = await db.collection('posts').aggregate([
      { $match: { status: 'published' } },
      {
        $group: {
          _id: '$category.name',
          posts_count: { $sum: 1 },
          total_views: { $sum: '$statistics.views' }
        }
      },
      { $sort: { posts_count: -1 } },
      { $limit: 6 }
    ]).toArray();

    // 3. Загальні лічильники
    const postsCount = await db.collection('posts').countDocuments({ status: 'published' });
    const usersCount = await db.collection('users').countDocuments();
    const categoriesCount = await db.collection('categories').countDocuments();

    const sumStats = await db.collection('posts').aggregate([
      { $match: { status: 'published' } },
      {
        $group: {
          _id: null,
          total_views: { $sum: '$statistics.views' },
          total_likes: { $sum: '$statistics.likes' },
          total_comments: { $sum: '$statistics.comments_count' }
        }
      }
    ]).toArray();

    const summary = {
      total_posts: postsCount,
      total_users: usersCount,
      total_categories: categoriesCount,
      total_views: sumStats[0]?.total_views || 0,
      total_likes: sumStats[0]?.total_likes || 0,
      total_comments: sumStats[0]?.total_comments || 0,
      top_authors: topAuthors,
      top_categories: topCategories,
      from_cache: false
    };

    setToCache('analytics_summary', summary, 60000); // 60s кеш
    res.json(summary);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Запуск сервера
async function startServer() {
  try {
    client = new MongoClient(MONGO_URI);
    await client.connect();
    db = client.db(DB_NAME);
    console.log(`✅ Підключено до MongoDB: ${MONGO_URI}/${DB_NAME}`);

    app.listen(PORT, () => {
      console.log(`🚀 Сервер NoSQL блогу працює на http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('❌ Не вдалося запустити сервер:', err);
    process.exit(1);
  }
}

startServer();
