<template>
  <section
    class="page in"
    :class="{ out: hide }"
    v-loading="loading"
    element-loading-text="暂时不支持移动端使用，请使用PC端浏览器打开"
    element-loading-background="rgba(0, 0, 0, 1)"
  >
    <div class="barrage-bg" ref="barrageBg"></div>

    <div class="content" :style="contentStyle">
      <div class="count-down">
        <p class="title">SIPC公益打榜墙</p>
        <p>重置倒计时</p>
        <Countdown :time="endTime" format="hh:mm:ss" @on-end="onCountdownEnd">
          <template slot-scope="{ time }">{{ time }}</template>
        </Countdown>
      </div>

      <div class="top">
        <div
          class="item"
          v-for="(item, index) in topList"
          :key="index"
          v-show="item.value !== '0'"
        >
          <div class="img-box">
            <img :src="imgUrl[index]" alt width="20" height="20" />
            <span :class="`img-right title-${index}`"
              >{{ coinAmount(item.value) }} SIPC</span
            >
          </div>
          <div class="info">
            <p :class="`title  title-${index}`">{{ item.content }}</p>
            <p class="wallet-info">钱包：{{ item.sender }}</p>
          </div>
        </div>
      </div>
      <div class="barrage-box">
        <div class="barrage-stage" ref="barrageStage">
          <template v-for="(item, index) of barrageList">
            <div
              class="barrage-item"
              :key="index"
              :style="`transform: translate3d(${item.x}px, ${item.y}px, 0)`"
            >
              <span class="barrage-msg">{{ item.msg }}</span>
            </div>
          </template>
        </div>
        <div class="barrage-cover-1"></div>
        <div class="barrage-cover-2"></div>
      </div>
      <div class="input-box">
        <input
          v-model="content"
          :disabled="buttonLoading"
          type="text"
          class="input-control"
          placeholder="在弹幕中许下你的新年愿望"
        />
        <input
          v-model="amount"
          :min="minAmount"
          :disabled="buttonLoading"
          type="number"
          class="input-amount"
          :placeholder="`最低${minAmount}`"
        />
        <el-button
          type="warning"
          class="barrage-add"
          :disabled="buttonLoading"
          @click="addBarrage"
          >许下你的新年愿望</el-button
        >
        <div class="total-blessing">总祝福：{{ total }}</div>

        <el-button
          type="warning"
          plain
          v-if="!this.metamask.isMetaMaskInstalled()"
          @click="this.metamask.onClickInstall"
          >安装 MetaMask</el-button
        >
      </div>
    </div>

    <div class="top-list">
      <div class="list">
        <h2 class="title">
          历史总榜
          <el-button type="text">
            <router-link to="/tutorial" style="color: #409EFF">
              教程
            </router-link>
          </el-button>
        </h2>
        <ul>
          <li class="item" v-for="(item, index) in list" :key="index">
            <el-row type="flex">
              <el-col :span="2">{{ index + 1 }}.</el-col>
              <el-col :span="5">{{ coinAmount(item.value) }} SIPC</el-col>
              <el-col :span="16" class="item-content">
                {{ item["content"] }}
              </el-col>
            </el-row>
          </li>
        </ul>
        <p>
          注: 0.01SIPC以上才可以上榜。 请勿使用ETH进行打榜。
          公益项目，打榜费用直接转向黑洞地址，任何人无法取出。
        </p>
      </div>
    </div>
  </section>
</template>

