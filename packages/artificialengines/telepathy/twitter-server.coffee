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
    @initialized = true

  @statuses:
    userTimeline: -> AT.Twitter.get 'statuses/user_timeline', arguments...
    show: -> AT.Twitter.get 'statuses/show', arguments...
      
  @users:
    lookup: -> AT.Twitter.get 'users/lookup', arguments...

  @get: (url, params, callback) ->
    throw new AE.InvalidOperationException 'Twitter was not initialized.' unless @initialized

    try
      if callback
        @_twitGet url, params, (error, data, response) =>
          if error
            @_handleError error
            return

          callback data

      else
        data = @_twitGet url, params

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
