AT = Artificial.Telepathy
PADB = PixelArtDatabase

# Prepare the server part of the PixelDailies class.
class PADB.PixelDailies extends PADB.PixelDailies
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
      tweet_mode: 'extended'

    # Start back from maxId if set.
    params.max_id = options.maxId if options.maxId

    # Query the API.
    AT.Twitter.userTimeline params, (data) =>
      # Process tweets.
      @processTweet tweet for tweet in data

      # Try to process older tweets (if this query even returned any data).
      return unless data.length

      newOptions =
        processedCount: options.processedCount + 200
        maxId: data[data.length - 1].id

      # Only countdown if we had count specified to begin with.
      newOptions.count = options.count - count if options.count

      @processTweetHistory newOptions

# Initialize on startup.
Meteor.startup ->
  return unless AT.Twitter.initialized

  # Parse the full history of last 3200 tweets on startup.
  PADB.PixelDailies.processTweetHistory()

  # Gather new tweets every hour. Do it 10 minutes after so that the new theme is captured as soon as possible.
  new Cron =>
    console.log "Fetching 200 latest Pixel Dailies tweets."
    PADB.PixelDailies.processTweetHistory
      count: 200
  ,
    minute: 10
