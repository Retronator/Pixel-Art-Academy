AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Day extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day'

  @title: (options) ->
    date = @date options
    return PADB.PixelDailies.Pages.YearReview.title options unless date

    "Retronator // Top Pixel Dailies: #{@dateTitle date: date}"

  @description: (options) ->
    date = @date options
    return PADB.PixelDailies.Pages.YearReview.description options unless date

    "Gallery of the best Pixel Dailies submissions for #{@dateTitle date: date, weekday: true}."

  @image: (options) ->
    date = @date options
    return unless date

    # Find the best submission for this day.
    [themesCursor, submissionsCursor, artworksCursor] = @themeSubmissions.query date, 1
    submissionsCursor.fetch()[0]?.images[0].imageUrl

  @date: (options) ->
    return unless options.year and options.month and options.day

    new Date "#{options.day} #{options.month} #{options.year}"

  @dateTitle: (options) ->
    dateFormat =
      month: 'long'
      day: 'numeric'
      year: 'numeric'

    dateFormat.weekday = 'long' if options.weekday
      
    options.date.toLocaleString Artificial.Babel.currentLanguage(), dateFormat

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

      # Find the main theme.
      theme = PADB.PixelDailies.Theme.documents.findOne themeQuery

      # If we didn't find a theme on that day, use the requested date as the search start.
      themeTime = theme?.time or date

      # Return the main theme and next theme.
      themesCursor = PADB.PixelDailies.Theme.documents.find
        time:
          $gte: themeTime
        processingError:
          $exists: false
      ,
        sort:
          time: 1
        limit: 2
        fields:
          tweetData: 0

      return [themesCursor] unless theme

      submissionsCursor = PADB.PixelDailies.Submission.documents.find
        'theme._id': theme._id
        processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition
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
      @constructor.date
        year: FlowRouter.getParam 'year'
        month: FlowRouter.getParam 'month'
        day: FlowRouter.getParam 'day'

    @infiniteScroll = new ReactiveField null
    @_themeSubmissionSubscriptionsHandle = new ReactiveField null

    @autorun (computation) =>
      return unless date = @date()
      return unless infiniteScroll = @infiniteScroll()

      @_themeSubmissionSubscriptionsHandle @constructor.themeSubmissions.subscribe @, date, infiniteScroll.limit()

    @theme = new ReactiveField null
    @nextTheme = new ReactiveField null
    @artworks = new ReactiveField null

    @autorun (computation) =>
      date = @date()
      infiniteScroll = @infiniteScroll()

      unless date and infiniteScroll
        @artworks []
        return

      [themesCursor, submissionsCursor, artworksCursor] = @constructor.themeSubmissions.query date, infiniteScroll.limit()

      # Find the theme on the given day
      dayRange = new AE.DateRange
        year: date.getFullYear()
        month: date.getMonth()
        day: date.getDate()

      themeQuery =
        processingError:
          $exists: false

      dayRange.addToMongoQuery themeQuery, 'time'

      # Find the main theme.
      theme = PADB.PixelDailies.Theme.documents.findOne themeQuery
      @theme theme

      # Find the next theme.
      themeTime = theme?.time or date
      @nextTheme PADB.PixelDailies.Theme.documents.findOne
        time:
          $gt: themeTime
      ,
        sort:
          time: 1

      unless artworksCursor
        @artworks []
        return

      if artworksCursor
        artworks = for artwork in artworksCursor.fetch()
          # Find image URL.
          imageRepresentation = _.find artwork.representations, type: PADB.Artwork.RepresentationTypes.Image

          submission = PADB.PixelDailies.Submission.documents.findOne
            'images.imageUrl': imageRepresentation.url

          artwork.favoritesCount = submission.favoritesCount

          artwork

        # If we don't have the artworks loaded yet, use top submissions as placeholders. We pretty
        # much repeat the archive submission code to create a temporary artwork out of the submission.
        if not artworks.length and theme.topSubmissions?.length
          artworks = for submission in theme.topSubmissions
            PADB.PixelDailies.Pages.YearReview.Helpers.convertSubmissionToArtworks submission

          artworks = _.flatten artworks

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

  themesReady: ->
    @_themeSubmissionSubscriptionsHandle()?.ready()

  dateTitle: ->
    @constructor.dateTitle
      date: @date()
      weekday: true

  topArtworkImageUrl: ->
    return unless artwork = @artworks()?[0]
    artwork.firstImageRepresentation().url

  nextThemeUrl: ->
    @_dateUrl @nextTheme().time

  previousDayUrl: ->
    @_offsetDayUrl -1

  nextDayUrl: ->
    @_offsetDayUrl 1

  _offsetDayUrl: (offset) ->
    date = @date()
    @_dateUrl new Date date.getFullYear(), date.getMonth(), date.getDate() + offset

  _dateUrl: (date) ->
    FlowRouter.path 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day',
      year: date.getFullYear()
      month: _.toLower date.toLocaleString 'en-US', month: 'long'
      day: date.getDate()
