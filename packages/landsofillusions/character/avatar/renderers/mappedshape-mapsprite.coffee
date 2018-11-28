LOI = LandsOfIllusions

Delaunator = require 'delaunator'
barycentric = require 'barycentric'

class LOI.Character.Avatar.Renderers.MappedShape extends LOI.Character.Avatar.Renderers.MappedShape
  _mapSprite: (spriteData, targetLandmarks) ->
    return spriteData unless targetLandmarks.length and spriteData?.bounds

    # Clone sprite data to the depth of the first layer so we can replace the pixels there.
    newSpriteData = {}
    newSpriteData[key] = value for own key, value of spriteData
    newSpriteData.layers = _.clone newSpriteData.layers
    newSpriteData.layers[0] = _.clone newSpriteData.layers[0]
    newSpriteData.palette = {}
    newSpriteData.palette[key] = value for own key, value of spriteData.palette

    # Find all the landmarks in the sprite that can be mapped to the target.
    sourceLandmarks = _.intersectionBy newSpriteData.landmarks, targetLandmarks, 'name'
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

    if flipHorizontal = @options.region?.id.indexOf('Right') >= 0
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
    triangle = [[], [], []]

    sourcePixels = newSpriteData.layers[0].pixels
    targetPixels = []

    for triangleIndex in [0...delaunay.triangles.length / 3]
      triangle[0][0] = delaunay.coords[delaunay.triangles[triangleIndex * 3] * 2]
      triangle[0][1] = delaunay.coords[delaunay.triangles[triangleIndex * 3] * 2 + 1]
      triangle[1][0] = delaunay.coords[delaunay.triangles[triangleIndex * 3 + 1] * 2]
      triangle[1][1] = delaunay.coords[delaunay.triangles[triangleIndex * 3 + 1] * 2 + 1]
      triangle[2][0] = delaunay.coords[delaunay.triangles[triangleIndex * 3 + 2] * 2]
      triangle[2][1] = delaunay.coords[delaunay.triangles[triangleIndex * 3 + 2] * 2 + 1]

      left = Math.ceil Math.min triangle[0][0], triangle[1][0], triangle[2][0]
      right = Math.floor Math.max triangle[0][0], triangle[1][0], triangle[2][0]
      top = Math.ceil Math.min triangle[0][1], triangle[1][1], triangle[2][1]
      bottom = Math.floor Math.max triangle[0][1], triangle[1][1], triangle[2][1]

      for x in [left..right]
        for y in [top..bottom]
          # Skip already-rasterized pixels.
          continue if _.find targetPixels, (pixel) => pixel.x is x and pixel.y is y

          # Calculate barycentric coordinates of the point in this triangle.
          pointWeights = barycentric triangle, [x, y]
          continue unless 0 <= pointWeights[0] <= 1 and 0 <= pointWeights[1] <= 1 and 0 <= pointWeights[2] <= 1
          continue unless 0.999 < pointWeights[0] + pointWeights[1] + pointWeights[2] < 1.001

          # Sample the pixel in the sprite.
          sampleX = pointWeights[0] * sourceLandmarks[delaunay.triangles[triangleIndex * 3]].x + pointWeights[1] * sourceLandmarks[delaunay.triangles[triangleIndex * 3 + 1]].x + pointWeights[2] * sourceLandmarks[delaunay.triangles[triangleIndex * 3 + 2]].x
          sampleY = pointWeights[0] * sourceLandmarks[delaunay.triangles[triangleIndex * 3]].y + pointWeights[1] * sourceLandmarks[delaunay.triangles[triangleIndex * 3 + 1]].y + pointWeights[2] * sourceLandmarks[delaunay.triangles[triangleIndex * 3 + 2]].y

          mainSampleX = Math.round sampleX
          mainSampleY = Math.round sampleY

          continue unless mainSamplePixel = _.find sourcePixels, (pixel) => pixel.x is mainSampleX and pixel.y is mainSampleY

          topLeftSampleX = Math.floor sampleX
          topLeftSampleY = Math.floor sampleY

          fractionX = sampleX - topLeftSampleX
          fractionY = sampleY - topLeftSampleY

          getNormal = (offsetX, offsetY) =>
            return null unless samplePixel = _.find sourcePixels, (pixel) => pixel.x is topLeftSampleX + offsetX and pixel.y is topLeftSampleY + offsetY
            THREE.Vector3.fromObject samplePixel.normal

          normalTopLeft = getNormal 0, 0
          normalBottomLeft = getNormal 0, 1
          normalTopRight = getNormal 1, 0
          normalBottomRight = getNormal 1, 1

          if normalTopLeft and normalBottomLeft
            normalLeft = new THREE.Vector3().lerpVectors normalTopLeft, normalBottomLeft, fractionY

          else if normalTopLeft
            normalLeft = normalTopLeft

          else if normalBottomLeft
            normalLeft = normalBottomLeft

          else
            normalLeft = null

          if normalTopRight and normalBottomRight
            normalRight = new THREE.Vector3().lerpVectors normalTopRight, normalBottomRight, fractionY

          else if normalTopRight
            normalRight = normalTopRight

          else if normalBottomRight
            normalRight = normalBottomRight

          else
            normalRight = null

          if normalLeft and normalRight
            normal = new THREE.Vector3().lerpVectors(normalLeft, normalRight, fractionX).toObject()

          else if normalLeft
            normal = normalLeft.toObject()

          else if normalRight
            normal = normalRight.toObject()

          normal.x *= -1 if flipHorizontal

          # Copy the sample pixel to target coordinates.
          targetPixels.push _.extend {}, mainSamplePixel, {x, y, normal}

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
