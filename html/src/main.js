import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import Notifications from '@kyvg/vue3-notification'
import Relax from './pages/dino.vue'
import Stft from './pages/stft.vue'
import Home from './pages/home.vue'
import Start from './pages/start.vue'
import DefaultPage from './default.vue'
import {OSCInit} from "./osc.js";

import './assets/reset.css'
import './assets/global.css'

const routes = [
    {
        path: '/',
        name:'start',
        component: Home,
    },
    {
        path: '/game/',
        children: [
            {
                path: 'start',
                component: Start,
            },
            {
                path: 'stft',
                component: Stft,
            },
            {
                path: 'relax',
                component: Relax,
            }
        ],
    },
]
const router = createRouter({
    history: createWebHistory(),
    routes, // short for `routes: routes`
})

const app = createApp(DefaultPage,)
app.config.globalProperties.OSC = OSCInit();
// const app = createApp(App)
app.use(router)
app.use(Notifications)
// test
app.mount('#app')



