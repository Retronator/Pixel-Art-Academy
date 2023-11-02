AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.PortfolioComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.PortfolioComponent'

  constructor: (@artworkAsset) ->
    super arguments...
  
  documentClassNameClass: ->
    return unless document = @artworkAsset.document()
    
    _.kebabCase document.constructor.className

  canvasStyle: ->
    assetData = @parentDataWith 'scale'
    scale = assetData.scale()
  
    style =
      width: "#{@artworkAsset.width() * scale}rem"
      height: "#{@artworkAsset.height() * scale}rem"
  
    style

  pixelImage: ->
    return unless document = @artworkAsset.document()

    if document instanceof LOI.Assets.Sprite
      new LOI.Assets.Components.SpriteImage
        spriteId: => document._id
        loadPalette: true
  
    else if document instanceof LOI.Assets.Bitmap
      new LOI.Assets.Components.BitmapImage
        bitmapId: => document._id
        loadPalette: true