<script>
import { mapState } from "vuex";
import web3 from "web3";
import metamask from "../utils//metamask.js";
import { connectContract, notConnectContract } from "../utils/contract";
import Mint from "mint-filter";
import keywords from "../utils/keywords.json";
import Countdown from "@choujiaojiao/vue2-countdown";
export default {
  name: "Barrage",
  components: { Countdown },
  data() {
    return {
      hide: false,
      list: [],
      imgUrl: [
        require("../assets/img/icon_0.png"),
        require("../assets/img/icon-1.png"),
        require("../assets/img/icon-2.png")
      ],
      topList: [],
      barrageId: 0,
      loop: true,
      stageWidth: 0,
      stageHeight: 0,
      stage: null,
      itemHeight: 0,
      itemRow: 0,
      speed: 3,
      maxCount: 50,
      barrageList: [],
      contract: null,
      content: "",
      amount: "0.01",
      buttonLoading: false,
      forwarderOrigin: null,
      isDisabled: false,
      metamask: null,
      minAmount: null,
      filterContent: "",
      accounts: [],
      total: "",
      endTime: 0,
      loading: true
    };
  },

  computed: {
    ...mapState(["contentWidth"]),

    contentStyle() {
      return { width: this.contentWidth };
    }
  },
  async created() {
    this.loading = !this.isPC();

    this.metamask = metamask;
    if (this.metamask.isMetaMaskInstalled()) {
      this.contract = await connectContract();
      this.buttonLoading = false;
      this.metamask.onClickConnect();
      this.fetchBarrage();
    } else {
      this.contract = await notConnectContract();
      this.fetchContractData();
      this.buttonLoading = true;
    }
  },

  mounted() {
    this.$nextTick(() => {
      this.init();
    });
  },

  methods: {
    isPC() {
      var userAgentInfo = navigator.userAgent;
      var Agents = [
        "Android",
        "iPhone",
        "SymbianOS",
        "Windows Phone",
        "iPad",
        "iPod"
      ];
      var flag = true;
      for (var v = 0; v < Agents.length; v++) {
        if (userAgentInfo.indexOf(Agents[v]) > 0) {
          flag = false;
          break;
        }
      }
      return flag;
    },

    random(max) {
      return Math.floor(Math.random() * max);
    },

    coinAmount(value) {
      return web3.utils.fromWei(value, "ether");
    },

    init() {
      this.stage = this.$refs.barrageStage;
      this.stageWidth = this.stage.clientWidth;
      this.stageHeight =
        this.stage.clientHeight -
        parseInt(window.getComputedStyle(this.stage, null).paddingTop) -
        parseInt(window.getComputedStyle(this.stage, null).paddingBottom);

      let ele = document.createElement("div");
      ele.classList.add("barrage-item");
      ele.style.opacity = "0";
      let msgEle = document.createElement("span");
      msgEle.classList.add("barrage-msg");
      msgEle.textContent = "弹幕弹幕";
      ele.appendChild(msgEle);
      this.stage.appendChild(ele);

      this.itemRow = Math.floor(this.stageHeight / (ele.offsetHeight * 1.1));
      this.itemHeight = Math.floor(this.stageHeight / this.itemRow);

      this.stage.removeChild(ele);

      window.requestAnimationFrame(this.move);
    },

    fetchTopPeriodPairs() {
      this.contract.methods
        .get_top_period_pairs()
        .call()
        .then(data => {
          this.topList = [];
          data.forEach((e, i) => {
            if (i <= 2) {
              const mint = new Mint(keywords);
              mint.filter(e["content"]).then(data => {
                this.topList.push({
                  content: data["text"],
                  value: e["value"],
                  sender: e["sender"]
                });
              });
            }
          });
        });
    },

    fetchTopSpecialPairs() {
      this.contract.methods
        .get_top_special_pairs()
        .call()
        .then(data => {
          this.list = [];
          data.forEach(e => {
            if (e.value !== "0") {
              const mint = new Mint(keywords);
              mint.filter(e["content"]).then(data => {
                this.list.push({
                  content: data["text"],
                  value: e["value"],
                  sender: e["sender"]
                });
              });
            }
          });
        });
    },

    fetchResetTime() {
      this.contract.methods
        .reset_time()
        .call()
        .then(data => {
          this.endTime = parseInt(data - new Date().getTime() / 1000);
        });
    },

    async fetchBarrage() {
      this.accounts = await this.metamask.getAccounts();
      this.contract.events
        .Bidding()
        .on("data", event => {
          this.fetchTopPeriodPairs();
          this.fetchTopSpecialPairs();
          this.fetchResetTime();
          this.contract.methods
            .total()
            .call()
            .then(data => {
              this.total = data;
            });
          this.addToList(event.returnValues.content, this.barrageList.length);
        })
        .on("error", console.error);
      this.fetchContractData();
    },

    async fetchContractData() {
      this.fetchTopPeriodPairs();
      this.fetchTopSpecialPairs();
      this.fetchResetTime();
      this.minAmount = web3.utils.fromWei(
        await this.contract.methods.minimum_bid().call(),
        "ether"
      );

      this.total = await this.contract.methods.total().call();

      this.contract.methods
        .get_pairs(await this.contract.methods.max().call())
        .call()
        .then(data => {
          data.forEach(e => {
            this.addToList(e.content, this.barrageList.length);
          });
        });

      this.contract.methods
        .get_special_pairs(await this.contract.methods.max().call())
        .call()
        .then(data => {
          data.forEach(e => {
            this.addToList(e.content, this.barrageList.length);
          });
        });
    },

    async addBarrage() {
      if (this.content === "" || this.content === undefined) {
        this.$message.error("祝福内容不能为空");
        return;
      } else if (parseFloat(this.amount) < parseFloat(this.minAmount)) {
        this.$message.error("祝福礼金不得低于" + parseFloat(this.minAmount));
        return;
      }
      this.buttonLoading = true;
      this.contract.methods
        .bid(this.content)
        .send({
          from: this.accounts[0],
          value: web3.utils.toWei(this.amount, "ether"),
          gasPrice: 1000000000
        })
        .on("receipt", () => {
          this.buttonLoading = false;
          this.content = "";
        })
        .on("error", () => {
          this.buttonLoading = false;
        });
    },

    async addToList(msg, index) {
      // 敏感词过滤
      const mint = new Mint(keywords);
      const result = await mint.filter(msg);

      let y = this.getY();
      let x =
        this.barrageList.length === 0
          ? this.stageWidth + 20 + this.random(50)
          : this.getX(y);

      this.barrageList.push({
        id: ++this.barrageId,
        w: 0,
        msg: result.text,
        x,
        y
      });

      if (typeof index !== "undefined") {
        setTimeout(() => {
          this.barrageList[index].w = this.stage.children[index].offsetWidth;
        }, 0);
      }
    },

    move() {
      this.detection();
      this.barrageList = this.barrageList.map(val => {
        val.x -= this.speed;
        return val;
      });

      if (this.loop) {
        window.requestAnimationFrame(this.move.bind(this));
      }
    },

    detection() {
      this.barrageList = this.barrageList.map((val, index) => {
        if (!val.w) {
          val.w = this.stage.children[index].offsetWidth;
        }
        if (val.x + val.w < -20) {
          val.y = this.getY();
          val.x = this.getX(val.y);
          // console.info("val.x", val.x);
        }
        return val;
      });

      let len = this.barrageList.length;
      if (len > this.maxCount) {
        let diff = len - this.maxCount;
        this.barrageList = this.barrageList.filter(val => {
          return !(
            diff-- > 0 &&
            (val.x + val.w < -20 || val.x > this.stageWidth + 20)
          );
        });
      }
    },

    getY() {
      return this.random(this.itemRow) * this.itemHeight;
    },

    getX(y) {
      let sameRowEle = this.barrageList.filter(ele => {
        return ele.y === y;
      });
      let maxX = sameRowEle.reduce((prev, cur) => {
        return cur.x + cur.w > prev ? cur.x + cur.w : prev;
      }, 0);
      return maxX > this.stageWidth
        ? maxX + 50 + this.random(50)
        : this.stageWidth + 20 + this.random(50);
    },

    onCountdownEnd() {}
  }
};
</script>

