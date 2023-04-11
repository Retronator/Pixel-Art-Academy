AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Bitmap.PortfolioComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Bitmap.PortfolioComponent'

  constructor: (@bitmap) ->
    super arguments...

  bitmapStyle: ->
    assetData = @parentDataWith 'scale'
    scale = assetData.scale()
  
    style =
      width: "#{@bitmap.width() * scale}rem"
      height: "#{@bitmap.height() * scale}rem"
  
    if backgroundColor = @bitmap.backgroundColor()
      style.backgroundColor = "##{backgroundColor.getHexString()}"
      style.borderColor = style.backgroundColor
  
    style

  bitmapImage: ->
    return unless bitmapId = @bitmap.bitmapId()
  
    new LOI.Assets.Components.BitmapImage
      bitmapId: => bitmapId
      loadPalette: true
