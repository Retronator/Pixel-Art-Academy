AM = Artificial.Mirage
AB = Artificial.Base
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Home extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Home'

  @title: (options) ->
    "Retronator // Pixel Dailies Archive"

  # Subscriptions
  @themes: new AB.Subscription
    name: "PixelArtDatabase.PixelDailies.Pages.Home.themes"
    query: (limit) ->
      themesCursor = PADB.PixelDailies.Theme.documents.find {},
        sort:
          time: -1
        limit: limit

      themes = themesCursor.fetch()
      themeIds = (theme._id for theme in themes)

      submissionsCursor = PADB.PixelDailies.Submission.documents.find
        'theme._id':
          $in: themeIds

      [themesCursor, submissionsCursor]

  mixins: -> [@infiniteScroll]

  constructor: ->
    super

    @infiniteScroll = new PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll
      step: 3
      windowHeightCounts: 3
  
  onCreated: ->
    super

    # Subscribe to last themes.
    @autorun (computation) =>
      @constructor.themes.subscribe @, @infiniteScroll.limit()

    # Prepare artworks for the stream.
    @themes = new ComputedField =>
      [themesCursor, submissionsCursor] = @constructor.themes.query @infiniteScroll.limit()
      themesCursor.fetch()

    # Update current count for infinite scroll.
    @autorun (computation) =>
      themes = @themes()

      @infiniteScroll.updateCount themes?.length or 0

  todaysTheme: ->
    theme = @themes()[0]

    # Return empty object when loading so that a placeholder is rendered.
    theme or {}

  todaysDate: ->
    theme = @currentData()

    theme.time?.toLocaleString Artificial.Babel.userLanguagePreference()[0] or 'en-US',
      weekday: 'long'
      month: 'long'
      day: 'numeric'
      year: 'numeric'

  background: ->
    url: 'https://pbs.twimg.com/media/C1XpVnQXEAAiNuD.png'
    author: 'vierbit'

  class @Theme extends AM.Component
    @register 'PixelArtDatabase.PixelDailies.Pages.Home.Theme'

    onCreated: ->
      super

      @showingTopOnly = new ReactiveField true

    artworkCaptionClass: ->
      PADB.PixelDailies.Pages.Home.ArtworkCaption

    themeUrl: ->
      theme = @data()
      @_dateUrl theme.time

    _dateUrl: (date) ->
      AB.Router.createPath 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day',
        year: date.getFullYear()
        month: _.toLower date.toLocaleString 'en-US', month: 'long'
        day: date.getDate()

    artworks: ->
      theme = @data()
      return unless theme.topSubmissions

      # Show top 3 artworks.
      artworks = for submission in theme.topSubmissions[...3] when submission.images
        PADB.PixelDailies.Pages.YearReview.Helpers.convertSubmissionToArtworks submission

      _.flatten artworks
