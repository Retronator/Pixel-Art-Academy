AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Layout extends BlazeLayoutComponent
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Layout'

  @image: (parameters) ->
    Meteor.absoluteUrl "pixelartdatabase/pixeldailies/yearreview/years/#{parameters.year}.png"

  onCreated: ->
    super

    @display = new AM.Display
      safeAreaWidth: 350
      safeAreaHeight: 350
      minScale: 2

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
