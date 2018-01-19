AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

Calendar = PAA.PixelBoy.Apps.Calendar

class Calendar.Providers.PixelDailies.ThemesProvider extends Calendar.Provider
  @calendarComponentClass: ->
    Calendar.Providers.PixelDailies.ThemeComponent

  @id: -> 'Calendar.Providers.PixelDailies.ThemesProvider'
  @displayName: -> "Pixel Dailies"

  constructor: ->
    super

  subscriptionName: ->
    'PixelArtDatabase.PixelDailies.Theme.forDateRange'

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
