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

  @artistUrl: (screenName) ->
    FlowRouter.path 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artist',
      year: FlowRouter.getParam 'year'
      screenName: screenName

  Template.registerHelper 'pixelDailiesArtistUrl', (screenName) =>
    @artistUrl screenName
