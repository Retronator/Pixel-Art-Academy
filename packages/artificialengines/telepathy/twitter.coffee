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

  @userTimeline: -> @get 'statuses/user_timeline', arguments...
  @usersLookup: -> @get 'users/lookup', arguments...

  @get: (url, params, callback) ->
    if callback
      @_twitGet url, params, (error, data, response) =>
        if error
          console.log "Error accessing Twitter API.", error
          return

        callback data

    else
      data = @_twitGet url, params

      unless data
        console.log "Error accessing Twitter API."
        return

      data
