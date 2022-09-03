LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Layer extends LOI.Assets.Bitmap.Area
  # name: name of the layer
  # visible: boolean if this layer should be drawn
  # blendMode: name of one of the blend modes
  # bounds: location of this layer's origin (0,0) in the sprite.
  #   x, y: absolute pixel coordinates of the top-left pixel of this layer
  #   width, height: the size of the layer in pixels
  # compressedPixelsData: binary object with compressed version of vertices, sent to the server

  constructor: (bitmap, parent, properties) ->
    super properties.bounds?.width, properties.bounds?.height, bitmap.pixelFormat, properties.compressedPixelsData, true

    console.log "layer area created", @

    # We set ancestors here since we can't use @ in the call to super.
    @bitmap = bitmap
    @parent = parent

    # Transfer provided properties and apply defaults.
    _.defaults @, properties,
      name: "New layer"
      visible: true
      blendMode: LOI.Assets.Bitmap.BlendModes.Normal

    console.log "layer created", @

  toPlainObject: ->
    plainObject = _.pick @, ['name', 'visible', 'blendMode']
    plainObject.bounds = _.pick @bounds, ['x', 'y', 'width', 'height']
    plainObject.compressedPixelsData = @getCompressedPixelsData()
    plainObject

  getAddress: ->
    [@parent.getAddress..., @parent.layers.indexOf @]
