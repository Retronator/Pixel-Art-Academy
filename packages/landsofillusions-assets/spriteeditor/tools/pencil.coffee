AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Pencil extends LOI.Assets.SpriteEditor.Tools.AliasedStroke
  # paintNormals: boolean whether only normals are being painted
  # ignoreNormals: boolean whether normals are not painted
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Pencil'
  @displayName: -> "Pencil"

  @initialize()
  
  createPixelsFromStrokeMask: (assetData, strokeMask) ->
    # Make sure we have paint at all.
    paint =
      directColor: @paintHelper.directColor()
      paletteColor: @paintHelper.paletteColor()
      materialIndex: @paintHelper.materialIndex()
      
    return [] unless paint.directColor or paint.paletteColor or paint.materialIndex?

    paint.normal = @paintHelper.normal().toObject()
    paint.alpha = @paintHelper.opacity()
  
    pixels = []
    
    for x in [0...assetData.bounds.width]
      for y in [0...assetData.bounds.height]
        maskIndex = x + y * assetData.bounds.width
        continue unless strokeMask[maskIndex]
        
        pixel =
          x: x + assetData.bounds.left
          y: y + assetData.bounds.top
  
        pixels.push pixel
      
    for property in ['normal', 'materialIndex', 'paletteColor', 'directColor', 'alpha'] when paint[property]?
      pixel[property] = paint[property] for pixel in pixels
    
    pixels

  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # See if we're only painting normals.
    paintNormals = @data.get 'paintNormals'
    ignoreNormals = @data.get 'ignoreNormals'

    changedPixels = _.filter relativePixels, (pixel) =>
      return true unless existingPixel = assetData.getPixelForLayerAtCoordinates layerIndex, pixel.x, pixel.y
  
      if paintNormals and existingPixel
        # Get the color from the existing pixel.
        for property in ['materialIndex', 'paletteColor', 'directColor']
          pixel[property] = existingPixel[property] if existingPixel[property]?

      if ignoreNormals and existingPixel
        # Get the normal from the existing pixel.
        pixel.normal = existingPixel.normal if existingPixel.normal?
      
      # We need to add this pixel unless one just like it is already there.
      for property in ['materialIndex', 'paletteColor', 'directColor']
        continue unless pixel[property]? or existingPixel[property]?
        return true if pixel[property]? isnt existingPixel[property]?
        return true unless EJSON.equals pixel[property], existingPixel[property]
        
      false

    return unless changedPixels.length

    if assetData instanceof LOI.Assets.Sprite
      LOI.Assets.Sprite.addPixels assetData._id, layerIndex, changedPixels, not strokeStarted

      # Register that we've processed the start of the stroke.
      @startOfStrokeProcessed()

    else if assetData instanceof LOI.Assets.Bitmap
      layerAddress = [layerIndex]

      # When the stroke starts, we need to prepare the final action, since it will be executed partially.
      if strokeStarted
        @_action = new AM.Document.Versioning.Action @constructor.id()
        @startOfStrokeProcessed()

      # If the image has no layer, we first have to add it as a partial action.
      unless assetData.getLayer layerAddress
        addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer @constructor.id(), assetData, []
        AM.Document.Versioning.executePartialAction assetData, addLayerAction
        @_action.append addLayerAction

      # Create the stroke action.
      action = new LOI.Assets.Bitmap.Actions.Stroke @constructor.id(), assetData, layerAddress, changedPixels, true
      AM.Document.Versioning.executePartialAction assetData, action
      @_action.append action
  
      # Optimize the partial stroke operations.
      @_action.optimizeOperations assetData
      
  endStroke: (assetData) ->
    # When the stroke ends, we need to execute the whole action as well.
    if assetData instanceof LOI.Assets.Bitmap
      return unless @_action
      
      assetData.executeAction @_action

      @_action = null
