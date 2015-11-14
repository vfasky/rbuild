#`#!/usr/bin/env node`

"use strict"

_ = require 'lodash'
path = require 'path'
argv = require('minimist') process.argv.slice(2)
spawn = require('child_process').spawn
fs = require 'fs-plus'


process.env.INIT_CWD = process.cwd()

options = _.extend
    config: 'rbuild.config.js'
, argv

# load config
config = require('../config') require path.join process.cwd(), options.config

gulpSh = path.join __dirname, '../node_modules/gulp/bin/gulp.js'

# 监听文件更改
if options._.indexOf('watch') != -1
    proc = spawn gulpSh, [
        'watch',
        '--config', options.config
        '--basePath', process.cwd()
    ],{
        cwd: __dirname
    }

# 更新cdnjs包
if options._.indexOf('updatePack') != -1
    sfile = require '../sfile'

    sfile.updatePackages (err, data)->
        if err
            console.log err
            process.exit(1)
        console.log "update packages: #{data.packages.length}"

# 删除包
if options._.indexOf('uninstall') != -1
    packName = options._[1]
    if !packName
        console.log 'rbuild uninstall [packName]'
        process.exit(1)

    pack = require '../pack'
    packData = pack.getData()
    packNames = Object.keys packData

    if packName in packNames
        packUrl = packData[packName]
        # 删除配置
        if packUrl.indexOf('//') == 0 or packUrl.indexOf('http') == 0
            pack.remove packName
        else
            packInfo = path.parse packUrl
            fs.removeSync packInfo.dir
            pack.remove packName
        console.log "uninstall #{packName} success"
    else
        console.log "#{packName} Not Find"


    
# 安装包
if options._.indexOf('install') != -1
    sfile = require '../sfile'
    packName = options._[1]
    version = null

    if !packName
        console.log 'rbuild install [packName] --download'
        process.exit(1)

    if packName.indexOf('@') != -1
        t = packName.split '@'
        version = t.pop()
        packName = t.pop()

    sfile.get packName, (err, info)->
        return console.log err if err
        return console.log "No Find Pack : #{packName}" if !info

        pack = require '../pack'

        # 下载到本地
        if options.download or options.down
            sfile.download info, (err, outFile)->
                pack.reg packName, outFile
                console.log "#{packName} install success"
        else
            pack.reg packName, sfile.buildUrl info, options.ssl
            console.log "#{packName} install success"
                
    , version
        

if proc
    proc.stdout.on 'data', (data)->
        console.log data.toString()

    proc.stderr.on 'data', (data)->
        console.log data.toString()