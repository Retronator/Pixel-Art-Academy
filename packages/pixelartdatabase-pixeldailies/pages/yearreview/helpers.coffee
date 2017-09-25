AE = Artificial.Everywhere
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Helpers
  # Sorts artworks by favorites count and includes a rank.
  @prepareTopArtworks: (artworks) ->
    artworks = for artwork in artworks
      # Find image URL.
      imageRepresentation = _.find artwork.representations, type: PADB.Artwork.RepresentationTypes.Image

      submission = PADB.PixelDailies.Submission.documents.findOne
        'images.imageUrl': imageRepresentation.url

      artwork.favoritesCount = submission.favoritesCount

      artwork

    artworks = _.reverse _.sortBy artworks, 'favoritesCount'

    # Add ranks.
    artwork.rank = index + 1 for artwork, index in artworks

    artworks

  # Creates the artworks cursor based on submissions
  @prepareArtworksCursorForSubmissionsCursor: (submissionsCursor) ->
    submissions = submissionsCursor.fetch()

    artworkIds = for submission in submissions
      for image in submission.images
        artwork = PADB.Artwork.documents.findOne
          'representations.url': image.imageUrl

        artwork?._id

    artworkIds = _.flatten artworkIds

    PADB.Artwork.documents.find
      _id:
        $in: artworkIds

  @convertSubmissionToArtworks: (submission) ->
    # Find type of the image.
    for image in submission.images
      artwork = new PADB.Artwork

      artwork.type = if image.animated then PADB.Artwork.Types.AnimatedImage else PADB.Artwork.Types.Image

      # Create representations of this image.
      artwork.representations = [
        type: PADB.Artwork.RepresentationTypes.Image
        url: image.imageUrl
      ,
        type: PADB.Artwork.RepresentationTypes.Post
        url: submission.tweetUrl
      ]

      if image.animated
        artwork.representations.push
          type: PADB.Artwork.RepresentationTypes.Video
          url: image.videoUrl

      artwork.favoritesCount = submission.favoritesCount

      artwork

  @artistUrl: (screenName, year) ->
    FlowRouter.path 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artist',
      year: year or FlowRouter.getParam('year') or new Date().getFullYear()
      screenName: screenName

  Template.registerHelper 'pixelDailiesArtistUrl', (screenName, year) =>
    # Make sure year is a number (if no year is passed, it will be the Kw hash).
    year = null unless _.isNumber year

    @artistUrl screenName, year

  @displayableSubmissionsCondition:
    $nin: [
      PADB.PixelDailies.Submission.ProcessingError.NoImages
      PADB.PixelDailies.Submission.ProcessingError.ImagesNotFound
    ]
