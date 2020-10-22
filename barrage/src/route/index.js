import Vue from "vue";
import Router from "vue-router";

import Barrage from "../components/Barrage.vue";
import Tutorial from "../components/Tutorial.vue";

Vue.use(Router);

export const routes = [
  {
    path: "/",
    component: Barrage
  },
  {
    path: "/tutorial",
    component: Tutorial
  }
];

export default new Router({
  routes: routes
});
