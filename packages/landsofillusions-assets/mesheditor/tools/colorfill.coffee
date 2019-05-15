AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.ColorFill extends LOI.Assets.SpriteEditor.Tools.Tool
  # fillColors: boolean whether to fill color information
  # fillNormals: boolean whether to fill normals
  # cornerNeighbors: boolean whether pixels that only touch with a corner are considered neighbors
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.ColorFill'
  @displayName: -> "Color fill"

  @initialize()

  constructor: ->
    super arguments...

    @fillColors = new ComputedField =>
      @data.get('fillColors') ? true

    @fillNormals = new ComputedField =>
      @data.get('fillNormals') ? true

  onMouseDown: (event) ->
    super arguments...

    return unless @mouseState.leftButton

    # Make sure we have paint at all.
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    paint = {}

    colorProperties = ['directColor', 'paletteColor', 'materialIndex']
    fillColors = @fillColors()
    fillNormals = @fillNormals()

    if fillColors
      for colorProperty in colorProperties
        colorValue = paintHelper[colorProperty]()
        paint[colorProperty] = colorValue if colorValue?

    if fillNormals
      paint.normal = paintHelper.normal()

    return unless paint.directColor or paint.paletteColor or paint.materialIndex? or paint.normal

    pixels = []
    picture = @editor().activePicture()
    bounds = picture.bounds()
    width = bounds.width
    height = bounds.height
    visitedPixels = new Uint8Array width * height

    cornerNeighbors = @data.get('cornerNeighbors')

    # See if there is a pixel at the fill location.
    targetX = @mouseState.x - bounds.x
    targetY = @mouseState.y - bounds.y
    targetExists = picture.pixelExistsRelative targetX, targetY

    # Start filling at the target.
    fringe = [x: targetX, y: targetY]
    visitedPixels[targetX + targetY * width] = 1

    while fringe.length
      fringePixel = fringe.pop()
      pixels.push _.extend {}, fringePixel, paint

      # Try to add all neighboring pixels.
      for xOffset in [-1..1]
        neighborX = fringePixel.x + xOffset
        continue unless 0 <= neighborX < width

        for yOffset in [-1..1]
          # See if this is a valid neighbor.
          distance = Math.abs(xOffset) + Math.abs(yOffset)

          # Skip same pixel.
          continue unless distance

          # We can go to corner neighbors only if we're filling existing pixels.
          continue if distance is 2 and not (cornerNeighbors and targetExists)

          neighborY = fringePixel.y + yOffset
          continue unless 0 <= neighborY < height

          # Skip if we've already visited this pixel.
          neighborIndex = neighborX + neighborY * width
          continue if visitedPixels[neighborIndex]
          visitedPixels[neighborIndex] = 1

          if targetExists
            # We're matching an existing pixel so we can skip if this is not a filled pixel.
            continue unless picture.pixelExistsRelative neighborX, neighborY

            # See if this pixel has the same map values as the target pixel.
            pixelIsSame = true

            if fillColors
              for mapType in colorProperties
                continue unless map = picture.maps[mapType]
                unless map.pixelsAreSame targetX, targetY, neighborX, neighborY
                  pixelIsSame = false
                  break

            continue unless pixelIsSame

            if fillNormals and picture.maps.normal
              continue unless picture.maps.normal.pixelsAreSame targetX, targetY, neighborX, neighborY

          else
            # We're filling empty area so just look that there is no pixel here.
            continue if picture.pixelExistsRelative neighborX, neighborY

            # When we're filling an empty area, if we reach the edge of the picture
            # we need to abort since we don't allow filling outside of closed areas.
            return if neighborX is 0 or neighborX is width - 1 or neighborY is 0 or neighborY is height - 1

          # It seems legit, add it.
          fringe.push x: neighborX, y: neighborY

    # If we're modifying color data, we set the rest of the color properties to null to delete them.
    if @fillColors()
      for pixel in pixels
        pixel.materialIndex ?= null
        pixel.paletteColor ?= null
        pixel.directColor ?= null

    # Set pixels with relative coordinates.
    picture.setPixels pixels, true
