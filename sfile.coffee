###*
# 
# @date 2015-11-13 17:51:10
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
# @version $Id$
###
path = require 'path'
fs = require 'fs-plus'
config = require('./config')()
util = require './util'
_ = require 'lodash'
request = require 'request'

packagesFile = path.join __dirname, 'cdnjs.packages.json'

exports.getPackages = (done)->
    if false == fs.isFileSync(packagesFile)
        console.log 'download cdnjs packages ...'
        request
            url: config.packages.url
        .pipe fs.createWriteStream packagesFile
        .on 'close', ->
            done null, JSON.parse fs.readFileSync packagesFile, 'utf8'
    else
        done null, JSON.parse fs.readFileSync packagesFile, 'utf8'

exports.updatePackages = (done)->
    console.log 'download cdnjs packages ...'
    request
        url: config.packages.url + '?_=' + (new Date()).getTime()
    .pipe fs.createWriteStream packagesFile
    .on 'close', ->
        done null, JSON.parse fs.readFileSync packagesFile, 'utf8'

exports.search = (keyword, done)->
    keyword = String(keyword).trim().toLowerCase()
   
    exports.getPackages (err, data)->
        data.packages = data.packages or []
        list = data.packages.filter (v)->
            v.name.toLowerCase().match keyword
        done err, list

exports.get = (pack, cb, version=null)->
    pack = String(pack).trim().toLowerCase()
    packInfo = {}

    keyword = pack

    if keyword in ['moment', 'momentjs']
        keyword = 'moment.js'

    exports.search keyword, (err, data)->
        return cb err if err
        return cb err, null if data.length == 0

        isMatch = false

        done = (err, info)->
            info.filename = packInfo.filename
            info.name = packInfo.name
            info.packInfo = packInfo
            info.url = exports.buildUrl info
            cb null, info

        _.each data, (v)->
            vname = v.name.toLowerCase()
            if vname == pack or vname == pack + '.js'
                packInfo = v

                if null == version
                    isMatch = true
                    info = v.assets[0]
                    done null, info
                else
                    _.each v.assets, (a)->
                        if a.version == version
                            isMatch = true
                            info = a
                            done null, info
                            return false

                return false

        if false == isMatch
            cb err, null
        

exports.buildUrl = (info, ssl = false)->
    host = ssl and '//' or 'http://'
    host += config.packages.host + '/ajax/libs'

    "#{host}/#{info.name}/#{info.version}/#{info.filename}"

    
# 下载包
exports.download = (info, done)->
    url = "http://#{config.packages.host}/ajax/libs/#{info.name}/#{info.version}/"
    outPath = path.join config.vendor.output, info.name, info.version
    downTotal = 0
    fileTotal = info.files.length

    info.files.forEach (file)->
        outFile = path.join outPath, file

        outInfo = path.parse outFile

        if false == fs.isDirectorySync outInfo.dir
            fs.makeTreeSync outInfo.dir
        
        request
            url: url + file
        .pipe fs.createWriteStream outFile
        .on 'close', ->
            downTotal++
            done null, path.join outPath, info.filename if fileTotal == downTotal

#test
#exports.get 'twitter-bootstrap', (err, info)->
    #console.log err, info if err

    #if info
        #exports.download info, ->
