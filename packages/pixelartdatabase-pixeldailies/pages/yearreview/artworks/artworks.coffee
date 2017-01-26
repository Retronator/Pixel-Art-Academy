AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Artworks extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artworks'

  # Subscriptions
  @mostPopular: new AB.Subscription
    name: "#{@componentName()}.mostPopular"
    query: (year, limit) =>
      # Take top submissions in the year.
      yearRange = new AE.DateRange year: year

      submissionsQuery =
        processingError:
          $ne: PADB.PixelDailies.Submission.ProcessingError.NoImages

      yearRange.addToMongoQuery submissionsQuery, 'time'

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

      [submissionsCursor, artworksCursor]

  onCreated: ->
    super

    @infiniteScroll = new ReactiveField null

    @autorun (computation) =>
      return unless infiniteScroll = @infiniteScroll()

      @constructor.mostPopular.subscribe @, @year(), infiniteScroll.limit()

    @artworks = new ComputedField =>
      return [] unless infiniteScroll = @infiniteScroll()
      [submissionsCursor, artworksCursor] = @constructor.mostPopular.query @year(), infiniteScroll.limit()

      artworks = for artwork in artworksCursor.fetch()
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

  onRendered: ->
    super

    stream = @childComponents(PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Stream)[0]
    @infiniteScroll stream.infiniteScroll

  year: ->
    parseInt FlowRouter.getParam 'year'
