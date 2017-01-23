PADB = PixelArtDatabase

# Returns the top 100 submissions with most favorites.
PADB.PixelDailies.Pages.Top2016.Artworks.mostPopular.publish (limit = 10) ->
  # Take top submissions.
  submissionsCursor = PADB.PixelDailies.Submission.documents.find
    processingError:
      $exists: false
  ,
    sort:
      favoritesCount: -1
    limit: limit
    fields:
      tweetData: 0

  submissions = submissionsCursor.fetch()

  artworkIds = for submission in submissions
    for image in submission.images
      artwork = PADB.Artwork.documents.findOne
        'representations.url': image.imageUrl

      artwork?._id

  artworkIds = _.flatten artworkIds

  artworksCursor = PADB.Artwork.documents.find
    _id:
      $in: artworkIds

  [submissionsCursor, artworksCursor]
