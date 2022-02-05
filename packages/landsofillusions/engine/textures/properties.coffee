LOI = LandsOfIllusions

class LOI.Engine.Textures.Properties extends THREE.DataTexture
  constructor: (type) ->
    textureData = new Float32Array type.maxItems * type.maxProperties * 4
    super textureData, type.maxItems, type.maxProperties, THREE.RGBAFormat, THREE.FloatType

  _writeToData: (itemIndex, propertyIndex, values...) ->
    if _.isBoolean values[0]
      # Convert booleans to floats.
      for value, index in values
        values[index] = if value then 1 else 0

    dataIndex = (itemIndex + propertyIndex * @constructor.maxItems) * 4

    for value, offset in values
      @image.data[dataIndex + offset] = value ? 0
