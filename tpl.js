// Generated by CoffeeScript 1.10.0

/**
 * 
 * @date 2015-11-12 15:23:43
 * @author vfasky <vfasky@gmail.com>
 * @link http://vfasky.com
 * @version $Id$
 */
var _writeFileTime, buildAMDPack, buildTpl, config, fs, minify, pack, path, through2, tplDataCache, util, writeFile;

through2 = require('through2');

path = require('path');

fs = require('fs-plus');

minify = require('html-minifier').minify;

util = require('./util');

pack = require('./pack');

config = require('./config')();

tplDataCache = function(tplPath, key, value) {
  var cacheData, hash, tplCacheFile;
  if (key == null) {
    key = null;
  }
  if (value == null) {
    value = null;
  }
  hash = util.md5(tplPath);
  tplCacheFile = path.join(config.dataPath, "tplCache." + hash + ".json");
  if (false === fs.isFileSync(tplCacheFile)) {
    fs.writeFileSync(tplCacheFile, '{}', 'utf8');
  }
  cacheData = JSON.parse(fs.readFileSync(tplCacheFile, 'utf8'));
  if (key === null) {
    return cacheData;
  }
  cacheData[key] = value;
  fs.writeFileSync(tplCacheFile, JSON.stringify(cacheData), 'utf8');
  return cacheData;
};

buildAMDPack = function(packName, data) {
  return "define('" + packName + "', function(){ return " + (JSON.stringify(data)) + "; });";
};

buildTpl = function(file, enc, done) {
  var chunkhash, fileName, filePath, html, packData, soure, tplData, tplFile, tplFileName, tplName, tplPack, tplPath, tplPathArr;
  filePath = file.path;
  fileName = path.basename(filePath);
  tplPath = path.normalize(path.join(filePath, '..'));
  tplPathArr = tplPath.split(path.sep);
  tplName = tplPathArr[tplPathArr.length - 1];
  tplPack = config.tplPrefix + tplName;
  html = file.contents.toString('utf8');
  html = minify(html, config.minifyHtml);
  tplData = tplDataCache(tplPath, fileName, html);
  soure = buildAMDPack(tplPack, tplData);
  chunkhash = util.md5(soure).substring(0, config.hashLen);
  tplFileName = config.tpl.filename.replace(/\[name\]/g, tplName).replace(/\[chunkhash\]/g, chunkhash);
  tplFile = path.join(config.tpl.output, tplFileName);
  fs.writeFileSync(tplFile, soure, 'utf8');
  packData = pack.reg(tplPack, tplFile);
  return done(null, file);
};

_writeFileTime = {};

writeFile = function(file, data) {
  if (_writeFileTime[file]) {
    clearTimeout(_writeFileTime[file]);
  }
  return _writeFileTime[file] = setTimeout(function() {
    fs.writeFileSync(file, data, 'utf8');
    return console.log("build tpl pack: " + file + " [success]");
  }, 500);
};

module.exports = function() {
  return through2.obj(buildTpl);
};
