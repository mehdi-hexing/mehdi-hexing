import DefaultTheme from 'vitepress/theme'
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DocFooter from './components/DocFooter.vue'
import Ltr from './components/Ltr.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'doc-after': () => h(DocFooter),
    })
  },
  enhanceApp({ app }) {
    app.component('Ltr', Ltr)
  },
} satisfies Theme
