<template>
  <div class="container">
    <h2 class="title">
      SIPC公益打榜墙教程
    </h2>
    <el-row>
      <el-col :span="8" class="item">
        <p>
          1. 此项目目前仅支持chrome浏览器，请先下载chrome浏览器
          <a
            href="https://www.google.cn/chrome/"
            target="_blank"
            rel="noopener noreferrer"
            >https://www.google.cn/chrome/</a
          >
        </p>
        <p>
          2. 打开项目地址
          <a href="http://122.51.239.75/">http://122.51.239.75/</a>
        </p>
        <p>
          3. 点击下图箭头所示按钮，安装钱包插件metamask（需要翻墙）
          <img src="../assets/img/tutorial-1.png" alt="" height="300" />
        </p>
      </el-col>
      <el-col :span="8" class="item">
        <div>
          <p>4. 点击浏览器右上角的metamask，点击自定义RPC</p>

          <img src="../assets/img/tutorial-2.png" alt="" height="400" />
        </div>
      </el-col>
      <el-col :span="8" class="item">
        <div>
          <p>5. 网络名称填写sipc即可（随意）</p>
          <p>6. RPC URL请填写：explorer.simplechain.com/rpc</p>

          <img src="../assets/img/tutorial-3.png" alt="" height="400" />
        </div>
      </el-col>
      <el-col :span="24" class="item">
        <div class="tips">
          <p>7. 向metamask地址中，充值sipc，充值到账后，即可参与打榜。</p>
          <p class="text">
            说明：打榜的最小金额是0.01 SIPC， 0.01
            SIPC的打榜，仅仅可以上墙，不参与排行榜竞争，打榜金额大于0.01
            SIPC，即可参与排行榜竞争。
            所有打榜费用，均流向黑洞地址，任何人（包括项目方）都无法取出。
            历史总排行永不重置，项目页面中间的前三名部分，会定时重置。
          </p>
        </div>
      </el-col>
    </el-row>
    <div></div>
  </div>
</template>

<script>
export default {};
</script>

<style>
.container {
  font-size: 16px;
}
.container .title {
  margin-top: 50px;
  margin-bottom: 30px;
  font-size: 26px;
}
.container img {
  margin: 0 auto;
}
.container .item {
  padding: 20px;
  text-align: left;
}

.item p {
  padding: 8px 0;
}
.container .tips {
  width: 500px;
}
.tips .text {
  color: #666;
}
</style>
