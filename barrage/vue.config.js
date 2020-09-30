module.exports = {
  publicPath: "./",

  devServer: {
    // hot: true,
    // clientLogLevel: "warning",
  },

  pages: {
    index: {
      // page 的入口
      entry: "src/main.js",
      // 模板来源
      template: "public/index.html",
      // 在 dist/index.html 的输出
      filename: "index.html"
    }
  },

  // 生产环境 sourceMap
  // 静态文件目录
  // assetsDir: 'static',
  productionSourceMap: false
};
