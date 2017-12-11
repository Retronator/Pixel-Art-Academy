AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.ThemesCalendarProvider extends PADB.PixelDailies.Pages.YearReview.Components.Calendar.Provider
  # Subscriptions
  @themes: new AB.Subscription name: "PixelArtDatabase.PixelDailies.Pages.YearReview.ThemesCalendarProvider.themes"

  constructor: (@options) ->
    super

    @yearRange = new AE.DateRange year: @options.year

    @_subscriptionAutorun = Tracker.autorun (computation) =>
      @subscriptionHandle @constructor.themes.subscribe @options.year, @limit()

  destroy: ->
    @_subscriptionAutorun.stop()

  submissions: ->
    # Get themes in the given year.
    themesQuery =
      submissionsCount:
        $gt: 0
      processingError:
        $exists: false

    @yearRange.addToMongoQuery themesQuery, 'time'

    themes = PADB.PixelDailies.Theme.documents.find(themesQuery,
      sort:
        time: 1
      limit: @limit()
    ).fetch()

    # Convert themes to top submissions.
    submissions = for theme in themes
      topSubmission = theme.topSubmissions?[0]

      if topSubmission
        # Modify submission time so it will appear on the date of the theme.
        topSubmission.time = theme.time

        # Add theme data.
        topSubmission.theme = theme

        # Add theme url.
        topSubmission.url = AB.Router.createUrl 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day',
          year: theme.time.getFullYear()
          month: _.toLower theme.time.toLocaleString 'en-US', month: 'long'
          day: theme.time.getDate()

      topSubmission

    _.without submissions, undefined
