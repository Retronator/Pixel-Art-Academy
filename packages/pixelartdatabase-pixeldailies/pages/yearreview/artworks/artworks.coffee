AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Artworks extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artworks'

  @title: (options) ->
    "Retronator // Top Pixel Dailies #{options.year}: Artworks"

  @description: (options) ->
    "Gallery of the best pixel art works from the Pixel Dailies community in #{options.year}."

  # Subscriptions
  @mostPopular: new AB.Subscription
    name: "#{@componentName()}.mostPopular"
    query: (year, limit) =>
      # Take top submissions in the year.
      yearRange = new AE.DateRange year: year

      submissionsQuery =
        processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition

      yearRange.addToMongoQuery submissionsQuery, 'time'

      submissionsCursor = PADB.PixelDailies.Submission.documents.find submissionsQuery,
        sort:
          favoritesCount: -1
        limit: limit
        fields:
          tweetData: 0

      artworksCursor = PADB.PixelDailies.Pages.YearReview.Helpers.prepareArtworksCursorForSubmissionsCursor submissionsCursor

      [submissionsCursor, artworksCursor]

  onCreated: ->
    super

    @stream = new ReactiveField null

    # Subscribe to most popular artworks.
    @autorun (computation) =>
      return unless stream = @stream()

      @constructor.mostPopular.subscribe @, @year(), stream.infiniteScroll.limit()

    # Prepare artworks for the stream.
    @artworks = new ComputedField =>
      return [] unless stream = @stream()
      [submissionsCursor, artworksCursor] = @constructor.mostPopular.query @year(), stream.infiniteScroll.limit()

      PADB.PixelDailies.Pages.YearReview.Helpers.prepareTopArtworks artworksCursor.fetch()

  onRendered: ->
    super

    @stream @childComponents(PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Stream)[0]

  year: ->
    parseInt FlowRouter.getParam 'year'
