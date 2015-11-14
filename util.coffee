###*
# 
# @date 2015-11-12 15:47:32
# @author vfasky <vfasky@gmail.com>
# @link http://vfasky.com
# @version $Id$
###
crypto = require 'crypto'

exports.md5 = (text)->
    crypto.createHash('md5').update(String(text)).digest('hex')
