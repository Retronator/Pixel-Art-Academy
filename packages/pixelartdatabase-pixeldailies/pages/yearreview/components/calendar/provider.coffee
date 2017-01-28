AE = Artificial.Everywhere
LOI = LandsOfIllusions
PADB = PixelArtDatabase

# Abstract class for providing a set of submissions to the calendar component.
class PADB.PixelDailies.Pages.YearReview.Components.Calendar.Provider
  constructor: ->
    @limit = new ReactiveField 0

    # Child implementation should store subscription handle here.
    @subscriptionHandle = new ReactiveField null

  ready: ->
    @subscriptionHandle()?.ready()

  submissions: ->
    throw new AE.NotImplementedException