<style lang="scss" scoped>
@import "../assets/css/common";

.page {
  @include full;

  .barrage-bg {
    @include full;
    background: url("../assets/img/barrage-bg.jpg") center;
    @include bgCover;
  }
  .count-down {
    margin-top: px2rem(30px);
    color: gray;
    font-size: px2rem(25px);
    .title {
      color: #2c3e50;
      font-size: px2rem(30px);
      margin-bottom: px2rem(15px);
    }
    p {
      padding-bottom: px2rem(10px);
    }
  }
  .top {
    width: px2rem(700px);
    margin: 0 auto;
    padding-top: px2rem(30px);
    .item {
      position: relative;
      margin-bottom: px2rem(20px);
      .img-box {
        position: absolute;
        top: px2rem(15px);
        .img-right {
          padding-left: px2rem(40px);
        }
        img {
          display: inline-block;
        }
        span {
          font-size: px2rem(26px);
        }
      }

      .info {
        padding-left: px2rem(240px);
        text-align: left;
        height: px2rem(65px);
        .title {
          width: px2rem(450px);
          padding-bottom: px2rem(10px);
          font-size: px2rem(26px);
          overflow: hidden;
          white-space: nowrap;
          text-overflow: ellipsis;
        }
      }

      .wallet-info {
        color: #888;
        height: px2rem(25px);
      }
    }
    .title-0 {
      color: gold;
    }
    .title-1 {
      color: silver;
    }
    .title-2 {
      color: goldenrod;
    }
  }

  .barrage-box {
    @include pa;
    width: 100%;
    top: px2rem(350px);
    height: px2rem(780px);
    left: px2rem(-10px);

    .barrage-cover-1,
    .barrage-cover-2 {
      width: px2rem(122px);
      height: 100%;
      @include pa;
      top: 0;
      background: linear-gradient(
        to right,
        #f9f3d2,
        #f9f3d2 10%,
        rgba(255, 255, 170, 0.1)
      );
    }
    .barrage-cover-1 {
      left: px2rem(-10px);
    }
    .barrage-cover-2 {
      right: px2rem(-10px);
      transform: rotate(180deg);
    }
  }

  .input-box {
    @include pa;
    width: 100%;
    display: flex;
    justify-content: center;
    left: 0;
    bottom: px2rem(50px);
    margin-bottom: px2rem(-15px);

    .input-control {
      width: px2rem(696px);
      box-sizing: border-box;
      height: px2rem(65px);
      padding: 0 px2rem(50px) 0 px2rem(15px);
      border-radius: px2rem(10px);
      box-shadow: px2rem(10px) px2rem(10px) px2rem(16px) px2rem(3px)
        rgba(207, 202, 171, 0.73);
      margin-right: px2rem(24px);
      color: #a4917a;
      font-size: px2rem(30px);
      background: #fff;
    }

    .input-amount {
      width: px2rem(196px);
      box-sizing: border-box;
      height: px2rem(65px);
      padding-left: px2rem(15px);
      border-radius: px2rem(10px);
      box-shadow: px2rem(10px) px2rem(10px) px2rem(16px) px2rem(3px)
        rgba(207, 202, 171, 0.73);
      color: #a4917a;
      font-size: px2rem(16px);
      background: #fff;
    }

    .el-button {
      font-size: 16px;
    }

    .total-blessing {
      font-size: px2rem(30px);
      margin-top: px2rem(15px);
      padding-left: px2rem(15px);
      padding-right: px2rem(15px);
    }

    .barrage-add {
      margin-left: px2rem(25px);
    }
  }

  .tip-button {
    margin-top: px2rem(20px);
  }

  &.in {
    .barrage-bg,
    .logo-wrap {
      animation: fall-in-1 0.5s ease backwards;
    }

    .questionnaire-succ-title {
      animation: fall-in-1 0.6s cubic-bezier(0.3, 0.9, 0.7, 1) 0.5s backwards;
    }

    .questionnaire-btn {
      animation: fall-in-2 0.6s cubic-bezier(0.3, 0.9, 0.7, 1) 1.1s backwards;
    }
  }

  &.out {
    animation: fall-out-1 0.25s ease forwards;
  }
}

