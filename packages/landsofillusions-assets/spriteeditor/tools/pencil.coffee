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
  
  @calculateChangedPixels: (assetData, layerIndex, relativePixels, paintNormals, ignoreNormals) ->
    _.filter relativePixels, (pixel) =>
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
  
  # Adds and executes partial actions that will apply the relative pixels to the asset.
  @applyPixels: (assetData, action, layerIndex, relativePixels, paintNormals, ignoreNormals) ->
    changedPixels = @calculateChangedPixels assetData, layerIndex, relativePixels, paintNormals, ignoreNormals
    return unless changedPixels.length

    layerAddress = [layerIndex]

    # If the image has no layer, we first have to add it as a partial action.
    unless assetData.getLayer layerAddress
      addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer action.operatorId, assetData, []
      AM.Document.Versioning.executePartialAction assetData, addLayerAction
      action.append addLayerAction

    # Create the stroke action.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke action.operatorId, assetData, layerAddress, changedPixels, true
    AM.Document.Versioning.executePartialAction assetData, strokeAction
    action.append strokeAction

    # Optimize the partial stroke operations.
    action.optimizeOperations assetData

  @createPixelsFromStrokeMask: (assetData, strokeMask) ->
    pixels = []
    
    for x in [0...assetData.bounds.width]
      for y in [0...assetData.bounds.height]
        continue unless strokeMask.isPixelInMask x, y
        
        pixel =
          x: x + assetData.bounds.left
          y: y + assetData.bounds.top
  
        pixels.push pixel
      
    pixels

  createPixelsFromStrokeMask: (assetData, strokeMask) ->
    # Make sure we have paint at all.
    return [] unless @paintHelper.isPaintSet()
    
    pixels = @constructor.createPixelsFromStrokeMask assetData, strokeMask
    @paintHelper.applyPaintToPixels pixels
    
    pixels

  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # See if we're only painting normals.
    paintNormals = @data.get 'paintNormals'
    ignoreNormals = @data.get 'ignoreNormals'

    if assetData instanceof LOI.Assets.Sprite
      changedPixels = @constructor.calculateChangedPixels assetData, layerIndex, relativePixels, paintNormals, ignoreNormals
      LOI.Assets.Sprite.addPixels assetData._id, layerIndex, changedPixels, not strokeStarted

      # Register that we've processed the start of the stroke.
      @startOfStrokeProcessed()

    else if assetData instanceof LOI.Assets.Bitmap
      # When the stroke starts, we need to prepare the final action, since it will be executed partially.
      if strokeStarted
        @_action = new AM.Document.Versioning.Action @constructor.id()
        @startOfStrokeProcessed()

      @constructor.applyPixels assetData, @_action, layerIndex, relativePixels, paintNormals, ignoreNormals
      
  endStroke: (assetData) ->
    # When the stroke ends, we need to execute the whole action as well.
    if assetData instanceof LOI.Assets.Bitmap
      return unless @_action
      
      assetData.executeAction @_action

      @_action = null
