LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.Alpha extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.Alpha
  @arrayClass = Uint8Array
  @elementsPerPixel = 1

  getPixel: (x, y) ->
    index = @getPixelIndex x, y

    @array[index] / 255

  setPixel: (x, y, value) ->
    index = @getPixelIndex x, y

    @array[index] = value * 255
