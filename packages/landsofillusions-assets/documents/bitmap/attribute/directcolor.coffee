LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.DirectColor extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.DirectColor
  @arrayClass = Uint8Array
  @elementsPerPixel = 3
  @flagValue = 4

  getPixelAtIndex: (index) ->
    r: @array[index] / 255
    g: @array[index + 1] / 255
    b: @array[index + 2] / 255

  setPixelAtIndex: (index, value) ->
    @array[index] = value.r * 255
    @array[index + 1] = value.g * 255
    @array[index + 2] = value.b * 255
