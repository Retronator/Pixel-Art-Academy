AE = Artificial.Everywhere
AT = Artificial.Telepathy
TumblrAPI = Npm.require 'tumblr.js'

# Tumblr API.
class AT.Tumblr
  if Meteor.settings.tumblr
    @_client = TumblrAPI.createClient
      consumer_key: Meteor.settings.tumblr.consumerKey
      consumer_secret: Meteor.settings.tumblr.consumerSecret
      token: Meteor.settings.tumblr.token
      token_secret: Meteor.settings.tumblr.tokenSecret
      
    @initialized = true

    # Wrap methods.
    for methodName in ['blogPosts', 'userInfo', 'blogFollowers']
      @[methodName] = Meteor.wrapAsync @_client[methodName].bind @_client
