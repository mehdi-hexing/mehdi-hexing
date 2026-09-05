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
                { text: 'مستندات، آموزش گام به گام و راهنمای استفاده از سرویس hysteria در بستر katabump', link: '/topics/Hysteria2Setup' },
                { text: 'مستندات، آموزش گام به گام و راهنمای استفاده از سرویس MTProto در بستر katabump', link: '/topics/KataBumpMTProtoSetup' },
                { text: 'مستندات، نحوه راه اندازی و دپلوی و نکات HTTP-PROXY', link: '/topics/HTTP-PROXY' },
                { text: 'راه‌اندازی وورکر zizifn', link: '/topics/zizifn' },
                { text: 'مستندات، راهنما و حل مشکل ریجن در سرویس های گوگل', link: '/topics/WorkerPlacementGemini' },
                { text: 'مستندات، نحوه راه اندازی و دپلوی و نکات ECH-Workers', link: '/topics/ECH-Workers' },
                { text: 'مستندات ، راه‌اندازی و مطالب تکمیلی ProxyIPChecker', link: '/topics/CF-ProxyIPChecker' },
                { text: 'مستندات، نحوه راه اندازی و دپلوی و نکات ProxyIP-Tel-Bot', link: '/topics/ProxyIP-Tel-Bot' },
                { text: 'مستندات، نحوه راه اندازی و دپلوی و نکات Cloudflare-Scamalytics', link: '/topics/Cloudflare-Scamalytics' },
                { text: 'مستندات، نحوه راه اندازی و دپلوی و نکات Domain-Resolve', link: '/topics/Domain-Resolve' },
                { text: 'مستندات، نحوه راه اندازی و دپلوی و نکات Check-Host-API', link: '/topics/Check-Host-API' },
                { text: 'آموزش Markdown', link: '/topics/markdown' },
                { text: 'آموزش ترموکس', link: '/topics/termux' },
                { text: 'ابزار‌های هوش مصنوعی', link: '/topics/ai' },
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
                { text: 'Documentation, step-by-step training and instructions for using the hysteria service on the katabump platform', link: '/en/topics/Hysteria2Setup' },
                { text: 'Documentation, step-by-step training and instructions for using the MTProto service on the katabump platform', link: '/en/topics/KataBumpMTProtoSetup' },
                { text: 'HTTP-PROXY documentation, setup and deployment tips and tricks', link: '/en/topics/HTTP-PROXY' },
                { text: 'Serverless runtime', link: '/en/topics/zizifn' },
                { text: 'Documentation, help and problem solving region in Google services', link: '/en/topics/WorkerPlacementGemini' },
                { text: 'ECH-Workers documentation, setup and deployment tips and tricks', link: '/en/topics/ECH-Workers' },
                { text: 'ProxyIPChecker Documentation, Setup, and Additional Content', link: '/en/topics/CF-ProxyIPChecker' },
                { text: 'Documentation, setup, deployment, and notes for ProxyIP-Tel-Bot', link: '/en/topics/ProxyIP-Tel-Bot' },
                { text: 'Cloudflare-Scamalytics documentation, setup and deployment tips and tricks', link: '/en/topics/Cloudflare-Scamalytics' },
                { text: 'Domain-Resolve documentation, setup and deployment tips and tricks', link: '/en/topics/Domain-Resolve' },
                { text: 'Check-Host-API documentation, setup and deployment tips and tricks', link: '/en/topics/Check-Host-API' },
                { text: 'Markdown Guide', link: '/en/topics/markdown' },
                { text: 'Termux Guide', link: '/en/topics/termux' },
                { text: 'AI Tools', link: '/en/topics/ai' },
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
