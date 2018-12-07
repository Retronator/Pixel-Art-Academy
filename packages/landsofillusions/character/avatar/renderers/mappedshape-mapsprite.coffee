LOI = LandsOfIllusions

Delaunator = require 'delaunator'
barycentric = require 'barycentric'

class LOI.Character.Avatar.Renderers.MappedShape extends LOI.Character.Avatar.Renderers.MappedShape
  _mapSprite: (spriteData, sourceLandmarks, targetLandmarks) ->
    return spriteData unless targetLandmarks.length and spriteData?.bounds

    # Clone sprite data to the depth of the first layer so we can replace the pixels there.
    newSpriteData = {}
    newSpriteData[key] = value for own key, value of spriteData
    newSpriteData.layers = _.clone newSpriteData.layers
    newSpriteData.layers[0] = _.clone newSpriteData.layers[0]
    newSpriteData.palette = {}
    newSpriteData.palette[key] = value for own key, value of spriteData.palette

    # Find all the landmarks in the sprite that can be mapped to the target.
    sourceLandmarks = _.intersectionBy sourceLandmarks, targetLandmarks, 'name'
    targetLandmarks = _.intersectionBy targetLandmarks, sourceLandmarks, 'name'

    # Sprite data should provide landmarks at new locations.
    # TODO: Also transform any non-mapped landmarks.
    newSpriteData.landmarks = _.clone targetLandmarks

    return newSpriteData unless sourceLandmarks.length

    # Order the landmarks by name so we make sure both arrays have them positioned at same indices.
    sourceLandmarks = _.sortBy sourceLandmarks, 'name'
    targetLandmarks = _.sortBy targetLandmarks, 'name'

    # Calculate landmark bounds.
    sourceLandmarksBounds = @_calculateLandmarkBounds sourceLandmarks
    targetLandmarksBounds = @_calculateLandmarkBounds targetLandmarks

    # Calculate padding between sprite landmarks and sprite bounds.
    padding =
      left: Math.max 0, sourceLandmarksBounds.left - (newSpriteData.bounds.left - 0.5)
      right: Math.max 0, (newSpriteData.bounds.right + 0.5) - sourceLandmarksBounds.right
      top: Math.max 0, sourceLandmarksBounds.top - (newSpriteData.bounds.top - 0.5)
      bottom: Math.max 0, (newSpriteData.bounds.bottom + 0.5) - sourceLandmarksBounds.bottom

    # Target padding is the same unless we're in Right regions and we have to flip it.
    targetPadding = _.clone padding

    flipHorizontal = @activeSpriteFlipped()

    if flipHorizontal
      [targetPadding.left, targetPadding.right] = [targetPadding.right, targetPadding.left]

    # Add bound corners as extra landmarks. Source corners need to be flipped in Right regions.
    @_addBoundsCorners sourceLandmarks, sourceLandmarksBounds, padding, flipHorizontal
    @_addBoundsCorners targetLandmarks, targetLandmarksBounds, targetPadding

    # Calculate triangulation of target landmarks.
    getX = (landmark) => landmark.x
    getY = (landmark) => landmark.y

    delaunay = Delaunator.from targetLandmarks, getX, getY
    @debugDelaunay delaunay

    # Rasterize the triangles, mapping pixels from source.
    sourcePixels = newSpriteData.layers[0].pixels
    targetPixels = []

    for triangleIndex in [0...delaunay.triangles.length / 3]
      # Rasterize target pixels one by one and sample from the source sprite.
      targetTriangle = @_calculateTriangleData triangleIndex, delaunay.triangles, delaunay.coords
      sourceTriangle = @_calculateTriangleData triangleIndex, delaunay.triangles, sourceLandmarks

      for x in [targetTriangle.bounds.left..targetTriangle.bounds.right]
        for y in [targetTriangle.bounds.top..targetTriangle.bounds.bottom]
          # Skip already-rasterized pixels.
          continue if _.find targetPixels, (pixel) => pixel.x is x and pixel.y is y

          continue unless sample = @_calculateSample sourceTriangle.coordinates, targetTriangle.coordinates, x, y

          continue unless mainSamplePixel = _.find sourcePixels, (pixel) => pixel.x is sample.integer.x and pixel.y is sample.integer.y

          getNormal = (offsetX, offsetY) =>
            return null unless samplePixel = _.find sourcePixels, (pixel) => pixel.x is sample.topLeftInteger.x + offsetX and pixel.y is sample.topLeftInteger.y + offsetY
            THREE.Vector3.fromObject samplePixel.normal

          normalTopLeft = getNormal 0, 0
          normalBottomLeft = getNormal 0, 1
          normalTopRight = getNormal 1, 0
          normalBottomRight = getNormal 1, 1

          if normalTopLeft and normalBottomLeft
            normalLeft = new THREE.Vector3().lerpVectors normalTopLeft, normalBottomLeft, sample.fraction.y

          else if normalTopLeft
            normalLeft = normalTopLeft

          else if normalBottomLeft
            normalLeft = normalBottomLeft

          else
            normalLeft = null

          if normalTopRight and normalBottomRight
            normalRight = new THREE.Vector3().lerpVectors normalTopRight, normalBottomRight, sample.fraction.y

          else if normalTopRight
            normalRight = normalTopRight

          else if normalBottomRight
            normalRight = normalBottomRight

          else
            normalRight = null

          if normalLeft and normalRight
            normal = new THREE.Vector3().lerpVectors(normalLeft, normalRight, sample.fraction.x).toObject()

          else if normalLeft
            normal = normalLeft.toObject()

          else if normalRight
            normal = normalRight.toObject()

          # Copy the sample pixel to target coordinates.
          targetPixels.push _.extend {}, mainSamplePixel, {x, y, normal}

      # Go over source sprite and map pixels to the target so that each source pixel is displayed somewhere.
      for x in [sourceTriangle.bounds.left..sourceTriangle.bounds.right]
        for y in [sourceTriangle.bounds.top..sourceTriangle.bounds.bottom]
          # Skip empty pixels.
          continue unless samplePixel = _.find sourcePixels, (pixel) => pixel.x is x and pixel.y is y

          # Calculate where in the target this pixel would map to.
          continue unless sample = @_calculateSample targetTriangle.coordinates, sourceTriangle.coordinates, x, y

          # Skip already-rasterized pixels.
          continue if _.find targetPixels, (pixel) => pixel.x is sample.integer.x and pixel.y is sample.integer.y

          targetPixels.push _.extend {}, samplePixel,
            x: sample.integer.x
            y: sample.integer.y

    newSpriteData.layers[0].pixels = targetPixels
    newSpriteData.bounds = null

    if targetPixels.length
      newSpriteData.bounds =
        left: targetPixels[0].x
        right: targetPixels[0].x
        top: targetPixels[0].y
        bottom: targetPixels[0].y

      for pixel in targetPixels[1..]
        newSpriteData.bounds.left = Math.min newSpriteData.bounds.left, pixel.x
        newSpriteData.bounds.right = Math.max newSpriteData.bounds.right, pixel.x
        newSpriteData.bounds.top = Math.min newSpriteData.bounds.top, pixel.y
        newSpriteData.bounds.bottom = Math.max newSpriteData.bounds.bottom, pixel.y

    new LOI.Assets.Sprite newSpriteData

  _calculateLandmarkBounds: (landmarks) ->
    bounds =
      left: landmarks[0].x
      right: landmarks[0].x
      top: landmarks[0].y
      bottom: landmarks[0].y

    for landmark in landmarks[1..]
      bounds.left = Math.min bounds.left, landmark.x
      bounds.right = Math.max bounds.right, landmark.x
      bounds.top = Math.min bounds.top, landmark.y
      bounds.bottom = Math.max bounds.bottom, landmark.y

    bounds

  _addBoundsCorners: (landmarks, bounds, padding, flipHorizontal) ->
    landmarks.push
      name: 'boundsTopLeft'
      x: if flipHorizontal then bounds.right + padding.right else bounds.left - padding.left
      y: bounds.top - padding.top

    landmarks.push
      name: 'boundsTopRight'
      x: if flipHorizontal then bounds.left - padding.left else bounds.right + padding.right
      y: bounds.top - padding.top

    landmarks.push
      name: 'boundsBottomLeft'
      x: if flipHorizontal then bounds.right + padding.right else bounds.left - padding.left
      y: bounds.bottom + padding.bottom

    landmarks.push
      name: 'boundsBottomRight'
      x: if flipHorizontal then bounds.left - padding.left else bounds.right + padding.right
      y: bounds.bottom + padding.bottom

  _calculateTriangleData: (triangleIndex, triangles, coordinates) ->
    triangle = [[], [], []]

    # See if we have an array of coordinate objects, or a flat array of x and y values interleaved.
    if coordinates[0].x?
      triangle[0][0] = coordinates[triangles[triangleIndex * 3]].x
      triangle[0][1] = coordinates[triangles[triangleIndex * 3]].y
      triangle[1][0] = coordinates[triangles[triangleIndex * 3 + 1]].x
      triangle[1][1] = coordinates[triangles[triangleIndex * 3 + 1]].y
      triangle[2][0] = coordinates[triangles[triangleIndex * 3 + 2]].x
      triangle[2][1] = coordinates[triangles[triangleIndex * 3 + 2]].y

    else
      triangle[0][0] = coordinates[triangles[triangleIndex * 3] * 2]
      triangle[0][1] = coordinates[triangles[triangleIndex * 3] * 2 + 1]
      triangle[1][0] = coordinates[triangles[triangleIndex * 3 + 1] * 2]
      triangle[1][1] = coordinates[triangles[triangleIndex * 3 + 1] * 2 + 1]
      triangle[2][0] = coordinates[triangles[triangleIndex * 3 + 2] * 2]
      triangle[2][1] = coordinates[triangles[triangleIndex * 3 + 2] * 2 + 1]

    coordinates: triangle
    bounds:
      left: Math.ceil Math.min triangle[0][0], triangle[1][0], triangle[2][0]
      right: Math.floor Math.max triangle[0][0], triangle[1][0], triangle[2][0]
      top: Math.ceil Math.min triangle[0][1], triangle[1][1], triangle[2][1]
      bottom: Math.floor Math.max triangle[0][1], triangle[1][1], triangle[2][1]

  _calculateSample: (sampleCoordinates, sourceCoordinates, x, y) ->
    # Calculate barycentric coordinates of the point in this triangle.
    pointWeights = barycentric sourceCoordinates, [x, y]
    return unless 0 <= pointWeights[0] <= 1 and 0 <= pointWeights[1] <= 1 and 0 <= pointWeights[2] <= 1
    return unless 0.999 < pointWeights[0] + pointWeights[1] + pointWeights[2] < 1.001

    # Sample the pixel in the sprite.
    x = 0
    y = 0

    for index in [0..2]
      x += pointWeights[index] * sampleCoordinates[index][0]
      y += pointWeights[index] * sampleCoordinates[index][1]

    integer =
      x: Math.round x
      y: Math.round y

    topLeftInteger =
      x: Math.floor x
      y: Math.floor y

    fraction =
      x: x - topLeftInteger.x
      y: y - topLeftInteger.y

    {integer, topLeftInteger, fraction}
