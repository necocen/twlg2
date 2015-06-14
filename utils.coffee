config = require('config')
http = require('q-io/http')

module.exports =
  groonga: (path, params, method, body) ->
    paramsArray = []
    for k,v of params
      paramsArray.push "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}"
    query = paramsArray.join "&"
    
    return http.request(
      hostname: config.groonga.host
      port: config.groonga.port
      path: '/' + config.groonga.db + path + "?" + query
      method: method
      body: body
      headers: 'Content-Type': 'application/json').then((response) ->
      response.body.read()
    ).then (buffer) ->
      buffer.toString 'utf-8'

  urlExpandedText: (tweet) ->
    text = tweet.text
    extendedLength = 0

    # URL置換によって伸びた長さの保存
    tweet.entities.urls.sort (a, b) ->
      a.indices[0] - b.indices[0]
    tweet.entities.urls.forEach (url) ->
      urlFrom = url.indices[0] + extendedLength
      urlTo = url.indices[1] + extendedLength
      urlLength = url.indices[1] - (url.indices[0])
      extendedLength += url.expanded_url.length - urlLength
      text = text.substr(0, urlFrom) + url.expanded_url + text.substr(urlTo)
    return text
