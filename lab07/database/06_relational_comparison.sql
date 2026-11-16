-- ==============================================================================
-- Лабораторна робота №7. Повний цикл розробки NoSQL застосунку з інтеграцією
-- Скрипт 06: Еквівалентна реляційна схема (PostgreSQL) та порівняльний аналіз
-- ==============================================================================

-- 1. Створення таблиць нормалізованої реляційної моделі (3НФ)
CREATE TABLE IF NOT EXISTS r_users (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'author', 'reader')),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS r_categories (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS r_posts (
    post_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    user_id INT REFERENCES r_users(user_id) ON DELETE CASCADE,
    category_id INT REFERENCES r_categories(category_id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'published', 'archived')),
    views INT DEFAULT 0,
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS r_tags (
    tag_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS r_post_tags (
    post_id INT REFERENCES r_posts(post_id) ON DELETE CASCADE,
    tag_id INT REFERENCES r_tags(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

CREATE TABLE IF NOT EXISTS r_comments (
    comment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INT REFERENCES r_posts(post_id) ON DELETE CASCADE,
    user_id INT REFERENCES r_users(user_id) ON DELETE CASCADE,
    parent_id INT REFERENCES r_comments(comment_id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Складний аналітичний SQL-запит для отримання повного агрегата статті:
-- У реляційній моделі вимагає з'єднання 5 таблиць та агрегації
SELECT
    p.post_id,
    p.title,
    p.slug,
    p.excerpt,
    u.username AS author,
    c.name AS category,
    COALESCE(array_agg(DISTINCT t.name) FILTER (WHERE t.name IS NOT NULL), '{}') AS tags,
    COUNT(DISTINCT cm.comment_id) AS comments_count,
    p.views,
    p.likes,
    p.published_at
FROM r_posts p
JOIN r_users u ON p.user_id = u.user_id
JOIN r_categories c ON p.category_id = c.category_id
LEFT JOIN r_post_tags pt ON p.post_id = pt.post_id
LEFT JOIN r_tags t ON pt.tag_id = t.tag_id
LEFT JOIN r_comments cm ON p.post_id = cm.post_id
WHERE p.status = 'published'
GROUP BY p.post_id, u.username, c.name
ORDER BY p.published_at DESC
LIMIT 10;
