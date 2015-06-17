mongoose = require 'mongoose'
db = mongoose.connection
config = require 'config'
utils = require '../utils.js'
fs = require 'fs'
XmlEntities = new (require('html-entities').XmlEntities)
Tweet = mongoose.model 'Tweet', require '../models/tweet.js'

mongoose.connect("mongodb://#{config.mongodb.host}:#{config.mongodb.port}/#{config.mongodb.db}")

# Re-create tables
db.collections['tweets'].drop()

promise = utils.groonga('/status', 'GET')
.then (res) ->
  console.log res
  utils.groonga '/column_remove',
    table: 'Lexicon'
    name: 'tweet_text', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/table_remove',
    name: 'Lexicon', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/column_remove',
    table: 'Tweets'
    name: 'text', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/column_remove',
    table: 'Tweets'
    name: 'created_at', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/table_remove',
    name: 'Tweets', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/table_create',
    name: 'Tweets'
    key_type: 'ShortText', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/column_create',
    table: 'Tweets'
    name: 'text'
    flags: 'COLUMN_SCALAR'
    type: 'ShortText', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/column_create',
    table: 'Tweets'
    name: 'created_at'
    flags: 'COLUMN_SCALAR'
    type: 'Time', 'GET'
.then (res) ->
  console.log res
  utils.groonga '/table_create',
    name: 'Lexicon'
    flags: 'TABLE_PAT_KEY'
    key_type: 'ShortText'
    default_tokenizer: config.groonga.tokenizer
    normalizer: config.groonga.normalizer, 'GET'
.then (res) ->
  console.log res
  utils.groonga '/column_create',
    table: 'Lexicon'
    name: 'tweet_text'
    flags: 'COLUMN_INDEX|WITH_POSITION'
    type: 'Tweets'
    source: 'text', 'GET'
.then (res) ->
  console.log res

Tweet.ensureIndexes()

# read index
eval fs.readFileSync(__dirname + '/../import/tweet_index.js').toString()

# read by month
for month in tweet_index
  filename = "#{month.year}_" + (if month.month < 10 then '0' else '') + "#{month.month}.js"
  do (filename) ->
    promise = promise.then ->
      console.log "Start: #{filename}"
      tweetsJSON = fs.readFileSync(__dirname + '/../import/tweets/' + filename).toString().split('\n')
      tweetsJSON.shift()
      tweets = JSON.parse tweetsJSON.join('\n')

      # mongodb and groonga
      return Tweet.create tweets, ->
        console.log "mongodb inserted."
      .then ->
        json = JSON.stringify(tweets.map (tweet) ->
          createdAt = new Date(tweet.created_at)
          text = XmlEntities.decode(utils.urlExpandedText(tweet))
          return {_key: tweet.id_str, text: text, created_at: createdAt.getTime() / 1000.0})
        return utils.groonga '/load',
          table: 'Tweets', 'POST', [json]
      .then (res) ->
        console.log "groonga inserted: #{res}"

promise.then ->
  console.log 'Done'
  return 0
.finally process.exit
