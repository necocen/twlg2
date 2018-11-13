# twlg 2

## Deploy

```
$ pm2 deploy ecosystem.json5 production
```

## Crawl
```
/usr/bin/env $HOME/.nodebrew/current/bin/node ./bin/crawl.js
```

## Import
Place logs downloaded from Twitter on `./import`. The final directory tree is below:

```
import/
    tweet_index.js
    tweets/
        YYYY_MM.js
        YYYY_MM.js
        ...
```
