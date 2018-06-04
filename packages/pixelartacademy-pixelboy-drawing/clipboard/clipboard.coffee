AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  constructor: (@drawing) ->
    super

  editorActive: ->
    @drawing.editor().active()

  asset: ->
    @drawing.portfolio().displayedAsset()?.asset

  editAsset: ->
    AB.Router.setParameter 'parameter4', 'edit'

  spritePlaceholderStyle: ->
    return unless @isRendered()

    editor = @drawing.editor()
    return unless spriteData = editor.spriteData()
    return unless assetData = @drawing.portfolio().displayedAsset()

    scale = assetData.scale()
    clipboardScale = scale * 1.2

    width = spriteData.bounds.width * clipboardScale
    height = spriteData.bounds.height * clipboardScale

    # Add one pixel to the size for outer grid line.
    displayScale = LOI.adventure.interface.display.scale()
    pixelInRem = 1 / displayScale

    # Border should be 6rem when camera scale matches the default sprite scale.
    borderWidth = 6 / scale * clipboardScale

    width: "#{width + pixelInRem + 2 * borderWidth}rem"
    height: "#{height + pixelInRem + 2 * borderWidth}rem"
