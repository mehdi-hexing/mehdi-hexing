---
layout: doc
title: "موضوعات و راهنماها"
lang: "fa-IR"
dir: "rtl"
---

# 📚 دانشنامه و موضوعات

به بخش مستندات و یادداشت‌های فنی خوش آمدید. می‌توانید از طریق دسته‌بندی‌های زیر یا منوی کناری، موضوع مورد نظر خود را مطالعه کنید.

<div class="topics-grid">

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">🐧</span>
      <h3>لینوکس و ترموکس</h3>
    </div>
    <p>راهنماهای کار با شبیه‌ساز ترمینال، دستورات شل، مدیریت پکیج‌ها و ترفندهای لینوکسی.</p>
    <a href="./termux" class="topic-link">مشاهده راهنما ←</a>
  </div>

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">📝</span>
      <h3>مارک‌داون و مستندسازی</h3>
    </div>
    <p>آموزش قواعد نوشتاری Markdown، ساخت جداول، فرمول‌های ریاضی و قالب‌بندی متون.</p>
    <a href="./markdown" class="topic-link">مشاهده راهنما ←</a>
  </div>

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">🤖</span>
      <h3>هوش مصنوعی</h3>
    </div>
    <p>بررسی ابزارهای AI، پرامپت‌نویسی و مدل‌های زبانی روز دنیا.</p>
    <a href="./ai" class="topic-link">مشاهده راهنما ←</a>
  </div>

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">⚙️</span>
      <h3>ابزارها و سرور</h3>
    </div>
    <p>کانفیگ‌ها و راه‌اندازی وورکرها، کلودفلر و ابزارهای بهینه‌سازی شبکه.</p>
    <a href="./zizifn" class="topic-link">مشاهده راهنما ←</a>
  </div>

</div>

<style scoped>
.topics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.25rem;
  margin-top: 2rem;
}

.topic-box {
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  transition: all 0.25s ease;
}

.topic-box:hover {
  transform: translateY(-3px);
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
}

.topic-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.topic-header h3 {
  margin: 0 !important;
  padding: 0 !important;
  font-size: 1.15rem;
  border: none !important;
}

.topic-icon {
  font-size: 1.6rem;
}

.topic-box p {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  line-height: 1.6;
  margin: 0 0 1.25rem 0;
  flex: 1;
}

.topic-link {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  text-decoration: none;
  align-self: flex-start;
}

.topic-link:hover {
  text-decoration: underline;
}
</style>
