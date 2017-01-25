AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Top2016.Layout extends BlazeLayoutComponent
  @register 'PixelArtDatabase.PixelDailies.Pages.Top2016.Layout'

  onCreated: ->
    super

    document.title = "Retronator // 2016 Pixel Dailies Retrospective"
    
    @display = new AM.Display
      safeAreaWidth: 350
      safeAreaHeight: 350
      minScale: 2

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
