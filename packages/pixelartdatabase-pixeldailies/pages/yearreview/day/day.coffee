AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Day extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day'

  # Subscriptions
  @themeSubmissions: new AB.Subscription
    name: "#{@componentName()}.themeSubmissions"
    query: (date, limit) =>
      # Find the theme on the given day
      dayRange = new AE.DateRange
        year: date.getFullYear()
        month: date.getMonth()
        day: date.getDate()

      themeQuery =
        processingError:
          $exists: false

      dayRange.addToMongoQuery themeQuery, 'time'

      themesCursor = PADB.PixelDailies.Theme.documents.find themeQuery,
        limit: 1
        fields:
          tweetData: 0

      theme = themesCursor.fetch()[0]
      return [themesCursor] unless theme

      submissionsCursor = PADB.PixelDailies.Submission.documents.find
        'theme._id': theme._id
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

      [themesCursor, submissionsCursor, artworksCursor]

  onCreated: ->
    super

    @date = new ComputedField =>
      year = FlowRouter.getParam 'year'
      month = FlowRouter.getParam 'month'
      day = FlowRouter.getParam 'day'

      return unless year and month and day

      new Date "#{day} #{month} #{year}"

    @infiniteScroll = new ReactiveField null

    @autorun (computation) =>
      return unless date = @date()
      return unless infiniteScroll = @infiniteScroll()

      @constructor.themeSubmissions.subscribe @, date, infiniteScroll.limit()

    @theme = new ReactiveField null
    @artworks = new ReactiveField null

    @autorun (computation) =>
      return unless date = @date()
      return [] unless infiniteScroll = @infiniteScroll()
      [themesCursor, submissionsCursor, artworksCursor] = @constructor.themeSubmissions.query date, infiniteScroll.limit()

      @theme themesCursor.fetch()[0]

      return unless artworksCursor

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

      @artworks artworks

  onRendered: ->
    super

    @autorun (computation) =>
      return unless @date()

      stream = @childComponents(PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Stream)[0]
      return unless stream

      @infiniteScroll stream.infiniteScroll

  dateTitle: ->
    @date().toLocaleString Artificial.Babel.userLanguagePreference()[0] or 'en-US',
      weekday: 'long'
      month: 'long'
      day: 'numeric'
      year: 'numeric'

  topArtworkImageUrl: ->
    return unless artwork = @artworks()?[0]
    artwork.firstImageRepresentation().url
