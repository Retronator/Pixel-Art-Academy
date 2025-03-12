AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.PortfolioComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.PortfolioComponent'

  constructor: (@artworkAsset) ->
    super arguments...
  
  canvasBorderClass: ->
    return unless document = @artworkAsset.document()
    
    'canvas-border' if document.properties?.canvasBorder

  canvasStyle: ->
    assetData = @parentDataWith 'scale'
    scale = assetData.scale()
  
    style =
      width: "#{@artworkAsset.width() * scale}rem"
      height: "#{@artworkAsset.height() * scale}rem"
  
    style

  bitmapImage: ->
    return unless document = @artworkAsset.document()

    new LOI.Assets.Components.BitmapImage
      bitmapId: => document._id
      loadPalette: true
