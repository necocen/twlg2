mongoose = require 'mongoose'
db = mongoose.connection
Tweet = mongoose.model 'Tweet', require '../models/tweet.js'
BigNumber = require 'bignumber.js'
utils = require '../utils.js'
config = require 'config'
XmlEntities = new (require('html-entities').XmlEntities)
twitter = (require 'twitter')(config.twitter)

mongoose.connect("mongodb://#{config.mongodb.host}:#{config.mongodb.port}/#{config.mongodb.db}")

promise = utils.groonga('/select',
  table: "Tweets"
  output_columns: "_key"
  sortby: "-created_at"
  limit: "1", 'GET').then (value) ->
    arr = JSON.parse(value)[1][0]
    arr.shift()
    arr.shift()
    if arr.length == 0
      console.log 'Start Crawling'
      crawl()
    else
      console.log "Start Crawling From: #{arr[0][0]}"
      crawl arr[0][0]

crawl = (sinceId, maxId) ->
  params =
    user_id: config.twitter.user_id
    include_rts: 1
    count: 200
    exclude_replies: false
  params.since_id = sinceId if sinceId?
  params.max_id = maxId if maxId?
  twitter.get '/statuses/user_timeline.json', params, (error, data, response) ->
    do (data) ->
      if data.length == 0
        promise = promise.then ->
          console.log 'Done.'
          return 0
        .finally process.exit
      else
        firstId = data[0].id_str
        lastId = data[data.length - 1].id_str
        console.log "Retrieved #{data.length} posts: #{firstId} -- #{lastId}"
        promise = promise.then ->
          Tweet.create data, ->
            console.log "mongodb: #{firstId} -- #{lastId}"
          .then ->
            json = JSON.stringify(data.map (tweet) ->
              createdAt = new Date(tweet.created_at)
              text = XmlEntities.decode utils.urlExpandedText(tweet)
              return {
                _key: tweet.id_str
                text: text
                created_at: createdAt.getTime() / 1000.0}
            )
            return utils.groonga '/load',
              table: "Tweets", 'POST', [json]
        crawl sinceId, new BigNumber(lastId).plus(-1).toString()
