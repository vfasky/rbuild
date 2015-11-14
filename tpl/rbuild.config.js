// rbuild dev config
var path = require('path');

module.exports = {
  // 静态资源目录
  basePath: __dirname,
  // 生成 require config
  configFile: {
    output: path.join(__dirname, 'js'),
    filename: 'config.js'
  },
  // 第三方库下载路径
  vendor: {
    output: path.join(__dirname, 'js/vendor')
  },
  // requirejs config
  requirejsConfig: {
    paths: {
      
    }
  },
  // 模板编译配置
  tpl: {
    watchFile: path.join(__dirname, 'tpl/**/*.html'),
    output: path.join(__dirname, 'js/tpl'),
    filename: '[name].min.js'
  },
  // webpack config
  webpackConfig: {
    watchFile: path.join(__dirname, 'js/pack/**/*.js'),
    entry: {
    },
    output: {
      path: path.join(__dirname, 'js'),
      filename: '[name].all.js',
      libraryTarget: 'amd'
    },
    resolve: {
      alias: {
        
      }
    },
    externals: ['jquery', 'mcore', 'mcoreExt', 'moment']
  }
};

