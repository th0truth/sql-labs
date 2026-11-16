// ==============================================================================
// Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
// Скрипт 04: Агрегаційні запити (Статистика, Пагінація, Теги)
// ==============================================================================

const dbTarget = db.getSiblingDB("blog_system");
print("\n=======================================================");
print(">>> 1. ТОП-10 АВТОРІВ ЗА КІЛЬКІСТЮ ПУБЛІКАЦІЙ ТА ПЕРЕГЛЯДАМИ");
print("=======================================================");

const topAuthorsPipeline = [
  { $match: { status: "published" } },
  {
    $group: {
      _id: "$author.user_id",
      username: { $first: "$author.username" },
      posts_count: { $sum: 1 },
      total_views: { $sum: "$statistics.views" },
      total_likes: { $sum: "$statistics.likes" }
    }
  },
  { $sort: { posts_count: -1, total_views: -1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      author_id: "$_id",
      username: 1,
      posts_count: 1,
      total_views: 1,
      total_likes: 1,
      avg_views_per_post: { $round: [{ $divide: ["$total_views", "$posts_count"] }, 1] }
    }
  }
];

const topAuthors = dbTarget.posts.aggregate(topAuthorsPipeline).toArray();
topAuthors.forEach(a => printjson(a));

print("\n=======================================================");
print(">>> 2. ПОПУЛЯРНІ КАТЕГОРІЇ ЗА АКТИВНІСТЮ ТА ВІДГУКАМИ");
print("=======================================================");

const popularCategoriesPipeline = [
  { $match: { status: "published" } },
  {
    $group: {
      _id: "$category.category_id",
      category_name: { $first: "$category.name" },
      posts_count: { $sum: 1 },
      total_views: { $sum: "$statistics.views" },
      avg_likes: { $avg: "$statistics.likes" }
    }
  },
  { $sort: { posts_count: -1, total_views: -1 } },
  {
    $project: {
      _id: 0,
      category_name: 1,
      posts_count: 1,
      total_views: 1,
      avg_likes: { $round: ["$avg_likes", 1] }
    }
  }
];

const popCategories = dbTarget.posts.aggregate(popularCategoriesPipeline).toArray();
popCategories.forEach(c => printjson(c));

print("\n=======================================================");
print(">>> 3. ЗАГАЛЬНА СТАТИСТИКА КОМЕНТАРІВ У СИСТЕМІ");
print("=======================================================");

const commentsStatsPipeline = [
  { $match: { status: "published" } },
  {
    $project: {
      comments_count: "$statistics.comments_count"
    }
  },
  {
    $group: {
      _id: null,
      total_posts: { $sum: 1 },
      total_comments: { $sum: "$comments_count" },
      avg_comments_per_post: { $avg: "$comments_count" },
      max_comments: { $max: "$comments_count" },
      min_comments: { $min: "$comments_count" }
    }
  },
  {
    $project: {
      _id: 0,
      total_posts: 1,
      total_comments: 1,
      avg_comments_per_post: { $round: ["$avg_comments_per_post", 2] },
      max_comments: 1,
      min_comments: 1
    }
  }
];

const commentsStats = dbTarget.posts.aggregate(commentsStatsPipeline).toArray();
printjson(commentsStats[0]);

print("\n=======================================================");
print(">>> 4. РОЗПОДІЛ СТАТЕЙ ЗА ТЕГАМИ ($unwind + $group)");
print("=======================================================");

const tagsDistributionPipeline = [
  { $match: { status: "published" } },
  { $unwind: "$tags" },
  {
    $group: {
      _id: "$tags",
      count: { $sum: 1 },
      avg_views: { $avg: "$statistics.views" },
      total_likes: { $sum: "$statistics.likes" }
    }
  },
  { $sort: { count: -1, _id: 1 } },
  { $limit: 8 },
  {
    $project: {
      _id: 0,
      tag: "$_id",
      posts_count: "$count",
      avg_views: { $round: ["$avg_views", 0] },
      total_likes: 1
    }
  }
];

const tagsDistribution = dbTarget.posts.aggregate(tagsDistributionPipeline).toArray();
tagsDistribution.forEach(t => printjson(t));

print("\n=======================================================");
print(">>> 5. ПАГІНАЦІЯ ЧЕРЕЗ $facet (СТОРІНКА + ЗАГАЛЬНИЙ COUNT)");
print("=======================================================");

const page = 1;
const perPage = 4;

const facetedPaginationPipeline = [
  { $match: { status: "published" } },
  { $sort: { published_at: -1, _id: -1 } },
  {
    $facet: {
      items: [
        { $skip: (page - 1) * perPage },
        { $limit: perPage },
        {
          $project: {
            title: 1,
            author: "$author.username",
            category: "$category.name",
            published_at: 1,
            views: "$statistics.views",
            likes: "$statistics.likes"
          }
        }
      ],
      meta: [
        { $count: "total_items" }
      ]
    }
  }
];

const paginationResult = dbTarget.posts.aggregate(facetedPaginationPipeline).toArray()[0];
printjson({
  page: page,
  per_page: perPage,
  total_items: paginationResult.meta[0].total_items,
  total_pages: Math.ceil(paginationResult.meta[0].total_items / perPage),
  items_on_page: paginationResult.items.length,
  sample_item: paginationResult.items[0]
});

print("\n=======================================================");
print(">>> 6. ПОШУК ЗА МНОЖИННИМИ ТЕГАМИ ($all: ['mongodb', 'nodejs'])");
print("=======================================================");

const multiTagResults = dbTarget.posts.find(
  { tags: { $all: ["mongodb", "nodejs"] } },
  { title: 1, author: "$author.username", tags: 1, _id: 0 }
).limit(3).toArray();

printjson(multiTagResults);

print("\n>>> ✅ Усі агрегаційні запити успішно виконано!");
