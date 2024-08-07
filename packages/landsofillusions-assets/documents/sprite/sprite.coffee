AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 2D pixel art asset.
class LOI.Assets.Sprite extends LOI.Assets.VisualAsset
  @id: -> 'LandsOfIllusions.Assets.Sprite'
  # layers: array of
  #   name: name of the layer
  #   visible: boolean if this layer should be drawn
  #   origin: location of this layer's origin (0,0) in the sprite.
  #     x, y: integer 2D location of the origin
  #     z: floating point depth of the origin
  #   pixels: array of
  #     x, y: integer 2D location of the pixel
  #     z: floating point depth of the pixel
  #     paletteColor: pixel color from the palette
  #       ramp
  #       shade
  #     directColor: directly specified color of the pixel
  #       r, g, b: (0.0-1.0)
  #     materialIndex: the index of the named color of the pixel
  #     normal: the direction of the surface that this pixel represents in right-handed 3D coordinates
  #       x, y, z
  # bounds: image bounds in pixels (or null if no pixels and not fixed bounds)
  #   left, right, top, bottom
  #   fixed: boolean whether to preserve the set bounds
  @Meta
    name: @id()

  @className: 'Sprite'

  # Subscriptions
  
  @allGeneric: @subscription 'allGeneric'
  @forMeshId: @subscription 'forMeshId'
  @forCharacterPartTemplatesOfTypes: @subscription 'forCharacterPartTemplatesOfTypes'

  # Methods
  
  @clear: @method 'clear'

  @addPixel: @method 'addPixel'
  @addPixels: @method 'addPixels'
  @removePixel: @method 'removePixel'
  @removePixels: @method 'removePixels'
  @smoothPixels: @method 'smoothPixels'
  @colorFill: @method 'colorFill'
  @replacePixels: @method 'replacePixels'
  @flipHorizontal: @method 'flipHorizontal'
  @resize: @method 'resize'

  @updateLayer: @method 'updateLayer'
  @removeLayer: @method 'removeLayer'
  
  @pixelPattern =
    x: Match.Integer
    y: Match.Integer
    paletteColor: Match.Optional
      ramp: Match.Integer
      shade: Match.Integer
    directColor: Match.Optional
      r: Number
      g: Number
      b: Number
    materialIndex: Match.Optional Match.Integer
    normal: Match.Optional
      x: Number
      y: Number
      z: Number
  
  @landmarkPattern =
    name: Match.OptionalOrNull String
    x: Match.OptionalOrNull Number
    y: Match.OptionalOrNull Number
    z: Match.OptionalOrNull Number

  @_limitLayerPixels = (newCount) ->
    # Allow up to 4,096 (64 * 64) pixels per layer.
    throw new AE.ArgumentOutOfRangeException "Up to 4,096 pixels per layer are allowed." if newCount > 4096

  constructor: ->
    super arguments...

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1
      
    # On the client also create pixel maps.
    @requirePixelMaps() if Meteor.isClient

  requirePixelMaps: ->
    return unless @layers?

    for layer in @layers when layer?.pixels
      continue if layer._pixelMap

      @_buildPixelMap layer

  rebuildPixelMaps: ->
    @_buildPixelMap layer for layer in @layers when layer?.pixels

  _buildPixelMap: (layer) ->
    layer._pixelMap = {}

    for pixel in layer.pixels
      layer._pixelMap[pixel.x] ?= {}
      layer._pixelMap[pixel.x][pixel.y] = pixel

  # Pixel retrieval
  
  getPixelForLayerAtCoordinates: (layerIndex, x, y) ->
    @layers?[layerIndex]?._pixelMap?[x]?[y]
  
  getPixelForLayerAtAbsoluteCoordinates: (layerIndex, absoluteX, absoluteY) ->
    return unless layer = @layers?[layerIndex]
    x = absoluteX - (layer.origin?.x or 0)
    y = absoluteY - (layer.origin?.y or 0)

    @getPixelForLayerAtCoordinates layerIndex, x, y
    
  findPixelAtAbsoluteCoordinates: (absoluteX, absoluteY) ->
    for layer, layerIndex in @layers when layer?.pixels
      x = absoluteX - (layer.origin?.x or 0)
      y = absoluteY - (layer.origin?.y or 0)

      pixel = @getPixelForLayerAtCoordinates layerIndex, x, y
      return pixel if pixel

    null
    
  # Bounds operations

  recomputeBounds: ->
    return unless newBounds = @getRecomputedBoundsIfNew()

    @bounds = newBounds
    @bounds.x = @bounds.left
    @bounds.y = @bounds.top
    @bounds.width = @bounds.right - @bounds.left + 1
    @bounds.height = @bounds.bottom - @bounds.top + 1

  getRecomputedBoundsIfNew: ->
    bounds = null

    for layer, index in @layers when layer?.pixels
      for pixel in layer.pixels
        absoluteX = pixel.x + (layer.origin?.x or 0)
        absoluteY = pixel.y + (layer.origin?.y or 0)

        if bounds
          bounds =
            left: Math.min bounds.left, absoluteX
            right: Math.max bounds.right, absoluteX
            top: Math.min bounds.top, absoluteY
            bottom: Math.max bounds.bottom, absoluteY

        else
          bounds = left: absoluteX, right: absoluteX, top: absoluteY, bottom: absoluteY

    # Nothing to do if bounds are the same.
    return if @boundsMatch bounds

    # Bounds are different, return them.
    bounds
    
  boundsMatch: (properties) ->
    # See if bounds match the sent properties. Note that we can't just
    # compare for equality since @bounds might have extra properties.
    for property, value of properties
      unless @bounds?[property] is value
        return false

    true
    
  # History operations
  
  _applyOperation: (forward, backward) ->
    @_modifyBoundsBeforeApply arguments...
    super arguments...

  _modifyBoundsBeforeApply: (forward, backward) ->
    # See if we're updating bounds.
    if forward.$set?.bounds
      if @bounds
        # Replace current bounds going backward.
        backward.$set ?= {}
        backward.$set.bounds = @bounds

      else
        # Remove bounds.
        backward.$unset ?= {}
        backward.$unset.bounds = true

    if forward.$unset?.bounds
      backward.$set ?= {}
      backward.$set.bounds = @bounds

  _applyOperationAndCombineHistory: (forward, combinedForward, combinedBackward) ->
    # See if we're updating bounds.
    if forward.$set?.bounds
      combinedForward.$set ?= {}
      combinedForward.$set.bounds = forward.$set.bounds

      # Restore previous bounds unless they were already being restored.
      unless combinedBackward.$set?.bounds or combinedBackward.$unset?.bounds
        combinedBackward.$set ?= {}
        combinedBackward.$set.bounds = @bounds

    super arguments...

  _applyOperationAndConnectHistory: (forward, backward) ->
    @_modifyBoundsBeforeApply arguments...
    super arguments...

  # Database content

  getSaveData: ->
    saveData = super arguments...
    _.extend saveData, _.pick @, ['bounds']

    # When saving layers, don't save pixel maps.
    if @layers
      saveData.layers = []

      for layer in @layers
        saveData.layers.push _.omit layer, ['_pixelMap']

    saveData

  getPreviewImage: ->
    engineSprite = new LOI.Assets.Engine.PixelImage.Sprite
      asset: => @

    engineSprite.getCanvas
      lightDirection: new THREE.Vector3 0, 0, -1
