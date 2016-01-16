PAA = PixelArtAcademy
Twit = Npm.require 'twit'
TwitterText = Npm.require 'twitter-text'

# Prepare the server part of the PixelDailies class.
class PAA.PixelDailies extends PAA.PixelDailies
  @_twit = new Twit
    consumer_key: 'dsAoBmJ4Cpo1OEfdavpRGzEzF'
    consumer_secret: 'WTa0eb6CotiUnCH85fisziFDgAul98ULhCyXJUdY7tSfTSno39'
    app_only_auth: true

  @_twitGet = Meteor.wrapAsync @_twit.get.bind @_twit

  @processTweetHistory: (options = {}) ->
    options.processedCount ?= 0

    # We can only see the history for 3200 tweets back (API limit).
    return if options.processedCount >= 400

    # Get 200 tweets.
    params =
      exclude_replies: true
      contributor_details: true
      include_rts: true
      screen_name: 'Pixel_Dailies'
      count: 200

    # Start back from maxId if set.
    params.max_id = options.maxId if options.maxId

    # Query the API
    @_twitGet 'statuses/user_timeline', params, (error, data, response) =>
      if error
        console.log "Error accessing tweets.", error
        return

      # Process tweets.
      @processTweet tweet for tweet in data

      # Try to process older tweets (if this query even returned any data).
      return unless data.length

      @processTweetHistory
        processedCount: options.processedCount + 200
        maxId: data[data.length-1].id

  @processTweet: (tweet) ->
    if tweet.retweeted_status
      # This is a retweet, it's probably an artwork!

    else
      # Do not process a tweet if it was already inserted.
      existing = @Theme.documents.findOne
        'tweetData.id': tweet.id

      return if existing

      # Prepare new document parameters.
      theme =
        date: new Date tweet.created_at
        text: tweet.text
        tweetData: tweet

      # The theme tweets must have a #pixel_dailies and another tag, which is the theme tag.
      hashtags = TwitterText.extractHashtags tweet.text
      if _.contains hashtags, 'pixel_dailies'
        themeHashtags = _.without hashtags, 'pixel_dailies'

        if themeHashtags.length is 0
          # We don't have anything but the #pixel_dailies hashtag, so flag the error.
          theme.processingError = @Theme.ProcessingError.NoExtraHashtag

        else
          theme.hashtag = "##{themeHashtags[0]}"

          if themeHashtags.length > 1
            # We have more than one hashtag besides #pixel_dailies, so flag the
            # (potential) error (we optimistically chose the first hashtag above).
            theme.processingError = @Theme.ProcessingError.MultipleExtraHashtags

      else
        # We don't have the #pixel_dailies hashtag, so flag the error.
        theme.processingError = @Theme.ProcessingError.MissingPixelDailiesHashtag

      # Insert the processed theme into the database.
      @Theme.documents.insert theme

# Initialize on startup.
Meteor.startup ->
  # Parse the full history of last 3200 tweets on startup.
  PAA.PixelDailies.processTweetHistory()
