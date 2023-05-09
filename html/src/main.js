import { createApp } from 'vue'
import App from './App.vue'
import Notifications from '@kyvg/vue3-notification'
import Template from './components/template.vue'
import Debug from './pages/debug.vue'
import Start from './pages/start_page.vue'

const routes = [
    { path: '/', component: Start },
    {
        path: '/game/',
        component: Template,
        children: [
            {
                path: 'debug',
                component: Debug,
            }
        ],
    },
]
const router = VueRouter.createRouter({
    // 4. Provide the history implementation to use. We are using the hash history for simplicity here.
    history: VueRouter.createWebHashHistory(),
    routes, // short for `routes: routes`
})

const app = createApp({})
// const app = createApp(App)
app.use(router)
app.use(Notifications)
// test
app.mount('#app')
