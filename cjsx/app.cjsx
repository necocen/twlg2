Main = React.createClass(
  getInitialState: ->
    {tweets: [], count: 0}
  componentDidMount: ->
    @socket = io.connect()
    @socket.on 'search', (msg) =>
      @paging = false
      @done = msg.done
      @setState
        tweets: msg.result
        count: msg.count
    @socket.on 'append', (msg) =>
      return unless msg.query == @query
      @paging = false
      @done = msg.done
      @setState
        tweets: @state.tweets.concat(msg.result)

    window.addEventListener 'scroll', (scroll) =>
      h = Math.max(document.documentElement.clientHeight, window.innerHeight ? 0)
      s = document.documentElement.scrollTop or document.body.scrollTop
      scrolled = (h + s) >= document.body.offsetHeight
      @appendPage() if scrolled && !@paging && !@done

    @search ''

  search: (query) ->
    @query = query
    @offset = 0
    @paging = true
    @socket.emit 'search',
      query: @query
      skip: @offset
      limit: 30
      dateMin: new Date(0) # distant past
      dateMax: new Date()  # present
      order: false

  appendPage: ->
    @offset += 30
    @paging = true
    @socket.emit 'search',
      query: @query
      skip: @offset
      limit: 30
      dateMin: new Date(0) # distant past
      dateMax: new Date()  # present
      order: false

  render: ->
    <div className="main">
      <SearchBox handleInput={@search} count={@state.count} />
      <TweetList tweets={@state.tweets} />
    </div>
)

SearchBox = React.createClass(
  handleInput: ->
    @props.handleInput @refs.query.getDOMNode().value

  render: ->
    <div className="head">
      <h1><img src="/images/top.png" /></h1>
      <input type="text" name="query" ref="query" onInput={@handleInput} />
      <p className="count">count: {@props.count}</p>
    </div>
)

TweetList = React.createClass(
  render: ->
    Tweets = <div>Loading...</div>
    if @props.tweets?
      Tweets = @props.tweets.map (tweet) ->
        <Tweet key={tweet.id_str} tweet={tweet} />
    <div className="tweets">
      {Tweets}
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
    <article className="tweets">
      <img src={@baseTweet().user.profile_image_url_https} />
      <div className="right">
        <ul>
          <li><a href={@userLink()}>@{@baseTweet().user.screen_name} / {@baseTweet().user.name}</a></li>
        </ul>
        <p dangerouslySetInnerHTML={{__html: @expandedText()}}></p>
        <ul>
          <li><a href={@permalink()}><time>{@createdAt()}</time></a></li>
          <li><a href={@favstarLink()}>Favs</a></li>
          <li>From: <span dangerouslySetInnerHTML={{__html: @baseTweet().source}}></span></li>
        </ul>
      </div>
    </article>
)

React.render <Main />, document.getElementById 'container'
