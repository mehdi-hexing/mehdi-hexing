---
layout: doc
title: "Topics & Guides"
lang: "en-US"
dir: "ltr"
---

# 📚 Topics & Documentation

Welcome to the technical docs and knowledge base. You can browse through the categories below or use the sidebar menu.

<div class="topics-grid">

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">🐧</span>
      <h3>Linux & Termux</h3>
    </div>
    <p>Terminal emulator guides, shell commands, package management, and Linux tricks.</p>
    <a href="./termux" class="topic-link">Explore Guide →</a>
  </div>

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">📝</span>
      <h3>Markdown & Docs</h3>
    </div>
    <p>Master Markdown syntax, tables, mathematical notations, and text formatting.</p>
    <a href="./markdown" class="topic-link">Explore Guide →</a>
  </div>

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">🤖</span>
      <h3>Artificial Intelligence</h3>
    </div>
    <p>Explore AI tools, prompt engineering, and state-of-the-art language models.</p>
    <a href="./ai" class="topic-link">Explore Guide →</a>
  </div>

  <div class="topic-box">
    <div class="topic-header">
      <span class="topic-icon">⚙️</span>
      <h3>Tools & Server</h3>
    </div>
    <p>Cloudflare Workers deployment, system configurations, and network utilities.</p>
    <a href="./zizifn" class="topic-link">Explore Guide →</a>
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
