LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.OperationMask extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.OperationMask
  @arrayClass = Uint8Array
  @elementsPerPixel = 1

  pixelWasChanged: (x, y, value) ->
    @pixelWasChangedAtIndex @getPixelIndex(x, y), value

  pixelWasChangedAtIndex: (index, value) ->
    if value?
      @array[index] = if value then 255 else 0

    @array[index] > 0
