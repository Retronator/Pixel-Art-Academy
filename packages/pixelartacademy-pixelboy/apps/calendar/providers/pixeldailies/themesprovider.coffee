AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

Calendar = PAA.PixelBoy.Apps.Calendar

class Calendar.Providers.PixelDailies.ThemesProvider extends Calendar.Provider
  @calendarComponentClass: ->
    PADB.PixelDailies.ThemeCalendarComponent

  constructor: ->
    super

  subscriptionName: ->
    'PADB.PixelDailies.Theme.forDateRange'

  # Returns all events for a specific day.
  getEvents: (dayDate) ->
    # Return all themes that were posted on that date.
    query =
      hashtags:
        $exists: true

    dateRange = new AE.DateRange
      year: dayDate.getFullYear()
      month: dayDate.getMonth()
      day: dayDate.getDate()

    dateRange.addToMongoQuery query, 'time'

    PADB.PixelDailies.Theme.documents.find query,
      fields:
        tweetData: 0
