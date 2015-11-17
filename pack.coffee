###*
# 生成pack map 
# @date 2015-11-12 17:43:18
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
# @version $Id$
###
path = require 'path'
fs = require 'fs-plus'
config = require('./config')()
util = require './util'
_ = require 'lodash'

_writeConfigTime = false

init = ->
    packMapFile = config.packMapFile
    
    if false == fs.isFileSync(packMapFile)
        fs.writeFileSync packMapFile, '{}', 'utf8'


exports.getData = ->
    init()
    packMapFile = config.packMapFile
    JSON.parse fs.readFileSync packMapFile, 'utf8'


exports.writeConfig = (data)->
    clearTimeout _writeConfigTime if _writeConfigTime

    _writeConfigTime = setTimeout ->
        exports._writeConfig data
    , 100

exports._writeConfig = (data)->
    paths = {}
    packNames = Object.keys data

    # todo add pack
    
    packNames.forEach (v)->
        fileInfo = path.parse data[v]
        fileInfo.base = fileInfo.name
        fileInfo.ext = ''
        paths[v] = path.format fileInfo
        if data[v].indexOf('//') != 0 and data[v].indexOf('http') != 0
            paths[v] = './' + paths[v]
        

    AMDCfg = _.merge config.requirejsConfig,
        paths: paths

    soure = "requirejs.config(#{JSON.stringify AMDCfg});"
    chunkhash = util.md5(soure).substring 0, config.hashLen
    
    cfgFileName = config.configFile
                        .filename
                        .replace /\[chunkhash\]/g, chunkhash

    cfgFile = path.join config.configFile.output, cfgFileName

    fs.writeFileSync cfgFile, soure, 'utf8'

    config.configFile.plugin.forEach (fun)->
        fun cfgFile, chunkhash, soure


    console.log "write file #{cfgFile}"


exports.reg = (pack, filePath)->
    
    packMapFile = config.packMapFile
    
    data = exports.getData()
    if filePath.indexOf('//') != 0 and filePath.indexOf('http') != 0
        data[pack] = path.relative config.basePath, filePath
    else
        data[pack] = filePath

    fs.writeFileSync packMapFile, JSON.stringify(data, null, 4), 'utf8'

    exports.writeConfig data
    
    data


exports.remove = (pack)->
    packMapFile = config.packMapFile

    data = exports.getData()
    if data.hasOwnProperty(pack)
        delete data[pack]

        fs.writeFileSync packMapFile, JSON.stringify(data, null, 4), 'utf8'
        exports.writeConfig data
    
    data


