import Vue from 'vue'
import App from './App.vue'
import router from './router'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import Snotify from 'vue-snotify'
import 'vue-snotify/styles/material.css'

Vue.config.productionTip = false

Vue.use(BootstrapVue)

const sNotifyOptions = {
  toast: {
    position: 'rightBottom',
    timeout: 7000,
    showProgressBar: false
  }
}

Vue.use(Snotify, sNotifyOptions)

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
