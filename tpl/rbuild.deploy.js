// rbuild deploy config

var config = require('./rbuild.config');
var webpack = require('#{webpackPath}');

// min js
config.webpackConfig.plugins = config.webpackConfig.plugins || [];
config.webpackConfig.plugins.push(new webpack.optimize.UglifyJsPlugin({
  compress: {
    warnings: false
  }
}));

// change file name
config.configFile.filename = 'config.[chunkhash].min.js';
config.tpl.filename = '[name].[chunkhash].min.js';
config.webpackConfig.output.filename = '[name].[chunkhash].min.js';

module.exports = config;
