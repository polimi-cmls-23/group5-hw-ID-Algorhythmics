import { createApp } from 'vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import Notifications from '@kyvg/vue3-notification'
import Debug from './pages/debug.vue'
import Stft from './pages/stft.vue'
import Start from './pages/start_page.vue'
import DefaultPage from './default.vue'

import './assets/reset.css'
import './assets/global.css'

const routes = [
    {
        path: '/',
        component: Start,
        props: { back: false }
    },
    {
        path: '/game/',
        children: [
            {
                path: 'debug',
                component: Debug,
            },
            {
                path: 'stft',
                component: Stft,
            }
        ],
    },
]
const router = createRouter({
    history: createWebHashHistory(),
    routes, // short for `routes: routes`
})

const app = createApp(DefaultPage)
// const app = createApp(App)
app.use(router)
app.use(Notifications)
// test
app.mount('#app')
