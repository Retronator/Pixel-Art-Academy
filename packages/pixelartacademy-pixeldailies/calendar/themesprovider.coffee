AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelDailies.ThemesCalendarProvider extends PAA.PixelBoy.Apps.Calendar.Provider
  @calendarComponentClass: ->
    PAA.PixelDailies.ThemeCalendarComponent

  constructor: ->
    super

  subscriptionName: ->
    'PAA.PixelDailies.Theme.forDateRange'

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

    query = dateRange.addToMongoQuery query, 'time'

    PAA.PixelDailies.Theme.documents.find query,
      fields:
        tweetData: 0
