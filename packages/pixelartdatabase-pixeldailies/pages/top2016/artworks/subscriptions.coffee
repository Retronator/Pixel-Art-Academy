AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns the top 100 submissions with most favorites.
PADB.PixelDailies.Pages.Top2016.Artworks.mostPopular.publish (limit = 10) ->
  # Take top submissions in 2016.
  year2016Range = new AE.DateRange year: 2016

  submissionsQuery =
    processingError:
      $ne: PADB.PixelDailies.Submission.ProcessingError.NoImages

  year2016Range.addToMongoQuery submissionsQuery, 'time'

  submissionsCursor = PADB.PixelDailies.Submission.documents.find submissionsQuery,
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

  artworks = artworksCursor.fetch()

  artistIds = for artwork in artworks
    for artist in artwork.authors
      artist._id

  artistIds = _.flatten artistIds

  artistsCursor = PADB.Artist.documents.find
    _id:
      $in: artistIds

  artists = artistsCursor.fetch()

  profileIds = for artist in artists
    for profile in artist.profiles
      profile._id

  profileIds = _.flatten profileIds

  profilesCursor = PADB.Profile.documents.find
    _id:
      $in: profileIds

  [submissionsCursor, artworksCursor, artistsCursor, profilesCursor]
