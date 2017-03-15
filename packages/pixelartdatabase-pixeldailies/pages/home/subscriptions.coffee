AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns the last 14 themes to display on the homepage.
PADB.PixelDailies.Pages.Home.themes.publish ->
  themesCursor = PADB.PixelDailies.Theme.documents.find {},
    sort:
      time: -1
    limit: 14

  themes = themesCursor.fetch()
  themeIds = (theme._id for theme in themes)

  submissionsCursor = PADB.PixelDailies.Submission.documents.find
    'theme._id':
      $in: themeIds

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

  [themesCursor, submissionsCursor, artworksCursor]
