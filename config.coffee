###*
# 
# @date 2015-11-12 15:34:40
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
# @version $Id$
###

"use strict"

_ = require 'lodash'
path = require 'path'

curPath = __dirname

_config =
    # 静态文件的basePath
    basePath: curPath

    # hash 长度
    hashLen: 20
    # 构建模板的前缀
    tplPrefix: 'tpl/'
    # 缓存文件夹名称
    dataDir: '.rbuildData'
    # 压缩html配置
    minifyHtml:
        # 删除注释
        collapseWhitespace: true
        # 去除空格
        removeComments: true
        # 去除空格时，保留一个
        conservativeCollapse: true

    # pack hash map
    packMapFileName: 'stats.json'

    # 第三方包的下载目录
    vendor:
        output: path.join curPath, 'js/vendor'

    # 生成模板
    tpl:
        # 监视的文件
        watchFile: []
        # 存放的目录
        output: path.join curPath, 'tpl'
        filename: '[name].[chunkhash].min.js'

    # 生成的 requirejs 文件目录
    configFile:
        filename: 'config.[chunkhash].js'
        output: path.join curPath, 'js'
        plugin: []

    # requirejs cofng
    requirejsConfig:
        paths: {}

    # webpack config
    webpackConfig:
        # 监视的文件
        watchFile: []
        
        output:
            libraryTarget: 'amd'
        plugins: []

    # cdnjs packages
    packages:
        url: 'http://7xobb7.dl1.z0.glb.clouddn.com/packages.json'
        host: 'dn-cdnjscn.qbox.me'

        
config = (config)->
    return _config if false == _.isObject(config)
    
    _config = _.merge _config, config

    # init webpack
    _config.webpackConfig.plugins.push ->
        pack = require './pack'
        @plugin 'done', (stats)->
            packMap = stats.toJson().assetsByChunkName
            packs = Object.keys packMap

            packs.forEach (name)->
                filePath = path.join _config.webpackConfig.output.path, packMap[name]
                pack.reg name, filePath

    # 缓存文件路径
    _config.dataPath = path.join _config.basePath, _config.dataDir
    _config.packMapFile = path.join _config.basePath, _config.packMapFileName

    _config

config {}

module.exports = config
