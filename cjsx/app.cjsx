Main = React.createClass(
  getInitialState: ->
    {tweets: [], count: 0, paging: false}
  componentDidMount: ->
    @socket = io.connect()
    @socket.on 'search', (msg) =>
      @done = msg.done
      window.scrollTo 0, 0
      @setState
        tweets: msg.result
        count: msg.count
        paging: false

    @socket.on 'append', (msg) =>
      return unless msg.query == @query
      @done = msg.done
      @setState
        tweets: @state.tweets.concat(msg.result)
        paging: false

    window.addEventListener 'scroll', (scroll) =>
      h = Math.max(document.documentElement.clientHeight, window.innerHeight ? 0)
      s = document.documentElement.scrollTop or document.body.scrollTop
      scrolled = (h + s) >= document.body.offsetHeight
      @appendPage() if scrolled && !@state.paging && !@done

    @search ''

  search: (query) ->
    @query = query
    @offset = 0
    @done = false
    @setState
      paging: true
    @socket.emit 'search',
      query: @query
      skip: @offset
      limit: 30
      dateMin: new Date(0) # distant past
      dateMax: new Date()  # present
      order: false

  appendPage: ->
    @offset += 30
    @setState
      paging: true
    @socket.emit 'search',
      query: @query
      skip: @offset
      limit: 30
      dateMin: new Date(0) # distant past
      dateMax: new Date()  # present
      order: false

  render: ->
    <div id="main">
      <SearchBox handleInput={@search} count={@state.count} />
      <TweetList tweets={@state.tweets} paging={@state.paging} />
    </div>
)

SearchBox = React.createClass(
  handleInput: ->
    @props.handleInput @refs.query.getDOMNode().value

  render: ->
    <div id="head">
      <h1><img src="/images/top.png" /></h1>
      <input type="text" name="query" ref="query" placeholder="Search" onInput={@handleInput} />
      {if @props.count? then <p id="count">{@props.count} posts</p> else null}
    </div>
)

Loading = React.createClass(
  render: ->
    <article className="loading">
      <img src="/images/loading.gif" width="48" height="48" />
    </article>
)

TweetList = React.createClass(
  render: ->
    Tweets = <div>Loading...</div>
    if @props.tweets?
      Tweets = @props.tweets.map (tweet) ->
        <Tweet key={tweet.id_str} tweet={tweet} />
    <div id="tweets">
      {Tweets}
      {if @props.paging then <Loading /> else null }
    </div>
)

Tweet = React.createClass(
  baseTweet: ->
    @props.tweet.retweeted_status ? @props.tweet
  expandedText: ->
    tweet = @baseTweet()
    urls = (tweet.entities.urls ? []).map (url) ->
      indices: url.indices
      display: "<a href=\"#{url.expanded_url}\">#{url.display_url}</a>"
    medias = (tweet.entities.media ? []).map (media) ->
      indices: media.indices
      display: "<a href=\"#{media.expanded_url}\">#{media.display_url}</a>"
    mentions = (tweet.entities.user_mentions ? []).map (mention) ->
      indices: mention.indices
      display: "<a href=\"https://twitter.com/#{mention.screen_name}\">@#{mention.screen_name}</a>"
    entities = urls.concat(medias, mentions)
    entities.sort (a, b) ->
      a.indices[0] - b.indices[0]
    extendedLength = 0
    text = tweet.text
    for entity in entities
      from = entity.indices[0] + extendedLength
      to = entity.indices[1] + extendedLength
      length = entity.indices[1] - entity.indices[0]
      extendedLength += (entity.display.length - length)
      text = text.substr(0, from) + entity.display + text.substr(to)
    return text
  userLink: ->
    tweet = @baseTweet()
    "https://twitter.com/#{tweet.user.screen_name}"
  permalink: ->
    tweet = @baseTweet()
    "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id_str}"
  favstarLink: ->
    tweet = @baseTweet()
    "https://favstar.fm/users/#{tweet.user.screen_name}/status/#{tweet.id_str}"
  createdAt: ->
    moment(new Date(@baseTweet().created_at)).format('YYYY-MM-DD HH:mm:ss')

  render: ->
    <article className="tweet">
      <img className="profile_image" src={@baseTweet().user.profile_image_url_https} />
      <div className="right">
        <p className="user"><a href={@userLink()}>@{@baseTweet().user.screen_name}&#x2005;/&#x2005;{@baseTweet().user.name}</a></p>
        <p className="tweet_text" dangerouslySetInnerHTML={{__html: @expandedText()}}></p>
        <ul>
          <li><a href={@permalink()}><time>{@createdAt()}</time></a></li>
          <li>From <span dangerouslySetInnerHTML={{__html: @baseTweet().source}}></span></li>
        </ul>
      </div>
    </article>
)

React.render <Main />, document.getElementById 'container'
