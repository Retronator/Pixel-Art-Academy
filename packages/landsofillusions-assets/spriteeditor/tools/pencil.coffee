AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Pencil extends LOI.Assets.SpriteEditor.Tools.Stroke
  # paintNormals: boolean whether only normals are being painted
  # ignoreNormals: boolean whether normals are not painted
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Pencil'
  @displayName: -> "Pencil"

  @initialize()

  createPixelsFromCoordinates: (coordinates) ->
    # Make sure we have paint at all.
    paint =
      directColor: @paintHelper.directColor()
      paletteColor: @paintHelper.paletteColor()
      materialIndex: @paintHelper.materialIndex()
    
    return [] unless paint.directColor or paint.paletteColor or paint.materialIndex?

    paint.normal = @paintHelper.normal().toObject()

    for coordinate in coordinates
      pixel = _.clone coordinate

      for property in ['normal', 'materialIndex', 'paletteColor', 'directColor']
        pixel[property] = paint[property] if paint[property]?
        
      pixel

  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # See if we're only painting normals.
    paintNormals = @data.get 'paintNormals'
    ignoreNormals = @data.get 'ignoreNormals'

    changedPixels = _.filter relativePixels, (pixel) =>
      existingPixel = assetData.getPixelForLayerAtCoordinates layerIndex, pixel.x, pixel.y
  
      if paintNormals and existingPixel
        # Get the color from the existing pixel.
        for property in ['materialIndex', 'paletteColor', 'directColor']
          pixel[property] = existingPixel[property] if existingPixel[property]?

      if ignoreNormals and existingPixel
        # Get the normal from the existing pixel.
        pixel.normal = existingPixel.normal if existingPixel.normal?
      
      # We need to add this pixel unless one just like it is already there.
      not EJSON.equals existingPixel, pixel

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
        addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer null, assetData, []
        LOI.Assets.Bitmap.executePartialAction LOI.Assets.Bitmap.className, assetData._id, addLayerAction
        @_action.append addLayerAction

      # Create the stroke action.
      action = new LOI.Assets.Bitmap.Actions.Stroke null, assetData, layerAddress, changedPixels
      LOI.Assets.Bitmap.executePartialAction LOI.Assets.Bitmap.className, assetData._id, action
      @_action.append action
  
      # Optimize the partial stroke operations.
      @_action.optimizeOperations assetData
      
  endStroke: (assetData) ->
    # When the stroke ends, we need to execute the whole action as well.
    if assetData instanceof LOI.Assets.Bitmap
      assetData.executeAction @_action

      @_action = null
