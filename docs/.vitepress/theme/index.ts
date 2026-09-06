import DefaultTheme from 'vitepress/theme'
import { h } from 'vue'
import { useRoute } from 'vitepress'
import type { Theme } from 'vitepress'
import 'viewerjs/dist/viewer.min.css'
import DocFooter from './components/DocFooter.vue'
import Ltr from './components/Ltr.vue'
import CopyLink from './components/CopyLink.vue'
import imageViewer from 'vitepress-plugin-image-viewer'
import vImageViewer from 'vitepress-plugin-image-viewer/lib/vImageViewer.vue'
import './custom.css'
import './styles.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'doc-after': () => h(DocFooter),
    })
  },
  enhanceApp({ app }) {
    app.component('vImageViewer', vImageViewer)
    app.component('Ltr', Ltr)
    app.component('CopyLink', CopyLink)
  },
  setup() {
    const route = useRoute()
    imageViewer(route)
  }
} satisfies Theme
