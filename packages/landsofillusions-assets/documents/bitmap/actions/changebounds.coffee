AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Actions.ChangeBounds extends AM.Document.Versioning.Action
  constructor: (operatorId, bitmap, bounds) ->
    super arguments...

    # Forward operation changes bounds to desired values.
    forwardOperation = new LOI.Assets.Bitmap.Operations.ChangeBounds bounds: EJSON.clone bounds
    @forward.push forwardOperation
    
    # Backward operation changes bounds to desired values and fill in the missing information if necessary.
    backwardOperation = new LOI.Assets.Bitmap.Operations.ChangeBounds bounds: EJSON.clone bitmap.bounds
    @backward.push backwardOperation
    
    # Note: We have to specify width and height so that it's not calculated from left/right
    # since those in bounds are given in whole pixels instead of actual distances.
    oldRectangle = new AE.Rectangle bitmap.bounds.left, bitmap.bounds.top, bitmap.bounds.width, bitmap.bounds.height
    newRectangle = new AE.Rectangle bounds.left, bounds.top, bounds.right - bounds.left + 1, bounds.bottom - bounds.top + 1
    
    intersectionRectangle = AE.Rectangle.intersect oldRectangle, newRectangle
    
    # We need to copy previous pixel values unless we're simply expanding the bounds.
    # In that case, the intersection of the bounds will be the same as the old bounds.
    unless intersectionRectangle.equals oldRectangle
      pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, bitmap.pixelFormat.attributeIds...

      updateLayerGroupLayers = (group) =>
        updateLayerGroupLayers subGroup for subGroup in group.layerGroups
        
        for layer in group.layers
          backwardOperation = new LOI.Assets.Bitmap.Operations.ChangePixels
            layerAddress: layer.getAddress()
            bounds: layer.bounds
            
          # Create change area with current pixel data.
          area = new LOI.Assets.Bitmap.Area layer.width, layer.height, pixelFormat
          areaOperationMask = area.attributes[LOI.Assets.Bitmap.Attribute.Ids.OperationMask]
          
          sourceBounds =
            x: 0
            y: 0
            width: layer.width
            height: layer.height
          
          destinationPosition =
            x: 0
            y: 0
          
          area.copyPixels layer, sourceBounds, destinationPosition
          
          for y in [0...layer.height]
            for x in [0...layer.width]
              areaOperationMask.pixelWasChanged x, y, true
            
          backwardOperation.setPixelsData area.pixelsData
          @backward.push backwardOperation
        
      updateLayerGroupLayers bitmap

    @_updateHashCode()
