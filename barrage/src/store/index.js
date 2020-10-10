import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

const state = {
  winW: window.innerHeight, // 页面宽度
  winH: window.innerWidth, // 页面高度
  pageW: 750, // 页面宽度
  pageH: 1495, // 页面高度
  direction: 0,
  contentWidth: "100%",
  contentSize: {
    w: 1220,
    h: 750
  }
};

const getters = {};

const actions = {};

const mutations = {
  // 设置页面宽度
  setPageWidth(state, { w, h, dir }) {
    state.winW = w;
    state.winH = h;
    state.direction = dir;
    state.contentWidth =
      Math.round(
        (state.contentSize.w * state.winH) / state.contentSize.h - 300
      ) + "px";
  }
};

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
});
