LOI = LandsOfIllusions
Attribute = LOI.Assets.Bitmap.Attribute

_paletteColor = ramp: 0, shade: 0
_directColor = new THREE.Color
_normal = new THREE.Vector3

class LOI.Assets.Engine.PixelImage.Bitmap extends LOI.Assets.Engine.PixelImage
  constructor: (@options) ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless bitmapData = @options.asset()
      return unless (bitmapData.layers?.length or bitmapData.layerGroups?.length) and bitmapData.bounds
      return unless bitmapData.customPalette or bitmapData.allPalettesAvailable() or @options.visualizeNormals?()

      true
    
  _render: (renderOptions) ->
    return unless bitmapData = @options.asset()
    return unless bitmapData instanceof LOI.Assets.Bitmap

    @_startRender bitmapData, renderOptions
    @_renderLayerGroup bitmapData, bitmapData, renderOptions
    @_endRender()
 
  _renderLayerGroup: (layerGroup, bitmapData, renderOptions) ->
    # Render all sub groups.
    for subGroup in layerGroup.layerGroups when subGroup.visible isnt false
      @_renderLayerGroup subGroup, renderOptions
    
    # Render all the layers.
    for layer in layerGroup.layers when layer.visible isnt false
      paletteColorArray = layer.attributes.paletteColor?.array
      directColorArray = layer.attributes.directColor?.array
      alphaArray = layer.attributes.alpha?.array
      flags = layer.attributes.flags
      
      for layerX in [0...layer.bounds.width]
        for layerY in [0...layer.bounds.height]
          flagIndex = flags.getPixelIndex layerX, layerY
          
          # See if the pixel exists at these coordinates.
          continue unless flags.pixelExistsAtIndex flagIndex
          
          absoluteX = layer.bounds.x + layerX
          absoluteY = layer.bounds.y + layerY
          
          assetX = absoluteX - bitmapData.bounds.x
          assetY = absoluteY - bitmapData.bounds.y
          
          if renderOptions.shaded
            if flags.pixelHasFlagAtIndex flagIndex, Attribute.PaletteColor.flagValue
              paletteColorIndex = flagIndex * 2
              _paletteColor.ramp = layer.attributes.paletteColor.array[paletteColorIndex]
              _paletteColor.shade = layer.attributes.paletteColor.array[paletteColorIndex + 1]
              paletteColor = _paletteColor
              
            else
              paletteColor = null
              
            if flags.pixelHasFlagAtIndex flagIndex, Attribute.DirectColor.flagValue
              directColorIndex = flagIndex * 3
              _directColor.r = layer.attributes.directColor.array[directColorIndex] / 255
              _directColor.g = layer.attributes.directColor.array[directColorIndex + 1] / 255
              _directColor.b = layer.attributes.directColor.array[directColorIndex + 2] / 255
              directColor = _directColor
              
            else
              directColor = null
    
            if flags.pixelHasFlagAtIndex flagIndex, Attribute.MaterialIndex.flagValue
              materialIndex = layer.attributes.materialIndex.array[flagIndex]
              
            else
              materialIndex = null
            
            if layer.attributes.normal
              normalIndex = flagIndex * 3
              layer.attributes.normal.getPixelAtIndexToVector normalIndex, _normal
              normal = _normal
              
            else
              normal = null
              
            @_renderPixelShaded assetX, assetY, 0, absoluteX, absoluteY, paletteColor, directColor, materialIndex, normal, bitmapData, renderOptions
            
          else
            if paletteColorArray
              paletteColorIndex = flagIndex * 2
              paletteColorRamp = paletteColorArray[paletteColorIndex]
              paletteColorShade = paletteColorArray[paletteColorIndex + 1]
              
            if directColorArray
              directColorIndex = flagIndex * 3
              directColorR = directColorArray[directColorIndex]
              directColorG = directColorArray[directColorIndex + 1]
              directColorB = directColorArray[directColorIndex + 2]
              
            if alphaArray
              alpha = alphaArray[flagIndex]
              
            @_renderPixel assetX, assetY, paletteColorRamp, paletteColorShade, directColorR, directColorG, directColorB, alpha
          
    # Optimization: Explicit return to not collect results of for loops.
    return
