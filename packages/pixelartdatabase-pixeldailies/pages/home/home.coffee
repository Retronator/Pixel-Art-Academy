AM = Artificial.Mirage
AB = Artificial.Base
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Home extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Home'

  # Subscriptions
  @themes: new AB.Subscription name: "PixelArtDatabase.PixelDailies.Pages.Home.themes"

  onCreated: ->
    super

    @constructor.themes.subscribe()

  todaysTheme: ->
    theme = PADB.PixelDailies.Theme.documents.findOne {},
      sort:
        time: -1

    console.log "t", theme

    # Return empty object when loading so that a placeholder is rendered.
    theme or {}

  todaysDate: ->
    theme = @currentData()

    theme.time?.toLocaleString Artificial.Babel.userLanguagePreference()[0] or 'en-US',
      weekday: 'long'
      month: 'long'
      day: 'numeric'
      year: 'numeric'

  lastWeekThemes: ->
    PADB.PixelDailies.Theme.documents.find {},
      sort:
        time: -1
      limit: 7
      skip: 1

  background: ->
    url: 'https://pbs.twimg.com/media/C18pKdxUcAAKyQX.png'
    author: 'EnchaeC'

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
      FlowRouter.path 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day',
        year: date.getFullYear()
        month: _.toLower date.toLocaleString 'en-US', month: 'long'
        day: date.getDate()

    artworks: ->
      theme = @data()
      return unless theme.topSubmissions

      # Show top 3 artworks.
      artworks = for submission in theme.topSubmissions[...3]
        PADB.PixelDailies.Pages.YearReview.Helpers.convertSubmissionToArtworks submission

      _.flatten artworks
