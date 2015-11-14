// Generated by CoffeeScript 1.10.0

/**
 * 
 * @date 2015-11-13 17:51:10
 * @author vfasky <vfasky@gmail.com>
 * @link http://vfasky.com
 * @version $Id$
 */
var _, config, fs, packagesFile, path, request, util;

path = require('path');

fs = require('fs-plus');

config = require('./config')();

util = require('./util');

_ = require('lodash');

request = require('request');

packagesFile = path.join(__dirname, 'cdnjs.packages.json');

exports.getPackages = function(done) {
  if (false === fs.isFileSync(packagesFile)) {
    console.log('download cdnjs packages ...');
    return request({
      url: config.packages.url
    }).pipe(fs.createWriteStream(packagesFile)).on('close', function() {
      return done(null, JSON.parse(fs.readFileSync(packagesFile, 'utf8')));
    });
  } else {
    return done(null, JSON.parse(fs.readFileSync(packagesFile, 'utf8')));
  }
};

exports.updatePackages = function(done) {
  console.log('download cdnjs packages ...');
  return request({
    url: config.packages.url + '?_=' + (new Date()).getTime()
  }).pipe(fs.createWriteStream(packagesFile)).on('close', function() {
    return done(null, JSON.parse(fs.readFileSync(packagesFile, 'utf8')));
  });
};

exports.search = function(keyword, done) {
  keyword = String(keyword).trim().toLowerCase();
  return exports.getPackages(function(err, data) {
    var list;
    data.packages = data.packages || [];
    list = data.packages.filter(function(v) {
      return v.name.toLowerCase().match(keyword);
    });
    return done(err, list);
  });
};

exports.get = function(pack, cb, version) {
  var keyword, packInfo;
  if (version == null) {
    version = null;
  }
  pack = String(pack).trim().toLowerCase();
  packInfo = {};
  keyword = pack;
  if (keyword === 'moment' || keyword === 'momentjs') {
    keyword = 'moment.js';
  }
  return exports.search(keyword, function(err, data) {
    var done, isMatch;
    if (err) {
      return cb(err);
    }
    if (data.length === 0) {
      return cb(err, null);
    }
    isMatch = false;
    done = function(err, info) {
      info.filename = packInfo.filename;
      info.name = packInfo.name;
      info.packInfo = packInfo;
      info.url = exports.buildUrl(info);
      return cb(null, info);
    };
    _.each(data, function(v) {
      var info, vname;
      vname = v.name.toLowerCase();
      if (vname === pack || vname === pack + '.js') {
        packInfo = v;
        if (null === version) {
          isMatch = true;
          info = v.assets[0];
          done(null, info);
        } else {
          _.each(v.assets, function(a) {
            if (a.version === version) {
              isMatch = true;
              info = a;
              done(null, info);
              return false;
            }
          });
        }
        return false;
      }
    });
    if (false === isMatch) {
      return cb(err, null);
    }
  });
};

exports.buildUrl = function(info, ssl) {
  var host;
  if (ssl == null) {
    ssl = false;
  }
  host = ssl && '//' || 'http://';
  host += config.packages.host + '/ajax/libs';
  return host + "/" + info.name + "/" + info.version + "/" + info.filename;
};

exports.download = function(info, done) {
  var downTotal, fileTotal, outPath, url;
  url = "http://" + config.packages.host + "/ajax/libs/" + info.name + "/" + info.version + "/";
  outPath = path.join(config.vendor.output, info.name, info.version);
  downTotal = 0;
  fileTotal = info.files.length;
  return info.files.forEach(function(file) {
    var outFile, outInfo;
    outFile = path.join(outPath, file);
    outInfo = path.parse(outFile);
    if (false === fs.isDirectorySync(outInfo.dir)) {
      fs.makeTreeSync(outInfo.dir);
    }
    return request({
      url: url + file
    }).pipe(fs.createWriteStream(outFile)).on('close', function() {
      downTotal++;
      if (fileTotal === downTotal) {
        return done(null, path.join(outPath, info.filename));
      }
    });
  });
};
