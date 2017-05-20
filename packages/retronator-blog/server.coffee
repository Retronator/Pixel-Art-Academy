AT = Artificial.Telepathy

# Prepare the server part of the PixelDailies class.
class Retronator.Blog extends Retronator.Blog
  @processPostHistory: (options = {}) ->
    options.processedCount ?= 0

    # Stop processing when count reached zero.
    return if options.count is 0

    # We can only get 20 posts with one API call.
    count = Math.min options.count ? 20, 20

    # Get the desired amount of tweets.
    params =
      reblog_info: true
      offset: options.offset or 0

    # Query the API.
    AT.Tumblr.blogPosts 'retronator.tumblr.com', params, (error, data) =>
      # Process posts.
      @processPost post, options for post in data.posts

      # Try to process older posts (if this query even returned any data).
      return unless data.posts.length

      newOptions = _.extend {}, options,
        processedCount: options.processedCount + 20
        offset: params.offset + 20

      # Only countdown if we had count specified to begin with.
      newOptions.count = options.count - count if options.count

      console.log "Processed", newOptions.processedCount, "posts."

      @processPostHistory newOptions

# Initialize on startup.
Meteor.startup ->
  return unless AT.Tumblr.initialized

  # Update all posts every day to get updated notes counts.
  new Cron =>
    console.log "Updating all Retronator posts."
    Retronator.Blog.processPostHistory()
  ,
    hour: 0

  # Look for new posts every hour and force reprocessing to catch any post edits.
  new Cron =>
    console.log "Fetching latest 20 Retronator posts."
    Retronator.Blog.processPostHistory
      count: 20
      reprocess: true
  ,
    minute: 0
