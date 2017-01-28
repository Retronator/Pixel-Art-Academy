AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Navigation extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Navigation'

  routeParameters: ->
    year: FlowRouter.getParam 'year'
