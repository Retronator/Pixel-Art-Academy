LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.Alpha extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.Alpha
  @arrayClass = Uint8Array
  @elementsPerPixel = 1

  getPixel: (x, y) ->
    @getPixelAtIndex @getPixelIndex x, y
    
  getPixelAtIndex: (index) ->
    @array[index] / 255

  setPixel: (x, y, value) ->
    @setPixelAtIndex @getPixelIndex x, y
    
  setPixelAtIndex: (index, value) ->
    @array[index] = value * 255
