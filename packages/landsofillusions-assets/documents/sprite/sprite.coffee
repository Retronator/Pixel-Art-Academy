AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 2D pixel art asset.
class LOI.Assets.Sprite extends LOI.Assets.VisualAsset
  @id: -> 'LandsOfIllusions.Assets.Sprite'
  # layers: array of
  #   name: name of the layer
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
  @forCharacterPartTemplatesOfTypes: @subscription 'forCharacterPartTemplatesOfTypes'

  # Methods
  
  @clear: @method 'clear'

  @addPixel: @method 'addPixel'
  @removePixel: @method 'removePixel'
  @colorFill: @method 'colorFill'
  @replacePixels: @method 'replacePixels'
  
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
