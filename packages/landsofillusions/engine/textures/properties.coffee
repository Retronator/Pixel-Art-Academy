LOI = LandsOfIllusions

class LOI.Engine.Textures.Properties extends THREE.DataTexture
  constructor: (type) ->
    textureData = new Float32Array type.maxItems * type.maxProperties
    super textureData, type.maxItems, type.maxProperties, THREE.AlphaFormat, THREE.FloatType

  _writeToData: (itemIndex, propertyIndex, value) ->
    if _.isBoolean value
      # Convert boolean to float.
      value = if value then 1 else 0

    dataIndex = itemIndex + propertyIndex * @constructor.maxItems
    @image.data[dataIndex] = value ? 0
