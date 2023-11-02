LOI = LandsOfIllusions

class LOI.Assets.Engine.PixelImage.Sprite extends LOI.Assets.Engine.PixelImage
  constructor: (@options) ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless spriteData = @options.asset()
      return unless spriteData.layers?.length and spriteData.bounds
      return unless spriteData.customPalette or spriteData.allPalettesAvailable() or @options.visualizeNormals?()

      true
      
  drawToContext: (context, renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.asset()
    super arguments...

  getImageData: (renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.asset()
    super arguments...

  getCanvas: (renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.asset()
    super arguments...
    
  _render: (renderOptions) ->
    return unless spriteData = @options.asset()
    return unless spriteData instanceof LOI.Assets.Sprite

    # On the server we need to manually request pixel maps.
    spriteData.requirePixelMaps() if Meteor.isServer
    
    @_startRender spriteData, renderOptions

    for layer in spriteData.layers when layer?.pixels and layer.visible isnt false
      layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0
        z: layer.origin?.z or 0

      for pixel in layer.pixels
        # Find pixel index in the image buffer.
        x = pixel.x + layerOrigin.x - spriteData.bounds.x
        y = pixel.y + layerOrigin.y - spriteData.bounds.y
        z = layerOrigin.z + (pixel.z or 0)
        
        if renderOptions.shaded
          @_renderPixelShaded x, y, z, pixel.x, pixel.y, pixel.paletteColor, pixel.directColor, pixel.materialIndex, pixel.normal, spriteData, renderOptions
          
        else
          paletteColorRamp = pixel.paletteColor?.ramp
          paletteColorShade = pixel.paletteColor?.shade
          
          if pixel.directColor
            directColorR = pixel.directColor.r * 255
            directColorG = pixel.directColor.g * 255
            directColorB = pixel.directColor.b * 255
          
          @_renderPixel x, y, paletteColorRamp, paletteColorShade, directColorR, directColorG, directColorB, 255

    @_endRender()
