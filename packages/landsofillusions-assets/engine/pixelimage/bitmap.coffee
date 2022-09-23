LOI = LandsOfIllusions

_paletteColor = ramp: 0, shade: 0
_directColor = new THREE.Color
_normal = new THREE.Vector3

class LOI.Assets.Engine.PixelImage.Bitmap extends LOI.Assets.Engine.PixelImage
  constructor: (@options) ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless bitmapData = @options.asset()
      return unless (bitmapData.layers?.length or bitmapData.layerGroups?.length) and bitmapData.bounds
      return unless bitmapData.customPalette or LOI.Assets.Palette.documents.findOne(bitmapData.palette?._id) or @options.visualizeNormals?()

      true
    
  _render: (renderOptions) ->
    return unless bitmapData = @options.asset()

    @_startRender bitmapData, renderOptions
    @_renderLayerGroup bitmapData, bitmapData, renderOptions
    @_endRender()
 
  _renderLayerGroup: (layerGroup, bitmapData, renderOptions) ->
    # Render all sub groups.
    for subGroup in layerGroup.layerGroups when subGroup.visible isnt false
      @_renderLayerGroup subGroup, renderOptions
    
    # Render all the layers.
    for layer in layerGroup.layers when layer.visible isnt false
      for layerX in [0...layer.bounds.width]
        for layerY in [0...layer.bounds.height]
          flagIndex = layer.attributes.flags.getPixelIndex layerX, layerY
          
          # See if the pixel exists at these coordinates.
          continue unless layer.attributes.flags.pixelExistsAtIndex flagIndex
          
          absoluteX = layer.bounds.x + layerX
          absoluteY = layer.bounds.y + layerY
          
          assetX = absoluteX - bitmapData.bounds.x
          assetY = absoluteY - bitmapData.bounds.y
          
          if layer.attributes.paletteColor
            paletteColorIndex = flagIndex * 2
            _paletteColor.ramp = layer.attributes.paletteColor.array[paletteColorIndex]
            _paletteColor.shade = layer.attributes.paletteColor.array[paletteColorIndex + 1]
            paletteColor = _paletteColor
            
          else
            paletteColor = null
            
          if layer.attributes.directColor
            directColorIndex = flagIndex * 3
            _directColor.r = layer.attributes.directColor.array[directColorIndex] / 255
            _directColor.g = layer.attributes.directColor.array[directColorIndex + 1] / 255
            _directColor.b = layer.attributes.directColor.array[directColorIndex + 2] / 255
            directColor = _directColor
            
          else
            directColor = null
            
          materialIndex = layer.attributes.materialIndex?.array[flagIndex]
          
          if layer.attributes.normal
            normalIndex = flagIndex * 3
            layer.attributes.normal.getPixelAtIndexToVector normalIndex, _normal
            normal = _normal
            
          else
            normal = null
            
          @_renderPixel assetX, assetY, 0, absoluteX, absoluteY, paletteColor, directColor, materialIndex, normal, bitmapData, renderOptions
          
    # Optimization: Explicit return to not collect results of for loops.
    return
