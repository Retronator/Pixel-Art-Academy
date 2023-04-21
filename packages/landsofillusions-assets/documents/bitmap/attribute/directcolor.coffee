LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.DirectColor extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.DirectColor
  @arrayClass = Uint8Array
  @elementsPerPixel = 3
  @flagValue = 4

  getPixel: (x, y) ->
    index = @getPixelIndex x, y

    r: @array[index] / 255
    g: @array[index + 1] / 255
    b: @array[index + 2] / 255

  setPixel: (x, y, value) ->
    index = @getPixelIndex x, y

    @array[index] = value.r * 255
    @array[index + 1] = value.g * 255
    @array[index + 2] = value.b * 255
