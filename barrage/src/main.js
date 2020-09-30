import "./assets/css/reset.scss";

import Vue from "vue";
import VueTouch from "vue-touch";
import App from "./App";
import store from "./store";
import ElementUI from "element-ui";
import "element-ui/lib/theme-chalk/index.css";

Vue.use(ElementUI);
Vue.use(VueTouch, { name: "v-touch" });
Vue.config.productionTip = false;

new Vue({
  store,
  render: h => h(App)
}).$mount("#app");
