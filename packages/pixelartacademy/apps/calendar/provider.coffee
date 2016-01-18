PAA = PixelArtAcademy

# Abstract class for providing a set of items to display in the calendar app.
class PAA.Apps.Calendar.Provider
  constructor: ->
    @_subscriptions = []
