<template>
  <div id="app">
    <div class="wrapper" :style="wrapperStyle">
      <Barrage></Barrage>
    </div>
    <!--<div id="test" style="background-color: rgba(0, 0, 0, 0.3); color: #fff; font-size: 16px; position: fixed; left: 5px; top: 5px; z-index: 1000;">test</div>-->
  </div>
</template>

<script>
import { mapState } from "vuex";
import _ from "lodash";

import Barrage from "./components/Barrage";

export default {
  name: "app",
  components: {
    Barrage
  },

  data() {
    return {
      timer: null,
      forwarderOrigin: ""
    };
  },

  computed: {
    ...mapState(["loadingEnd", "winW", "winH", "direction", "errorTips"]),

    wrapperStyle() {
      let angle =
        this.direction === 0 || this.direction === 180
          ? this.direction + 90
          : 0;
      return {
        width: this.winW + "px",
        height: this.winH + "px",
        transform: `translate(-50%, -50%) rotate(${angle}deg )`
      };
    }
  },

  created() {
    this.resize();
  },

  mounted() {
    this.listenerOrientation();
  },

  methods: {
    listenerOrientation() {
      window.addEventListener(
        "orientationchange",
        _.debounce(this.resize, 160),
        false
      );
    },

    resize() {
      let w,
        h,
        dir = window.orientation;
      if (window.orientation === 0 || window.orientation === 180) {
        w = document.documentElement.clientHeight;
        h = document.documentElement.clientWidth;
        // dir = window.orientation;
      } else {
        w = document.documentElement.clientWidth;
        h = document.documentElement.clientHeight;
        // dir = 0;
      }
      this.$store.commit("setPageWidth", {
        w,
        h,
        dir
      });
    }
  }
};
</script>

<style lang="scss">
@import "assets/css/app";
</style>
