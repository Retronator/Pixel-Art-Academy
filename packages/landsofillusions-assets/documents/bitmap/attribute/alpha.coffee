LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.Alpha extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.Alpha
  @arrayClass = Uint8Array
  @elementsPerPixel = 1

  getPixelAtIndex: (index) ->
    @array[index] / 255

  setPixelAtIndex: (index, value) ->
    @array[index] = value * 255
