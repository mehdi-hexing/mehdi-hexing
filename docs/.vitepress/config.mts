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
    socialLinks: [
      { icon: 'github', link: 'https://github.com/mehdi-hexing/' },
      {
        icon: {
          svg: '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="m20.665 3.717-17.73 6.837c-1.21.486-1.203 1.161-.222 1.462l4.552 1.42 10.532-6.645c.498-.303.953-.14.579.192l-8.533 7.701h-.002l-.002.001-.314 4.692c.46 0 .663-.211.921-.46l2.211-2.15 4.599 3.397c.848.467 1.457.227 1.668-.785l3.019-14.228c.309-1.239-.473-1.8-1.282-1.434z"/></svg>'
        },
        link: 'https://t.me/mehdiasmart',
        ariaLabel: 'Telegram'
      }
    ],
  },

  locales: {
    root: {
      label: 'فارسی',
      lang: 'fa-IR',
      dir: 'rtl',
      themeConfig: {
        returnToTopLabel: 'بازگشت به بالا',
        sidebarMenuLabel: 'منوی جانبی',
        darkModeSwitchLabel: 'تغییر تم',
        langMenuLabel: 'تغییر زبان',
        outline: { level: [2, 3], label: 'در این صفحه' },
        docFooter: { prev: 'صفحه قبلی', next: 'صفحه بعدی' },
        editLink: {
          pattern: 'https://github.com/mehdi-hexing/mehdi-hexing/edit/main/docs/:path',
          text: 'این صفحه را ویرایش کنید',
        },
        nav: [
          { text: '🏠 خانه', link: '/' },
          { text: '📖 موضوعات', link: '/topics/' },
        ],
        sidebar: {
          '/topics/': [
            {
              text: '🧭 شروع',
              collapsed: false,
              items: [
                { text: 'آموزش ترموکس', link: '/topics/termux' },
                { text: 'آموزش Markdown', link: '/topics/markdown' },
                { text: 'مستندات ECH-Workers', link: '/topics/ECH-Workers' },
                { text: 'ابزار‌های هوش مصنوعی', link: '/topics/ai' },
                { text: 'مستندات Domain-Resolve', link: '/topics/Domain-Resolve' },
                { text: 'راه‌اندازی وورکر zizifn', link: '/topics/zizifn' },
                { text: 'مستندات ProxyIP-Tel-Bot', link: '/topics/ProxyIP-Tel-Bot' },
                { text: 'مستندات و نکات HTTP-PROXY', link: '/topics/HTTP-PROXY' },
                { text: 'مطالب تکمیلی ProxyIPChecker', link: '/topics/CF-ProxyIPChecker' },
                { text: 'مطالب Cloudflare-Scamalytics', link: '/topics/Cloudflare-Scamalytics' },
                { text: 'مطالب مربوط به Check-Host-API', link: '/topics/Check-Host-API' },
                { text: 'حل مشکل ریجن در سرویس های گوگل', link: '/topics/WorkerPlacementGemini' },
                { text: 'راهنمای استفاده از سرویس MTProto در بستر katabump', link: '/topics/KataBumpMTProtoSetup' },
                { text: 'راهنمای استفاده از سرویس Hysteria2 در بستر katabump', link: '/topics/Hysteria2Setup' },
              ],
            },
          ],
        },
      },
    },

    en: {
      label: 'English',
      lang: 'en-US',
      dir: 'ltr',
      themeConfig: {
        returnToTopLabel: 'Return to top',
        sidebarMenuLabel: 'Menu',
        darkModeSwitchLabel: 'Appearance',
        langMenuLabel: 'Change language',
        outline: { level: [2, 3], label: 'On this page' },
        docFooter: { prev: 'Previous', next: 'Next' },
        editLink: {
          pattern: 'https://github.com/mehdi-hexing/mehdi-hexing/edit/main/docs/:path',
          text: 'Edit this page on GitHub',
        },
        nav: [
          { text: '🏠 Home', link: '/en/' },
          { text: '📖 Topics', link: '/en/topics/' },
        ],
        sidebar: {
          '/en/topics/': [
            {
              text: '🧭 Get Started',
              collapsed: false,
              items: [
                { text: 'AI Tools', link: '/en/topics/ai' },
                { text: 'Termux Guide', link: '/en/topics/termux' },
                { text: 'Markdown Guide', link: '/en/topics/markdown' },
                { text: 'Serverless runtime', link: '/en/topics/zizifn' },
                { text: 'HTTP-PROXY documentation', link: '/en/topics/HTTP-PROXY' },
                { text: 'ECH-Workers documentation', link: '/en/topics/ECH-Workers' },
                { text: 'Domain-Resolve documentation', link: '/en/topics/Domain-Resolve' },
                { text: 'Check-Host-API documentation', link: '/en/topics/Check-Host-API' },
                { text: 'Documentation ProxyIP-Tel-Bot', link: '/en/topics/ProxyIP-Tel-Bot' },
                { text: 'MTProto service on the katabump', link: '/en/topics/KataBumpMTProtoSetup' },
                { text: 'Hysteria2 service on the katabump', link: '/en/topics/Hysteria2Setup' },
                { text: 'ProxyIPChecker Additional Content', link: '/en/topics/CF-ProxyIPChecker' },
                { text: 'Cloudflare-Scamalytics documentation', link: '/en/topics/Cloudflare-Scamalytics' },
                { text: 'solving region Problem in Google services', link: '/en/topics/WorkerPlacementGemini' },
              ],
            },
          ],
        },
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
