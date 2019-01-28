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
  @removePixel: @method 'removePixel'
  @colorFill: @method 'colorFill'
  @replacePixels: @method 'replacePixels'
  @flipHorizontal: @method 'flipHorizontal'

  @updateLayer: @method 'updateLayer'
  @removeLayer: @method 'removeLayer'
  
  @pixelPattern = Match.ObjectIncluding
    x: Match.Integer
    y: Match.Integer
    paletteColor: Match.Optional Match.ObjectIncluding
      ramp: Match.Integer
      shade: Match.Integer
    directColor: Match.Optional Match.ObjectIncluding
      r: Number
      g: Number
      b: Number
    materialIndex: Match.Optional Match.Integer

  constructor: ->
    super arguments...

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1
      
    # On the client also create pixel maps.
    if Meteor.isClient and @layers
      for layer in @layers when layer?.pixels
        layer._pixelMap = {}

        for pixel in layer.pixels
          layer._pixelMap[pixel.x] ?= {}
          layer._pixelMap[pixel.x][pixel.y] = pixel
        
  getPixelAtCoordinate: (x, y, layerIndex) ->
    @layers[layerIndex]._pixelMap?[x]?[y]

  findPixelAtAbsoluteCoordinate: (absoluteX, absoluteY) ->
    for layer in @layers when layer?.pixels
      x = absoluteX - (layer.origin?.x or 0)
      y = absoluteY - (layer.origin?.y or 0)

      pixel = _.find layer.pixels, (pixel) => pixel.x is x and pixel.y is y
      return pixel if pixel

    null

  @_limitLayerPixels = (newCount) ->
    # Allow up to 4,096 (64 * 64) pixels per layer.
    throw new AE.ArgumentOutOfRangeException "Up to 4,096 pixels per layer are allowed." if newCount > 4096
    
  _applyOperation: (forward, backward) ->
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

    super forward, backward

  recomputeBounds: ->
    return unless newBounds = @_tryRecomputeBounds()

    @bounds = newBounds
    @bounds.x = @bounds.left
    @bounds.y = @bounds.top
    @bounds.width = @bounds.right - @bounds.left + 1
    @bounds.height = @bounds.bottom - @bounds.top + 1

  _tryRecomputeBounds: ->
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
          
    # See if bounds are even different. Note that we can't just
    # compare for equality since @bounds have extra properties.
    changed = false

    for property, value of bounds
      unless @bounds?[property] is value
        changed = true
        break

    return unless changed

    bounds

if Meteor.isServer
  # Export sprites without authors.
  LOI.GameContent.addToExport ->
    LOI.Assets.Sprite.documents.fetch authors: $exists: false
