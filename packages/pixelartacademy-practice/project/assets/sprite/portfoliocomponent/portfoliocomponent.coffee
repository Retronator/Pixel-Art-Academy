AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite.PortfolioComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.PortfolioComponent'

  constructor: (@sprite) ->
    super arguments...

  spriteStyle: ->
    assetData = @parentDataWith 'scale'
    scale = assetData.scale()
  
    style =
      width: "#{@sprite.width() * scale}rem"
      height: "#{@sprite.height() * scale}rem"
  
    if backgroundColor = @sprite.backgroundColor()
      style.backgroundColor = "##{backgroundColor.getHexString()}"
      style.borderColor = style.backgroundColor
  
    style

  spriteImage: ->
    return unless spriteId = @sprite.spriteId()
  
    new LOI.Assets.Components.SpriteImage
      spriteId: => spriteId
      loadPalette: true
