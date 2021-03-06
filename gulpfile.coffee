###*
# 
# @date 2015-11-13 12:47:34
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
# @version $Id$
###

"use strict"

gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
path = require 'path'
argv = require('minimist') process.argv.slice(2)
_ = require 'lodash'
webpack = require 'webpack'

buildTpl = require './tpl'
config = require './config'
pack = require './pack'


options = _.extend
    basePath: process.cwd()
, argv

process.env.INIT_CWD = options.basePath

# load config
cfg = config require path.join options.basePath, options.config

# init webpack context
cfg.webpackConfig.context = options.basePath
packInfo = pack.getData()
packKeys = Object.keys packInfo

packKeys.forEach (v)->
    if cfg.webpackConfig.externals.indexOf(v) == -1
        cfg.webpackConfig.externals.push v

#console.log cfg.webpackConfig.externals

gulp.task 'webpack', ->
    webpack cfg.webpackConfig, (err, stats)->
        throw new gutil.PluginError 'webpack', err if err
        gutil.log '[webpack]', stats.toString
            colors: true


gulp.task 'buildTpl', ->
    gulp.src cfg.tpl.watchFile
        .pipe buildTpl()


gulp.task 'watch', ['buildTpl', 'webpack'], (done)->
    browserSync =
        reload: ->
        stream: ->

    if options.server != 'undefined'
        port = Number(options.p != 'undefined' and options.p or 8080)

        browserSync = require('browser-sync').create()
        browserSync.init
            port: port
            server:
                baseDir: options.basePath

        gutil.log '[webpack-dev-server]', "http://0.0.0.0:#{port}"

        watch path.join(cfg.tpl.output, '*.js'), ->
            browserSync.reload()
        
    watch cfg.tpl.watchFile, (file)->
        console.log 'change tpl: %s', file.path
        gulp.src file.path
            .pipe buildTpl()

    
    watch cfg.webpackConfig.watchFile, ->
        webpack cfg.webpackConfig, (err, stats)->
            throw new gutil.PluginError 'webpack', err if err

            gutil.log '[webpack]', stats.toString
                colors: true

            browserSync.reload()

        



    
