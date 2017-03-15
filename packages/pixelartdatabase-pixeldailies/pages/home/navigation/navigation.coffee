AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Home.Navigation extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Home.Navigation'

  routeParameters: ->
    year: FlowRouter.getParam 'year'
