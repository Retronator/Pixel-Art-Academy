LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.Normal extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.Normal
  @arrayClass = Int8Array
  @elementsPerPixel = 3

  getPixel: (x, y) ->
    @getPixelAtIndex @getPixelIndex x, y

  getPixelAtIndex: (index) ->
    result = {}
    @getPixelAtIndexToVector index, result
    result
    
  getPixelToVector: (x, y, vector) ->
    @getPixelAtIndexToVector @getPixelIndex(x, y), vector

  getPixelAtIndexToVector: (index, vector) ->
    vector.x = @signedData[index] / 127
    vector.y = @signedData[index + 1] / 127
    vector.z = @signedData[index + 2] / 127

  setPixel: (x, y, value) ->
    index = @getPixelIndex x, y

    @signedData[index] = Math.round value.x * 127
    @signedData[index + 1] = Math.round value.y * 127
    @signedData[index + 2] = Math.round value.z * 127
