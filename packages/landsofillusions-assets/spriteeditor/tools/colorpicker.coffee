AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorPicker extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ColorPicker'
  @displayName: -> "Color picker"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @pickColor()

  onMouseMove: (event) ->
    super arguments...

    @pickColor()

  pickColor: ->
    return unless @mouseState.leftButton

    spriteData = @editor().spriteData()    
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    # Go over all pixels to find the one we want.
    for layer in spriteData.layers when layer?.pixels and layer.visible isnt false
      layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0
        z: layer.origin?.z or 0

      for pixel in layer.pixels
        if pixel.x + layerOrigin.x is @mouseState.x and pixel.y + layerOrigin.y is @mouseState.y
          pixelDepth = (pixel.z or 0) + layerOrigin.z

          if not topPixel or pixelDepth >= topPixelDepth
            topPixel = pixel
            topPixelDepth = pixelDepth

    return unless topPixel

    if topPixel.paletteColor
      paintHelper.setPaletteColor topPixel.paletteColor

    else if topPixel.directColor
      paintHelper.setDirectColor topPixel.directColor

    else if topPixel.materialIndex?
      paintHelper.setMaterialIndex topPixel.materialIndex

    if topPixel.normal
      paintHelper.setNormal topPixel.normal
