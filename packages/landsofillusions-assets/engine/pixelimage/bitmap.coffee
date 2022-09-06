LOI = LandsOfIllusions

class LOI.Assets.Engine.PixelImage.Bitmap extends LOI.Assets.Engine.PixelImage
  constructor: (@options) ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless bitmapData = @options.asset()
      return unless (bitmapData.layers?.length or bitmapData.layerGroups?.length) and bitmapData.bounds
      return unless bitmapData.customPalette or LOI.Assets.Palette.documents.findOne(bitmapData.palette?._id) or @options.visualizeNormals?()

      true
  
    # Listen to bitmap changes.
    @_bitmapUpdatedDependency = new Tracker.Dependency
    
    LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, @onBitmapUpdated
    
  destroy: ->
    LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandler @, @onBitmapUpdated
    
  onBitmapUpdated: (bitmap, operation, changedFields) ->
    return unless bitmapData = @options.asset()
    return unless bitmap._id is bitmapData._id
  
    # Our bitmap changed, trigger a redraw.
    @_bitmapUpdatedDependency.changed()
    
  _render: (renderOptions) ->
    bitmapData = @options.asset()
    
    # React to bitmap changes.
    @_bitmapUpdatedDependency.depend()

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
          # See if the pixel exists at these coordinates.
          continue unless layer.attributes.flags.pixelExists layerX, layerY
          
          pixel = layer.getPixel layerX, layerY
          assetX = layer.bounds.x + layerX
          assetY = layer.bounds.y + layerY
          
          @_renderPixel assetX, assetY, 0, pixel, bitmapData, renderOptions