::-webkit-input-placeholder {
  opacity: 0.5;
}
input:focus::-webkit-input-placeholder {
  opacity: 0.2;
}
.top-list {
  position: absolute;
  right: 0;

  .list {
    .title {
      margin-top: px2rem(50px);
      margin-bottom: px2rem(20px);
      font-size: px2rem(40px);
      text-align: left;
    }
    ul {
      max-height: px2rem(1000px);
      overflow: scroll;
      overflow-x: hidden;
      overflow-y: scroll;
      &::-webkit-scrollbar {
        display: none;
      }
      li {
        padding: px2rem(10px) 0;
        text-align: left;
        font-size: px2rem(20px);
        .item-content {
          width: px2rem(550px);
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
      }
    }
    p {
      margin-top: px2rem(30px);
      color: #888;
    }
  }
}
</style>
<style lang="scss">
@import "../assets/css/common";

.barrage-stage {
  width: 100%;
  height: 100%;
  padding: 5px 0 5px 0;
  box-sizing: border-box;
  overflow-x: hidden;
  @include pa;
  will-change: auto;
  /*background-color: rgba(204, 204, 204, 0.5);*/

  .barrage-item {
    padding: 5px 10px;
    box-shadow: px2rem(10px) px2rem(10px) px2rem(16px) px2rem(3px)
      rgba(207, 202, 171, 0.73);
    color: #ff8c47 !important;
    font-size: px2rem(30px);
    @include pa;
    border-radius: 50px;
    display: flex;

    &:nth-of-type(even) {
      background-color: #fdfaeb !important;
    }

    &:nth-of-type(odd) {
      background-color: #fbf6db !important;
    }

    .barrage-msg {
      line-height: 1.6;
      white-space: nowrap;
    }
  }
}
</style>
