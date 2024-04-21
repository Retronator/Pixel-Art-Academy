LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.PaletteColor extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.PaletteColor
  @arrayClass = Uint8Array
  @elementsPerPixel = 2
  @flagValue = 2

  getPixelAtIndex: (index) ->
    ramp: @array[index]
    shade: @array[index + 1]

  setPixelAtIndex: (index, value) ->
    @array[index] = value.ramp
    @array[index + 1] = value.shade
