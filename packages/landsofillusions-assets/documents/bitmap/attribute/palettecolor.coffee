LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.PaletteColor extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.PaletteColor
  @arrayClass = Uint8Array
  @elementsPerPixel = 2
  @flagValue = 2

  getPixel: (x, y) ->
    index = @getPixelIndex x, y

    ramp: @array[index]
    shade: @array[index + 1]

  setPixel: (x, y, value) ->
    index = @getPixelIndex x, y

    @array[index] = value.ramp
    @array[index + 1] = value.shade
