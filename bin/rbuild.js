#!/usr/bin/env node

"use strict";
var _, args, argv, config, deployConfig, devConfig, downGFonts, fs, gitignore, gulpSh, gutil, options, outFile, pack, packData, packFile, packInfo, packName, packNames, packUrl, packages, path, proc, sfile, spawn, t, url, version,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ = require('lodash');

path = require('path');

argv = require('minimist')(process.argv.slice(2));

spawn = require('child_process').spawn;

fs = require('fs-plus');

gutil = require('gulp-util');

process.env.INIT_CWD = process.cwd();

options = _.extend({
  config: 'rbuild.config.js'
}, argv);

global.webpack = require('webpack');

if (options.version || options.v) {
  packFile = path.join(__dirname, '../package.json');
  packages = JSON.parse(fs.readFileSync(packFile, 'utf8'));
  console.log(packages.version);
  process.exit(1);
}

if (options._.indexOf('init') !== -1) {
  devConfig = fs.readFileSync(path.join(__dirname, '../tpl/rbuild.config.js'), 'utf8');
  outFile = path.join(process.cwd(), 'rbuild.config.js');
  fs.writeFileSync(outFile, devConfig, 'utf8');
  deployConfig = fs.readFileSync(path.join(__dirname, '../tpl/rbuild.deploy.js'), 'utf8').replace('#{webpackPath}', path.join(__dirname, '../node_modules/webpack/lib/webpack.js'));
  outFile = path.join(process.cwd(), 'rbuild.deploy.js');
  fs.writeFileSync(outFile, deployConfig, 'utf8');
  gitignore = fs.readFileSync(path.join(__dirname, '../tpl/_gitignore'), 'utf8');
  fs.writeFileSync(path.join(process.cwd(), '.gitignore', gitignore, 'utf8'));
  console.log('init done');
  process.exit(1);
}

config = require('../config')(require(path.join(process.cwd(), options.config)));

gulpSh = path.join(__dirname, '../node_modules/gulp/bin/gulp.js');

if (options._.indexOf('watch') !== -1) {
  args = options;
  args.cwd = __dirname;
  args.stdio = 'inherit';
  proc = spawn(gulpSh, ['watch', '--config', options.config, '--basePath', process.cwd(), '--server', options.server, '--p', options.p], args);
}

if (options._.indexOf('updatePack') !== -1) {
  sfile = require('../sfile');
  sfile.updatePackages(function(err, data) {
    if (err) {
      console.log(err);
      process.exit(1);
    }
    return console.log("update packages: " + data.packages.length);
  });
}

if (options._.indexOf('uninstall') !== -1) {
  packName = options._[1];
  if (!packName) {
    console.log('rbuild uninstall [packName]');
    process.exit(1);
  }
  pack = require('../pack');
  packData = pack.getData();
  packNames = Object.keys(packData);
  if (indexOf.call(packNames, packName) >= 0) {
    packUrl = packData[packName];
    if (packUrl.indexOf('//') === 0 || packUrl.indexOf('http') === 0) {
      pack.remove(packName);
    } else {
      packInfo = path.parse(packUrl);
      fs.removeSync(packInfo.dir);
      pack.remove(packName);
    }
    console.log("uninstall " + packName + " success");
  } else {
    console.log(packName + " Not Find");
  }
}

if (options._.indexOf('install') !== -1) {
  sfile = require('../sfile');
  packName = options._[1];
  version = null;
  if (!packName) {
    console.log('rbuild install [packName] --download');
    process.exit(1);
  }
  if (packName.indexOf('@') !== -1) {
    t = packName.split('@');
    version = t.pop();
    packName = t.pop();
  }
  sfile.get(packName, function(err, info) {
    if (err) {
      return console.log(err);
    }
    if (!info) {
      return console.log("No Find Pack : " + packName);
    }
    pack = require('../pack');
    if (options.download || options.down) {
      return sfile.download(info, function(err, outFile) {
        pack.reg(packName, outFile);
        return console.log(packName + " install success");
      });
    } else {
      pack.reg(packName, sfile.buildUrl(info, options.ssl));
      return console.log(packName + " install success");
    }
  }, version);
}

if (options._.indexOf('downGFonts') !== -1) {
  url = options._[1];
  downGFonts = require('../downGFonts');
  downGFonts(url, config);
}
