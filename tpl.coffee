###*
# 
# @date 2015-11-12 15:23:43
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
# @version $Id$
###
through2 = require 'through2'
path = require 'path'
fs = require 'fs-plus'
minify = require('html-minifier').minify
util = require './util'
pack = require './pack'
config = require('./config')()

# 根据模板路径，取模板缓存 (sync)
tplDataCache = (tplPath, key = null, value = null)->
    hash = util.md5(tplPath)
    tplCacheFile = path.join config.dataPath, "tplCache.#{hash}.json"

    if false == fs.isFileSync(tplCacheFile)
        fs.writeFileSync tplCacheFile, '{}', 'utf8'

    cacheData = JSON.parse fs.readFileSync tplCacheFile, 'utf8'
    return cacheData if key == null

    # write
    cacheData[key] = value
    fs.writeFileSync tplCacheFile, JSON.stringify(cacheData), 'utf8'

    cacheData

# 生成amd的包文件
buildAMDPack = (packName, data)->
    "define('#{packName}', function(){ return #{JSON.stringify(data)}; });"

# 生成模板
buildTpl = (file, enc, done)->
    filePath = file.path
    fileName = path.basename filePath
    tplPath = path.normalize path.join(filePath, '..')
    tplPathArr = tplPath.split path.sep
    tplName = tplPathArr[tplPathArr.length - 1]
    tplPack = config.tplPrefix + tplName

    html = file.contents.toString 'utf8'

    # 压缩
    html = minify html, config.minifyHtml

    # update
    tplData = tplDataCache tplPath, fileName, html

    # build amd pack
    soure = buildAMDPack tplPack, tplData
    chunkhash = util.md5(soure).substring 0, config.hashLen
    
    tplFileName = config.tpl.filename.replace /\[name\]/g, tplName
                                     .replace /\[chunkhash\]/g, chunkhash

    tplFile = path.join config.tpl.output, tplFileName

    fs.writeFileSync tplFile, soure, 'utf8'

    packData = pack.reg tplPack, tplFile

    console.log "build tpl pack: #{tplPack} [success]"

    done null, file


# test
#htmlPath = '/Users/vfasky/git/mcore/example/cnodejs/tpl/cnode/index.html'
#buildTpl
    #path: htmlPath
    #contents: fs.readFileSync htmlPath


module.exports = -> through2.obj buildTpl
