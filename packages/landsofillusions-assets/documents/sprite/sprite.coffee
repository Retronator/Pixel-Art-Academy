AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 2D image asset.
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
  # bounds: image bounds in pixels (or null if no pixels)
  #   left, right, top, bottom
  @Meta
    name: @id()

  # Store the class name of the visual asset by which we can reach the class by querying LOI.Assets. We can't simply
  # use the name parameter, because in production the name field has a minimized value.
  @className: 'Sprite'

  @forId: @subscription 'forId'
  @all: @subscription 'all'

  @insert: @method 'insert'
  @update: @method 'update'
  @clear: @method 'clear'
  @remove: @method 'remove'
  @duplicate: @method 'duplicate'

  @addPixel: @method 'addPixel'
  @removePixel: @method 'removePixel'
  @colorFill: @method 'colorFill'

  constructor: ->
    super

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1
