AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Abstract class for providing a set of items to display in the calendar app.
class PAA.PixelBoy.Apps.Calendar.Provider
  @calendarComponentClass: ->
    throw new AE.NotImplementedException

  constructor: ->
    @_monthSubscriptions = {}

  # Returns an array of events for a specific day. Event is an object with
  # component: component instance that will render the event
  # dataContext: the data context to be provided to the component
  getEvents: (dayDate) ->
    throw new AE.NotImplementedException

  subscriptionName: ->
    throw new AE.NotImplementedException

  subscribeToMonthOf: (date, calendar) ->
    # See if we're already subscribed to this month's date range.
    dateValue = date.valueOf()
    return if @_monthSubscriptions[dateValue]

    dateRange = new AE.DateRange
      year: date.getFullYear()
      month: date.getMonth()

    @_monthSubscriptions[dateValue] = calendar.subscribe @subscriptionName(), dateRange
