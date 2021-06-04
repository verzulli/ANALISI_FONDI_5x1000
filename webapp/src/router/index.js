import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  { path: '*', redirect: '/torte' },
  { path: '/torte', name: 'torte', component: () => import('../components/torte') },
  { path: '/mappa', name: 'mappa', component: () => import('../components/mappa') }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
