AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Layout extends BlazeLayoutComponent
  @register 'LandsOfIllusions.Assets.Layout'

  @image: (parameters) ->
    # TODO: Add image thumbnail.

  onCreated: ->
    super

    @display = new AM.Display
      safeAreaWidth: 350
      safeAreaHeight: 350
      minScale: 2

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
