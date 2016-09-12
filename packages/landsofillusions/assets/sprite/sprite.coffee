LOI = LandsOfIllusions

# A 2D image asset.
class LandsOfIllusionsAssetsSprite extends Document
  # name: text identifier for the sprite
  # pixels: array of
  #   x: location of pixel in pixels
  #   y: location of pixel in pixels
  #   color: direct hex color of the pixel (or null if using indexed colors)
  #     r, g, b: (0.0-1.0)
  #   colorIndex: the index of the named color of the pixel (or null if using direct colors)
  #   relativeShade: which relative shade of the color should this pixel be
  # origin: where the anchor point for the image is
  #   x: in pixels
  #   y: in pixels
  # palette: the color palette that this sprite uses (or null if only direct colors are used)
  #   _id
  #   name
  # colorMap: map from color indices to named colors
  #   (colorIndex):
  #     name: what the color represents
  #     ramp: index of the ramp within the palette
  #     shade: the base shade to which polygon shades are relative to
  # bounds: image bounds in pixels (or null if no pixels)
  #   left, right, top, bottom
  @Meta
    name: 'LandsOfIllusionsAssetsSprite'
    fields: =>
      palette: @ReferenceField LOI.Assets.Palette, ['name'], false

  constructor: ->
    super

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1

LOI.Assets.Sprite = LandsOfIllusionsAssetsSprite
