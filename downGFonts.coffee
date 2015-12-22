###*
# 下载google字体
# @date 2015-12-22 09:45:19
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
###
'use strict'
path = require 'path'
request = require 'request'
{md5} = require './util'
fs = require 'fs-plus'

# 取出所有 woff2
getWoff2 = (css)->
    woffMap = []
    String(css).split('url(').forEach (v)->
        if v.indexOf(') format(') != -1
            woffMap.push v.split(') format(')[0]

    woffMap



module.exports = (url, config)->
    config.GFonts = config.GFonts or {
        output: path.join config.basePath, 'style/gfonts'
    }

    GFontsOutput = config.GFonts.output

    request.get url, (err, res, body)->
        return console.log err if err

        outDir = path.join GFontsOutput, md5(url).substring(0, 8)

        fs.makeTreeSync outDir

        fileList = getWoff2 body
        downTotal = 0
        fileTotal = fileList.length

        done = ->
            fileList.forEach (fontUrl)->
                fontName = fontUrl.split('/').pop()

                body = body.replace fontUrl, './' + fontName


            fs.writeFileSync path.join(outDir, 'font.css'), body, 'utf8'
            console.log 'download fonts success { %s/font.css }', outDir


        fileList.forEach (fontUrl)->
            fontName = fontUrl.split('/').pop()

            request
                url: fontUrl
            .pipe fs.createWriteStream path.join(outDir, fontName)
            .on 'close', ->
                downTotal++
                done() if downTotal == fileTotal


