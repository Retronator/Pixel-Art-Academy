AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.CheckInsCalendarProvider extends LOI.PixelBoy.Apps.Calendar.Provider
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

    # Only grab a list of check-in ids to prevent reactive updates of the whole array on check-in changes.
    checkIns = PAA.Practice.CheckIn.documents.find query,
      fields:
        _id: 1
      sort:
        time: -1

    # Return the array of components (+ data contexts) that will render the events.
    for checkIn in checkIns.fetch()
      do (checkIn) ->
        component: new PAA.Practice.CheckInCalendarComponent()
        dataContext: -> PAA.Practice.CheckIn.documents.findOne checkIn._id
