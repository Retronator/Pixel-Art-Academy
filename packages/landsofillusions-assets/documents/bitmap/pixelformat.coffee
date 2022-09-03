LOI = LandsOfIllusions

class LOI.Assets.Bitmap.PixelFormat extends Array
  getBytesPerPixel: ->
    _.sumBy @, (attributeId) ->
      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId attributeId
      attributeClass.elementsPerPixel * attributeClass.arrayClass.BYTES_PER_ELEMENT

  getOffsetForAttribute: (attributeId, pixelsCount) ->
    offset = 0

    for formatAttributeId in @
      return offset if formatAttributeId is attributeId

      attributeClass = LOI.Assets.Bitmap.Attribute.getClassForId formatAttributeId
      offset += pixelsCount * attributeClass.elementsPerPixel * attributeClass.arrayClass.BYTES_PER_ELEMENT

  # Utility

  @typeName: -> "LandsOfIllusions.Assets.Bitmap.PixelFormat"
  typeName: -> @constructor.typeName()

  toJSONValue: -> [@...]

  @equals: (a, b) ->
    console.log "equals called", a, b
    return false unless a and b
    return false unless a.length is b.length
    for index in [0...a.length]
      return false unless a[index] is b[index]

    true

  equals: (other) ->
    @constructor.equals @, other

  EJSON.addType @typeName(), (json) => new @ json...
