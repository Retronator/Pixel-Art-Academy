AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.HardEraser extends LOI.Assets.SpriteEditor.Tools.AliasedStroke
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.HardEraser'
  @displayName: -> "Eraser"

  @initialize()

  createPixelsFromCoordinates: (coordinates) ->
    for coordinate in coordinates
      pixel = _.clone coordinate

      # Set direct color to color of the background to fake erasing.
      pixel.directColor = r: 0.34, g: 0.34, b: 0.34

      pixel

  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    changedPixels = for pixel in relativePixels when assetData.getPixelForLayerAtCoordinates layerIndex, pixel.x, pixel.y
      # We must send only the coordinates to the server.
      _.pick pixel, ['x', 'y']

    return unless changedPixels.length
  
    if assetData instanceof LOI.Assets.Sprite
      LOI.Assets.Sprite.removePixels assetData._id, layerIndex, changedPixels, not strokeStarted
  
      # Register that we've processed the start of the stroke.
      @startOfStrokeProcessed()
      
    else if assetData instanceof LOI.Assets.Bitmap
      layerAddress = [layerIndex]
  
      # When the stroke starts, we need to prepare the final action, since it will be executed partially.
      if strokeStarted
        @_action = new AM.Document.Versioning.Action @constructor.id()
        @startOfStrokeProcessed()
    
      # Create the stroke action.
      action = new LOI.Assets.Bitmap.Actions.Stroke null, assetData, layerAddress, changedPixels
      LOI.Assets.Bitmap.executePartialAction LOI.Assets.Bitmap.className, assetData._id, action
      @_action.append action

      # Optimize the partial stroke operations.
      @_action.optimizeOperations assetData

  endStroke: (assetData) ->
    # When the stroke ends, we need to execute the whole action as well.
    if assetData instanceof LOI.Assets.Bitmap
      LOI.Assets.Bitmap.executeAction LOI.Assets.Bitmap.className, assetData._id, assetData.lastEditTime or assetData.creationTime, @_action, new Date, (error, result) ->
        AM.Document.Versioning.reportExecuteActionError assetData if error
    
      @_action = null
