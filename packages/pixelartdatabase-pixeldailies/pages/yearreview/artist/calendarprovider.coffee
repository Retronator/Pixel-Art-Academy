AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Artist.CalendarProvider extends PADB.PixelDailies.Pages.YearReview.Components.Calendar.Provider
  # Subscriptions
  @submissions: new AB.Subscription
    name: "PixelArtDatabase.PixelDailies.Pages.Artist.CalendarProvider.submissions"
    query: (screenName, year, limit) ->
      yearRange = new AE.DateRange year: year

      # We should match the screen name regardless of case.
      submissionsQuery =
        'user.screenName': new RegExp screenName, 'i'
        processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition

      yearRange.addToMongoQuery submissionsQuery, 'time'

      PADB.PixelDailies.Submission.documents.find submissionsQuery,
        sort:
          time: 1
        limit: limit
        fields:
          tweetData: 0

  constructor: (@options) ->
    super arguments...

    @yearRange = new AE.DateRange year: @options.year

    @_subscriptionAutorun = Tracker.autorun (computation) =>
      limit = @limit()

      # Mongo treats a zero limit as unbounded, so wait for the calendar to provide its initial page size.
      return unless limit > 0

      @subscriptionHandle @constructor.submissions.subscribe @options.screenName, @options.year, limit

  destroy: ->
    subscriptionHandle = @subscriptionHandle()
    @_subscriptionAutorun.stop()
    subscriptionHandle?.stop()
    @subscriptionHandle null

  submissions: ->
    @constructor.submissions.query(@options.screenName, @options.year, @limit()).fetch()
