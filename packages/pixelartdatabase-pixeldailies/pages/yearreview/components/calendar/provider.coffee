AE = Artificial.Everywhere
LOI = LandsOfIllusions
PADB = PixelArtDatabase

# Abstract class for providing a set of submissions to the calendar component.
class PADB.PixelDailies.Pages.YearReview.Components.Calendar.Provider
  constructor: ->
    @limit = new ReactiveField 0

  submissions: ->
    throw new AE.NotImplementedException
