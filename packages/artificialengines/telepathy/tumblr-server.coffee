AE = Artificial.Everywhere
AT = Artificial.Telepathy
TumblrAPI = Npm.require 'tumblr.js'

# Tumblr API.
class AT.Tumblr
  if Meteor.settings.tumblr
    @_client = TumblrAPI.createClient consumer_key: Meteor.settings.tumblr.consumerKey
    @initialized = true

    # Wrap methods.
    for methodName in ['blogPosts']
      @[methodName] = Meteor.wrapAsync @_client[methodName].bind @_client
