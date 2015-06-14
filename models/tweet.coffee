mongoose = require('mongoose')
mediaSchema = mongoose.Schema(
  display_url: String
  expanded_url: String
  id_str: String
  indices: [Number]
  media_url: String
  media_url_https: String
  sizes:
    thumb:
      h: Number
      resize: String
      w: Number
    large:
      h: Number
      resize: String
      w: Number
    medium:
      h: Number
      resize: String
      w: Number
    small:
      h: Number
      resize: String
      w: Number
  source_status_id_str: String
  type: String
  url: String)

module.exports = mongoose.Schema(
  contributors: [{
    id_str: String
    screen_name: String
  }]
  coordinates:
    coordinates: [Number]
    type: String
  created_at:
    type: Date
    index: true
  current_user_retweet: id_str: String
  entities:
    hashtags: [{
      indices: [Number]
      text: String
    }]
    media: [mediaSchema]
    urls: [{
      indices: [Number]
      url: String
      display_url: String
      expanded_url: String
    }]
    user_mentions: [{
      name: String
      indices: [Number]
      screen_name: String
      id_str: String
    }]
  favorite_count: Number
  favorited: Boolean
  filter_level: String
  id_str:
    type: String
    unique: true
  in_reply_to_screen_name: String
  in_reply_to_status_id_str: String
  lang: String
  place:
    attributes: {}
    bounding_box:
      coordinates: [[[Number]]]
      type: String
    country: String
    country_code: String
    full_name: String
    id: String
    name: String
    place_type: String
    url: String
  possibly_sensitive: Boolean
  scopes: followers: Boolean
  retweet_count: Number
  retweeted: Boolean
  retweeted_status: {}
  source: String
  text: String
  truncated: Boolean
  user:
    contributors_enabled: Boolean
    created_at: Date
    default_profile: Boolean
    default_profile_image: Boolean
    description: String
    entities:
      hashtags: [{
        indices: [Number]
        text: String
      }]
      media: [{
        display_url: String
        expanded_url: String
        id_str: String
        indices: [Number]
        media_url: String
        media_url_https: String
        sizes:
          thumb:
            h: Number
            resize: String
            w: Number
          large:
            h: Number
            resize: String
            w: Number
          medium:
            h: Number
            resize: String
            w: Number
          small:
            h: Number
            resize: String
            w: Number
        source_status_id_str: String
        type: String
        url: String
      }]
      urls: [{
        indices: [Number]
        url: String
        display_url: String
        expanded_url: String
      }]
      user_mentions: [{
        name: String
        indices: [Number]
        screen_name: String
        id_str: String
      }]
    favourites_count: Number
    follow_request_sent: Boolean
    following: Boolean
    followers_count: Number
    friends_count: Number
    geo_enabled: Boolean
    id_str: String
    is_translator: Boolean
    lang: String
    listed_count: Number
    location: String
    name: String
    notification: Boolean
    profile_background_color: String
    profile_background_image_url: String
    profile_background_image_url_https: String
    profile_background_tile: Boolean
    profile_banner_url: String
    profile_image_url: String
    profile_image_url_https: String
    profile_link_color: String
    profile_sidebar_border_color: String
    profile_sidebar_fill_color: String
    profile_text_color: String
    profile_use_background_image: Boolean
    protected: Boolean
    screen_name: String
    show_all_inline_media: Boolean
    status: {}
    statuses_count: Number
    time_zone: String
    url: String
    utc_offset: Number
    verified: Boolean
    withheld_in_countries: String
    withheld_scope: String
  withheld_copyright: Boolean
  withheld_in_countries: [String]
  with_scope: String)
