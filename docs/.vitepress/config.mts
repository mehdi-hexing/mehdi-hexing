import { defineConfig } from 'vitepress'
import footnote from 'markdown-it-footnote'
import mathjax3 from 'markdown-it-mathjax3'
import attrs from 'markdown-it-attrs'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import { withMermaid } from 'vitepress-plugin-mermaid'

const base = '/mehdi-hexing/'

export default withMermaid(defineConfig({
  base,
  cleanUrls: true,
  ignoreDeadLinks: true,
  title: 'NoteBook',
  description: 'یادداشت‌های من',

  head: [
    ['link', { rel: 'icon', href: `${base}favicon.ico` }],
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: 'anonymous' }],
    [
      'link',
      {
        href: 'https://fonts.googleapis.com/css2?family=Vazirmatn:wght@100..900&family=Inter:wght@100..900&display=swap',
        rel: 'stylesheet',
      },
    ],
    ['meta', { name: 'theme-color', content: '#5f67ee' }],
  ],

  markdown: {
    config: (md) => {
      md.use(footnote)
      md.use(attrs)
      md.use(mathjax3)
      md.use(tabsMarkdownPlugin)
    },
    lineNumbers: true,
  },

  mermaid: { theme: 'default' },

  themeConfig: {
    logo: '/logo.svg',
    search: { provider: 'local' },
    lastUpdated: {
      text: 'Last updated',
      formatOptions: { dateStyle: 'medium', timeStyle: 'short' },
    },
    returnToTopLabel: 'Back to top',
    sidebarMenuLabel: 'Menu',
    darkModeSwitchLabel: 'Theme',
  },

  locales: {
    root: {
      label: 'فارسی',
      lang: 'fa-IR',
      dir: 'rtl',
      themeConfig: {
        nav: [
          { text: '🏠 خانه', link: '/' },
          { text: '📖 موضوعات', link: '/topics/' },
          { text: '🔗 گیت‌هاب', link: 'https://github.com/mehdi-hexing/mehdi-hexing' },
        ],
        sidebar: {
          '/topics/': [
            {
              text: '🧭 شروع',
              collapsed: false,
              items: [
                { text: 'آموزش Markdown', link: '/topics/markdown' },
                { text: 'آموزش ترموکس', link: '/topics/termux' },
                { text: 'ابزار‌های هوش مصنوعی', link: '/topics/ai' },
                { text: 'راه‌اندازی وورکر zizifn', link: '/topics/zizifn' },
                { text: 'مستندات ، راه‌اندازی و مطالب تکمیلی ProxyIPChecker', link: '/topics/CF-ProxyIPChecker' },
              ],
            },
          ],
        },
        docFooter: { prev: 'صفحه قبلی', next: 'صفحه بعدی' },
        editLink: {
          pattern: 'https://github.com/mehdi-hexing/mehdi-hexing/edit/main/docs/:path',
          text: 'این صفحه را ویرایش کنید',
        },
        outline: { level: [2, 3], label: 'On this page' },
      },
    },

    en: {
      label: 'English',
      lang: 'en-US',
      dir: 'ltr',
      themeConfig: {
        nav: [
          { text: '🏠 Home', link: '/en/' },
          { text: '📖 Topics', link: '/en/topics/' },
          { text: '🔗 GitHub', link: 'https://github.com/mehdi-hexing/mehdi-hexing' },
        ],
        sidebar: {
          '/en/topics/': [
            {
              text: '🧭 Get Started',
              collapsed: false,
              items: [
                { text: 'Markdown Guide', link: '/en/topics/markdown' },
                { text: 'Termux Guide', link: '/en/topics/termux' },
                { text: 'AI Tools', link: '/en/topics/ai' },
                { text: 'Serverless runtime', link: '/en/topics/zizifn' },
                { text: 'ProxyIPChecker Documentation, Setup, and Additional Content', link: '/en/topics/CF-ProxyIPChecker' },
              ],
            },
          ],
        },
        docFooter: { prev: 'Previous', next: 'Next' },
        outline: { level: [2, 3], label: 'On this page' },
      },
    },
  },

  vite: {
    optimizeDeps: {
      include: ['mermaid', 'fastdom'],
      exclude: [
        'video.js',
        '@nolebase/vitepress-plugin-inline-link-preview/client',
      ],
    },
    ssr: {
      noExternal: [
        /@nolebase\/vitepress-plugin-.*/,
        '@nolebase/ui',
      ],
    },
  },
}))
