AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorFill extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ColorFill'
  @displayName: -> "Color fill"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    return unless @mouseState.leftButton

    # Make sure we have paint at all.
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    paint =
      directColor: paintHelper.directColor()
      paletteColor: paintHelper.paletteColor()
      materialIndex: paintHelper.materialIndex()

    return [] unless paint.directColor or paint.paletteColor or paint.materialIndex?

    paint.normal = paintHelper.normal().toObject()

    assetData = @editor().assetData()
    layerIndex = paintHelper.layerIndex()
    layer = assetData.layers?[layerIndex]

    xCoordinates = [@mouseState.x]

    # TODO: Get symmetry from interface data.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()

    if symmetryXOrigin?
      mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push mirroredX

    layerOrigin =
      x: layer?.origin?.x or 0
      y: layer?.origin?.y or 0

    ignoreNormals = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).get('ignoreNormals') or false
    
    if assetData instanceof LOI.Assets.Bitmap
      # Prepare the action.
      layerAddress = [layerIndex]
      
      action = new AM.Document.Versioning.Action @constructor.id()
      
      # If the image has no layer, we first have to add it as a partial action.
      unless assetData.getLayer layerAddress
        addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer null, assetData, []
        action.append addLayerAction

    for xCoordinate in xCoordinates
      # Make sure we're filling inside of bounds.
      continue unless assetData.bounds.left <= xCoordinate <= assetData.bounds.right and assetData.bounds.top <= @mouseState.y <= assetData.bounds.bottom

      pixel =
        x: xCoordinate - layerOrigin.x
        y: @mouseState.y - layerOrigin.y

      for property in ['materialIndex', 'paletteColor', 'directColor']
        pixel[property] = paint[property] if paint[property]?

      pixel.normal = paint.normal if paint.normal and not ignoreNormals
    
      if assetData instanceof LOI.Assets.Sprite
        LOI.Assets.Sprite.colorFill assetData._id, layerIndex, pixel, ignoreNormals
      
      else if assetData instanceof LOI.Assets.Bitmap
        # Add the fill action.
        colorFillAction = new LOI.Assets.Bitmap.Actions.ColorFill null, assetData, layerAddress, pixel
        action.append colorFillAction

    if assetData instanceof LOI.Assets.Bitmap
      # Optimize the operations (for the symmetry case) and execute the action.
      action.optimizeOperations assetData

      AM.Document.Versioning.executeAction assetData, assetData.lastEditTime or assetData.creationTime, action, new Date
