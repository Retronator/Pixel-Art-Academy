AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Calendar = PAA.PixelBoy.Apps.Calendar

class Calendar.Providers.Practice.CheckInsProvider extends Calendar.Provider
  @calendarComponentClass: ->
    Calendar.Providers.Practice.CheckInComponent

  constructor: ->
    super

  subscriptionName: ->
    'PixelArtAcademy.Practice.CheckIn.forDateRange'

  # Returns all events for a specific day.
  getEvents: (dayDate) ->
    # Return all themes that were posted on that date.
    query = {}

    dateRange = new AE.DateRange
      year: dayDate.getFullYear()
      month: dayDate.getMonth()
      day: dayDate.getDate()

    dateRange.addToMongoQuery query, 'time'

    # Only grab a list of check-in ids to prevent reactive updates of the whole array on check-in changes.
    PAA.Practice.CheckIn.documents.find query,
      fields:
        _id: 1
      sort:
        time: -1
