express = require('express')
router = express.Router()

mongoose = require('mongoose')
tweetSchema = require('../models/tweet.js')
debug = require('debug')('twlg2:socket.io')
config = require('config')
utils = require('../utils.js')

mongoose.connect("mongodb://#{config.mongodb.host}:#{config.mongodb.port? ? 27017}/#{config.mongodb.db}")
db = mongoose.connection

Tweet = mongoose.model 'Tweet', tweetSchema

### GET home page. ###

router.get '/', (req, res, next) ->
  res.render 'index', title: 'log_t @necocen'


router.search = (socket) ->
  debug 'connection'
  socket.on 'search', (data) ->
    debug 'search'

    args = data.query.split(/[ 　]/).map((arg) ->
      return null if arg.length == 0
      arg = arg.replace('\\', '\\\\').replace('"', '\"').replace('\'', '\\\'').replace('(', '\\(').replace(')', '\\)').replace(' ', '\\ ')
      return 'text:@"' + arg + '"'
    ).filter((arg) ->
      return arg?
    ).join(' + ')

    debug args

    dateMin = new Date(data.dateMin)
    dateMax = new Date(data.dateMax)

    if args.length > 0
      # なにかの単語が
      params =
        table: "Tweets"
        query: args
        sortby: (if data.order then '+' else '-') + 'created_at'
        'output_columns': '_key'
        filter: "(created_at>=#{dateMin.getTime() / 1000.0})&&(created_at<#{dateMax.getTime() / 1000.0})"
        offset: "#{data.skip or 0}"
        limit: "#{Math.min(100, data.limit or 30)}"

      do (data, params) ->
        utils.groonga('/select', params, 'GET').then (value) ->
          arr = JSON.parse(value)[1][0]
          hitCount = arr.shift()[0]
          columns = arr.shift()
          ids = [].concat.apply([], arr)
          Tweet.find(id_str: {'$in': ids}).sort(created_at: if data.order then 1 else -1).exec (err, docs) ->
            socket.emit (if (data.skip ? 0) > 0 then 'append' else 'search'),
              result: docs
              count: hitCount
              query: data.query
              done: (hitCount <= (docs.length + (data.skip ? 0)))
    else
      Tweet.find(created_at:
        $gte: dateMin
        $lt: dateMax).sort(created_at: if data.order then 1 else -1).skip(data.skip or 0).limit(Math.min(100, data.limit or 30)).exec (err, docs) ->
        socket.emit (if (data.skip ? 0) > 0 then 'append' else 'search'),
          result: docs
          count: null
          query: ''
          done: false # TODO: カウンタは必要

  socket.on 'disconnect', ->
    debug 'disconnect'

module.exports = router
