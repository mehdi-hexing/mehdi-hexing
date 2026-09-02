---
layout: home
lang: "fa-IR"
dir: "rtl"

hero:
  name: "مهدی اسمارت"
  text: "یادداشت‌های من"
  tagline: "کاوش در دنیای تکنولوژی، ابزارها و لینوکس"
  actions:
    - theme: brand
      text: شروع یادگیری
      link: /topics/
    - theme: alt
      text: مشاهده در گیت‌هاب
      link: https://github.com/mehdi-hexing/mehdi-hexing

features:
  - title: "🔒 امنیت و لینوکس"
    details: "بررسی ابزارهای کاربردی، ترفندهای لینوکس و ترموکس."
  - title: "⚙️ ابزارها و کانفیگ‌ها"
    details: "راهنماهای کاربردی برای پیکربندی ابزارها و سرورها."
  - title: "🤖 یادداشت‌های روزمره"
    details: "اشتراک‌گذاری تجربیات فنی و برنامه‌نویسی."
---

<script setup>
import { data as posts } from './.vitepress/posts.data.js'
</script>

<div class="latest-posts-section" v-if="posts && posts.length > 0">
  <h2 class="section-title">آخرین یادداشت‌ها</h2>
  <div class="posts-grid">
    <article v-for="post of posts" :key="post.url" class="post-card">
      <div class="post-category">
        <span class="category-icon">{{ post.categoryIcon }}</span>
        <span class="category-text">{{ post.category }}</span>
      </div>
      <div class="post-content">
        <h3 class="post-title">
          <a :href="post.url" class="post-link">{{ post.title }}</a>
        </h3>
        <p class="post-date">
          <span class="date-icon">📅</span>
          {{ post.date.string }}
        </p>
        <p class="post-excerpt" v-if="post.excerpt">{{ post.excerpt }}</p>
        <div class="post-actions">
          <a :href="post.url" class="read-more">مطالعه مطلب ←</a>
        </div>
      </div>
    </article>
  </div>
</div>

<style scoped>
.latest-posts-section {
  max-width: 1152px;
  margin: 4rem auto 0;
  padding: 0 24px;
}

.section-title {
  font-size: 2rem;
  font-weight: 700;
  color: var(--vp-c-text-1);
  margin-bottom: 2.5rem;
  text-align: center;
  position: relative;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 4px;
  background: linear-gradient(90deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  border-radius: 2px;
}

.posts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 1.5rem;
  margin-top: 2.5rem;
}

.post-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  display: flex;
  flex-direction: column;
}

.post-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 0.3s ease;
}

.post-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
  border-color: var(--vp-c-brand-1);
}

.post-card:hover::before {
  transform: scaleX(1);
}

.post-category {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem 0;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.post-content {
  padding: 1rem 1.5rem 1.5rem;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.post-title {
  margin: 0 0 0.75rem 0;
  font-size: 1.15rem;
  font-weight: 600;
  line-height: 1.4;
}

.post-link {
  color: var(--vp-c-text-1);
  text-decoration: none;
  transition: color 0.3s ease;
}

.post-link:hover {
  color: var(--vp-c-brand-1);
}

.post-date {
  color: var(--vp-c-text-2);
  font-size: 0.8rem;
  margin: 0 0 0.75rem 0;
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.post-excerpt {
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin: 0 0 1.25rem 0;
  font-size: 0.9rem;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: auto;
}

.read-more {
  color: var(--vp-c-brand-1);
  text-decoration: none;
  font-weight: 500;
  font-size: 0.85rem;
  padding: 0.4rem 0.9rem;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.read-more:hover {
  background: var(--vp-c-brand-soft);
}
</style>
