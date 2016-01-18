AE = Artificial.Everywhere
PAA = PixelArtAcademy

# Abstract class for providing a set of items to display in the calendar app.
class PAA.Apps.Calendar.Provider
  constructor: ->
    @_monthSubscriptions = {}

  # Returns all events for a specific day.
  getEvents: (dayDate) ->
    # Not implemented.

  subscriptionName: ->
    # Not implemented

  subscribeToMonthOf: (date, calendar) ->
    # See if we're already subscribed to this month's date range.
    dateValue = date.valueOf()
    return if @_monthSubscriptions[dateValue]

    dateRange = new AE.DateRange
      year: date.getFullYear()
      month: date.getMonth()

    @_monthSubscriptions[dateValue] = calendar.subscribe @subscriptionName(), dateRange
