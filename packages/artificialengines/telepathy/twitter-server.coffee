AE = Artificial.Everywhere
AT = Artificial.Telepathy
Twit = Npm.require 'twit'

# Twitter API wrapper.
class AT.Twitter
  if Meteor.settings.twitter
    @_twit = new Twit
      consumer_key: Meteor.settings.twitter.consumerKey
      consumer_secret: Meteor.settings.twitter.secret
      app_only_auth: true

    @_twitGet = Meteor.wrapAsync @_twit.get.bind @_twit
    @_twitPost = Meteor.wrapAsync @_twit.post.bind @_twit
    @initialized = true

    urls = [
      'statuses/user_timeline'
      'statuses/show'
      'users/lookup'
    ]

    for url in urls
      do (url) =>
        urlParts = url.split '/'
        groupName = urlParts[0]
        methodName = _.camelCase urlParts[1]

        # Create get and post variants of the method.
        @[groupName] ?= {}
        @[groupName][methodName] = -> AT.Twitter.get url, arguments...
        @[groupName]["#{methodName}Post"] = -> AT.Twitter.post url, arguments...

  @get: -> @_call @_twitGet, arguments...
  @post: -> @_call @_twitPost, arguments...

  @_call: (method, url, params, callback) ->
    throw new AE.InvalidOperationException 'Twitter was not initialized.' unless @initialized

    try
      if callback
        method url, params, (error, data, response) =>
          if error
            @_handleError error
            return

          callback data

      else
        data = method url, params

        unless data
          console.log "Error accessing Twitter API."
          return

        data

    catch error
      @_handleError error

  @_handleError: (error) ->
    switch error.code
      when 88
        throw new AE.LimitExceededException "Twitter API rate limit exceeded."

      else
        throw error
