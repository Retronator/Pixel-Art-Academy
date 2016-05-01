AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.Practice.CheckInsCalendarProvider extends PAA.PixelBoy.Apps.Calendar.Provider
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

    query = dateRange.addToMongoQuery query, 'time'

    checkIns = PAA.Practice.CheckIn.documents.find query,
      sort:
        time: -1

    # Return the array of components (+ data contexts) that will render the events.
    for checkIn in checkIns.fetch()
      component: new PAA.Practice.CheckInCalendarComponent()
      dataContext: checkIn
