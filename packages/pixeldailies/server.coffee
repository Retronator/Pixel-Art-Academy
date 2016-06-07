PAA = PixelArtAcademy
Twit = Npm.require 'twit'
TwitterText = Npm.require 'twitter-text'

# Prepare the server part of the PixelDailies class.
class PAA.PixelDailies extends PAA.PixelDailies
  # Setup Twitter API.
  if Meteor.settings.twitter
    @_twit = new Twit
      consumer_key: Meteor.settings.twitter.consumerKey
      consumer_secret: Meteor.settings.twitter.secret
      app_only_auth: true

    @_twitGet = Meteor.wrapAsync @_twit.get.bind @_twit

  else
    console.warn "You need to specify twitter consumer key and secret in the settings file and don't forget to run the server with the --settings flag pointing to it."
    @_twitGet = ->

  @processTweetHistory: (options = {}) ->
    options.processedCount ?= 0

    # Stop processing when count reached zero.
    return if options.count is 0

    # We can only see the history for 3200 tweets back (API limit).
    return if options.processedCount >= 3200

    # We can only get 200 tweets with one API call.
    count = Math.min options.count ? 200, 200

    # Get the desired amount of tweets.
    params =
      exclude_replies: true
      contributor_details: true
      include_rts: true
      screen_name: 'Pixel_Dailies'
      count: count

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

      newOptions =
        processedCount: options.processedCount + 200
        maxId: data[data.length-1].id

      # Only countdown if we had count specified to begin with.
      newOptions.count = options.count - count if options.count

      @processTweetHistory newOptions

  @processTweet: (tweet) ->
    if tweet.retweeted_status
      # This is a retweet, it's probably a submission! Check if we already have it.
      existing = @Submission.documents.findOne
        'tweetData.id': tweet.id

      # Only update favorites count if tweet exists without errors.
      if existing and not existing.processingError
        # See if the favorites count even is bigger.
        if existing.favoritesCount isnt tweet.retweeted_status.favorite_count
          @Submission.documents.update existing._id,
            $set:
              favoritesCount: tweet.retweeted_status.favorite_count

        return

      # Process (or reprocess) the tweet.
      submission =
        time: new Date tweet.retweeted_status.created_at
        text: tweet.retweeted_status.text
        user:
          name: tweet.retweeted_status.user.name
          screenName: tweet.retweeted_status.user.screen_name
        favoritesCount: tweet.retweeted_status.favorite_count
        tweetData: tweet

      # Get tweet images.
      submission.images = []
      if tweet.retweeted_status.extended_entities?.media
        for media in tweet.retweeted_status.extended_entities.media
          switch media.type
            when 'photo'
              submission.tweetUrl ?= media.url
              submission.images.push
                imageUrl: media.media_url

            when 'animated_gif'
              submission.tweetUrl ?= media.url
              submission.images.push
                animated: true
                imageUrl: media.media_url
                videoUrl: media.video_info.variants[0].url

      if submission.images.length
        # Find the closest theme based on the hashtags.
        theme = @_findThemeForTweet tweet.retweeted_status

        if theme
          submission.theme =
            _id: theme._id

        else
          # We couldn't find any theme that would make sense, so flag the error.
          submission.processingError = @Submission.ProcessingError.NoThemeMatch

      else
        submission.processingError = @Submission.ProcessingError.NoImages

      # Insert the processed submission into the database.
      @Submission.documents.upsert 'tweetData.id': tweet.id, submission

    else
      # This is a tweet directly from @Pixel_Dailes so it's likely a
      # theme, but do not process a tweet if it was already inserted.
      existing = @Theme.documents.findOne
        'tweetData.id': tweet.id

      return if existing

      # Prepare new theme document parameters.
      theme =
        time: new Date tweet.created_at
        text: tweet.text
        tweetData: tweet

      # The theme tweets must have a #pixel_dailies and another tag, which is the theme tag.
      hashtags = for hashtag in tweet.entities.hashtags
        hashtag.text.toLowerCase()

      if _.contains hashtags, 'pixel_dailies'
        themeHashtags = _.without hashtags, 'pixel_dailies', 'pixelart'

        if themeHashtags.length is 0
          # We don't have anything but the #pixel_dailies hashtag, so flag the error.
          theme.processingError = @Theme.ProcessingError.NoExtraHashtag

        else
          theme.hashtags = themeHashtags

      else
        # We don't have the #pixel_dailies hashtag, so flag the error.
        theme.processingError = @Theme.ProcessingError.MissingPixelDailiesHashtag

      # Insert the processed theme into the database.
      @Theme.documents.insert theme
      
  @_findThemeForTweet: (tweet) ->
    # Only consider themes in the last 5 days from the tweet.
    tweetTime = new Date tweet.created_at

    dayMilliseconds = 1000 * 60 * 60 * 24
    oneWeekEarlier = new Date tweetTime.getTime() - 5 * dayMilliseconds

    themes = @Theme.documents.find(
      hashtags:
        $exists: true
      time:
        # Before the tweet.
        $lt: tweetTime

        # After one week earlier than the tweet.
        $gt: oneWeekEarlier
    ,
      fields:
        time: 1
        hashtags: 1
    ).fetch()

    unless themes.length
      #console.warn "No themes found in the last 5 days. That's weird.", tweetTime
      return

    tweetText = tweet.text.toLowerCase()

    # Remove urls.
    urlRegex = /(https?):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])?/g
    tweetText = tweetText.replace urlRegex, ''

    # Remove special characters.
    tweetText = tweetText.replace /\W+/g, ' '

    # Add parameters by which we'll sort how good a match the theme is.
    for theme in themes
      theme.exactMatchCount = 0
      theme.fuzzyMatchCount = 0

      # Try to see if a theme hashtag is in the text.
      for themeHashtag in theme.hashtags
        match = @_wordMatchInText themeHashtag, tweetText
        theme.exactMatchCount++ if match is 1
        theme.fuzzyMatchCount = Math.max match, theme.fuzzyMatchCount

    # Sort to find the best theme.
    themes.sort (a, b) ->
      # Sort descending by exact match count.
      return b.exactMatchCount - a.exactMatchCount unless a.exactMatchCount is b.exactMatchCount

      # Sort descending by fuzzy match count.
      b.fuzzyMatchCount - a.fuzzyMatchCount

    #if not themes[0].exactMatchCount and themes[0].fuzzyMatchCount > 0.5
      #console.log "Fuzzy match made on", tweetText, themes

    # Don't do a match with a theme that didn't get an exact match and fuzzy match is below 50%.
    unless themes[0].exactMatchCount or themes[0].fuzzyMatchCount > 0.5
      #console.log "Couldn't find a good match for tweet:", tweetText, themes
      return

    themes[0]

  @_wordMatchInText: (word, text, returnStatus) ->
    # Return a number from 0-1, how likely this word appears in the text (considering typos and close matches).
    bestMatch = 0

    textWords = text.split ' '

    doubleCompoundWords = for i in [0...textWords.length-1]
      "#{textWords[i]} #{textWords[i+1]}"

    tripleCompoundWords = for i in [0...textWords.length-2]
      "#{textWords[i]} #{textWords[i+1]} #{textWords[i+2]}"

    textWords = textWords.concat doubleCompoundWords, tripleCompoundWords

    # First match individual words.
    for otherWord in textWords
      distance = @_levenshteinDistance word, otherWord
      match = 1 - distance / word.length
      if match > bestMatch
        bestMatch = match
        bestMatchWord = "#{word} + #{otherWord} = #{match}"

    if returnStatus then bestMatchWord else bestMatch

  @_levenshteinDistance = (s, t) ->
    # Based on Stack Overflow answer:
    # http://stackoverflow.com/a/6638467
    n = s.length
    m = t.length
    return m if n is 0
    return n if m is 0

    d = []
    d[i] = [] for i in [0..n]
    d[i][0] = i for i in [0..n]
    d[0][j] = j for j in [0..m]

    for c1, i in s
      for c2, j in t
        cost = if c1 is c2 then 0 else 1
        d[i+1][j+1] = Math.min d[i][j+1]+1, d[i+1][j]+1, d[i][j] + cost

    d[n][m]

# Initialize on startup.
Meteor.startup ->
  # Parse the full history of last 3200 tweets on startup.
  PAA.PixelDailies.processTweetHistory()

  # Gather new tweets every hour. Do it 10 minutes after so that the new theme is captured as soon as possible.
  new Cron =>
    console.log "Fetching 200 latest Pixel Dailies tweets."
    PAA.PixelDailies.processTweetHistory
      count: 200
  ,
    minute: 10
