AT = Artificial.Telepathy
PADB = PixelArtDatabase

# Prepare the server part of the Retronator Blog class.
class Retronator.Blog extends Retronator.Blog
  @processPostHistory: (options = {}) ->
    options.processedCount ?= 0

    # Stop processing when count reached zero.
    return if options.count is 0

    # We can only get 20 posts with one API call.
    count = Math.min options.count ? 20, 20

    # Get the desired amount of posts.
    params =
      reblog_info: true
      offset: options.offset or 0

    # Query the API.
    AT.Tumblr.blogPosts 'retronator.tumblr.com', params, (error, data) =>
      if error
        console.error error
        return

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

  @updateFeaturedWebsitePreviews: ->
    featuredWebsites = PADB.Website.documents.find(
      'blogFeature.enabled': true
    ).fetch()

    # Render 1 website per minute.
    for website, index in featuredWebsites
      do (website) =>
        Meteor.setTimeout =>
          @renderWebsitePreview website._id
        ,
          index * 60 * 1000

# Initialize on startup.
Document.startup ->
  return unless AT.Tumblr.initialized

  # Update all posts every day to get updated notes counts.
  new Cron =>
    console.log "Updating all Retronator posts."
    Retronator.Blog.processPostHistory()
  ,
    hour: 0
    minute: 0

  # Look for new posts every hour and force reprocessing to catch any post edits.
  new Cron =>
    console.log "Fetching latest 20 Retronator posts."
    Retronator.Blog.processPostHistory
      count: 20
      reprocess: true
  ,
    minute: 20

  # Update featured website previews once per day.
  # TODO: Re-enable when website rendering works on the new linux server.
  ###
  new Cron =>
    console.log "Updating featured website previews."
    Retronator.Blog.updateFeaturedWebsitePreviews()
  ,
    hour: 2
    minute: 0
  ###
