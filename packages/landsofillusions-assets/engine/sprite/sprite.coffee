AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Engine.Sprite
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return unless spriteData.customPalette or LOI.Assets.Palette.documents.findOne(spriteData.palette?._id) or @options.visualizeNormals?()

      true

  drawToContext: (context, renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    spriteData = @options.spriteData()

    return unless @ready()

    @_render renderOptions

    # Right now we're using canvas' drawing capabilities, without using our depth data. This is done for simplicity
    # since we can let canvas' context deal with transformations and stuff. Eventually we'll want to move to either
    # a custom drawing routine or upgrade to WebGL.
    bounds = spriteData.bounds

    context.imageSmoothingEnabled = false
    context.drawImage @_canvas, bounds.x, bounds.y

  getImageData: (renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.spriteData()
    return unless @ready()

    @_render renderOptions
    @_imageData

  getCanvas: (renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.spriteData()
    return unless @ready()

    @_render renderOptions
    @_canvas

  _render: (renderOptions) ->
    spriteData = @options.spriteData()

    # On the server we need to manually request pixel maps.
    spriteData.requirePixelMaps() if Meteor.isServer

    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette?._id

    # Build a new canvas if needed.
    unless @_canvas?.width is spriteData.bounds.width and @_canvas?.height is spriteData.bounds.height
      @_canvas = new AM.Canvas spriteData.bounds.width, spriteData.bounds.height

    # Resize the canvas if needed.
    @_context = @_canvas.context
    @_imageData = @_canvas.getFullImageData()
    @_canvasPixelsCount = @_canvas.width * @_canvas.height

    # Clear the image buffer to transparent.
    @_imageData.data.fill 0

    # Build the depth buffer if needed.
    unless @_depthBuffer?.length is @_canvasPixelsCount
      @_depthBuffer = new Float32Array @_canvasPixelsCount

    # Clear the depth buffer to smallest value.
    @_depthBuffer.fill Number.NEGATIVE_INFINITY

    # Prepare constants.
    inverseLightDirection = renderOptions.lightDirection?.clone().multiplyScalar(-1)
    materialsData = @options.materialsData?()
    visualizeNormals = @options.visualizeNormals?()
    flippedHorizontal = @options.flippedHorizontal
    flippedHorizontal = flippedHorizontal() if _.isFunction flippedHorizontal

    for layer in spriteData.layers when layer?.pixels and layer.visible isnt false
      layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0
        z: layer.origin?.z or 0

      for pixel in layer.pixels
        # Find pixel index in the image buffer.
        x = pixel.x + layerOrigin.x - spriteData.bounds.x
        y = pixel.y + layerOrigin.y - spriteData.bounds.y
        depthPixelIndex = x + y * @_canvas.width
        pixelIndex = depthPixelIndex * 4

        # Allow a special material called 'erase' to delete pixels.
        erase = spriteData.materials?[pixel.materialIndex]?.name is 'erase'

        if erase
          z = Number.NEGATIVE_INFINITY

        else
          # Cull by depth.
          z = layerOrigin.z + (pixel.z or 0)
          continue if z < @_depthBuffer[depthPixelIndex]

        # Update depth buffer.
        @_depthBuffer[depthPixelIndex] = z

        # Determine the color.
        if visualizeNormals
          # Visualized normals mode.
          if pixel.normal
            normal = new THREE.Vector3 pixel.normal.x, pixel.normal.y, pixel.normal.z
            normal.x *= -1 if flippedHorizontal
            backward = new THREE.Vector3 0, 0, 1

            horizontalAngle = Math.atan2(normal.y, normal.x) + Math.PI
            verticalAngle = normal.angleTo backward

            hue = horizontalAngle / (2 * Math.PI)
            saturation = verticalAngle / (Math.PI / 2)

            if Math.abs(verticalAngle) > Math.PI / 2
              lightness = 1 - Math.abs(verticalAngle) / Math.PI

            else
              lightness = 0.5

            destinationColor = new THREE.Color().setHSL hue, saturation, lightness

          else
            destinationColor = r: 0, g: 0, b: 0

        else if renderOptions.renderNormalData
          # Rendering of raw normal data for use in shaders.
          if pixel.normal
            destinationColor = r: pixel.normal.x * 0.5 + 0.5, g: pixel.normal.y * 0.5 + 0.5, b: pixel.normal.z * 0.5 + 0.5
            destinationColor.r = -pixel.normal.x * 0.5 + 0.5 if flippedHorizontal

          else
            destinationColor = r: 0, g: 0, b: 0

        else if renderOptions.renderPaletteData
          # Rendering of ramp + shade + dither data for use in shaders.
          paletteColor = null

          # Normal color mode.
          if pixel.materialIndex?
            material = spriteData.materials[pixel.materialIndex]

            paletteColor = _.clone material

            # Override material data if we have it present.
            if materialData = materialsData?[material.name]
              for key, value of materialData
                paletteColor[key] = value if value?

          else if pixel.paletteColor
            paletteColor = pixel.paletteColor
            
          if paletteColor
            destinationColor =
              r: paletteColor.ramp / 255
              g: paletteColor.shade / 255
              b: paletteColor.dither or 0
            
          else
            destinationColor = r: 255, g: 255, b: 255, a: 0

        else
          paletteColor = null

          # Normal color mode.
          if pixel.materialIndex?
            continue unless material = spriteData.materials?[pixel.materialIndex]

            paletteColor = _.clone material

            # Override material data if we have it present.
            if materialData = materialsData?[material.name]
              for key, value of materialData
                paletteColor[key] = value if value?

          else if pixel.paletteColor
            paletteColor = pixel.paletteColor

          else if pixel.directColor
            directColor = pixel.directColor

          if paletteColor
            continue unless shades = palette.ramps[paletteColor.ramp]?.shades
            shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1
            directColor = shades[shadeIndex]

          unless directColor
            console.warn "Missing color information in pixel", pixel
            continue

          sourceColor = THREE.Color.fromObject directColor

          if inverseLightDirection
            # Shade color based on the normal.
            shadeFactor = 0

            # Ambient lighting.
            sceneAmbientCoefficient = 0.4
            materialAmbientCoefficient = 1

            if sceneAmbientCoefficient and materialAmbientCoefficient
              shadeFactor += sceneAmbientCoefficient * materialAmbientCoefficient

            # Diffuse lighting
            if pixel.normal
              normal = new THREE.Vector3 pixel.normal.x, pixel.normal.y, pixel.normal.z
              normal.x *= -1 if flippedHorizontal

            else
              normal = new THREE.Vector3 0, 0, 1

            normalLightProduct = THREE.Math.clamp normal.dot(inverseLightDirection), 0, 1

            lightDiffuseCoefficient = 0.6
            materialDiffuseCoefficient = 1

            if lightDiffuseCoefficient and materialDiffuseCoefficient
              shadeFactor += normalLightProduct * lightDiffuseCoefficient * materialDiffuseCoefficient

            lightSpecularCoefficient = 1
            materialSpecularCoefficient = 0

            if paletteColor?.reflection
              materialSpecularCoefficient = paletteColor.reflection.intensity
              shininess = paletteColor.reflection.shininess

            shadedColor = sourceColor.clone().multiplyScalar shadeFactor

            if lightSpecularCoefficient and materialSpecularCoefficient
              smoothFactor = paletteColor.reflection.smoothFactor or 0

              # Average the normal.
              averageNormal = new THREE.Vector3

              for offsetX in [-smoothFactor..smoothFactor]
                for offsetY in [-smoothFactor..smoothFactor]
                  if sampleNormal = layer._pixelMap[pixel.x + offsetX]?[pixel.y + offsetY]?.normal
                    averageNormal.add sampleNormal

              averageNormal.normalize()
              averageNormal.x *= -1 if flippedHorizontal

              averageNormalLightProduct = THREE.Math.clamp averageNormal.dot(inverseLightDirection), 0, 1

              # Calculate the perfectly reflected ray.
              reflection = averageNormal.clone().multiplyScalar(2 * averageNormalLightProduct).sub inverseLightDirection

              # We assume the inverse view direction to be (0, 0, 1).
              # Dot product is then the equivalent of the z coordinate.
              reflectionViewProduct = THREE.Math.clamp reflection.z, 0, 1

              lightFactor = Math.pow(reflectionViewProduct, shininess) * lightSpecularCoefficient * materialSpecularCoefficient
              lightColor = new THREE.Color(0xffffff).multiplyScalar lightFactor

              shadedColor.add lightColor

            if palette
              # Find the nearest color from the palette to represent the shaded color.
              bestColor = null
              secondBestColor = null
              bestColorDistance = Number.POSITIVE_INFINITY
              secondBestColorDistance = Number.POSITIVE_INFINITY

              # If we got this color from a palette ramp, we should shade only withing it.
              # If it was done as a direct color, we'll match it to the whole palette space.
              ramps = if paletteColor then [palette.ramps[paletteColor.ramp]] else palette.ramps

              for ramp in ramps
                for shade in ramp.shades
                  distance = Math.pow(shade.r - shadedColor.r, 2) + Math.pow(shade.g - shadedColor.g, 2) + Math.pow(shade.b - shadedColor.b, 2)

                  if distance < bestColorDistance
                    secondBestColor = bestColor
                    secondBestColorDistance = bestColorDistance
                    bestColor = shade
                    bestColorDistance = distance

                  else if distance < secondBestColorDistance
                    secondBestColor = shade
                    secondBestColorDistance = distance

              destinationColor = bestColor

              # Apply dithering.

              ditherPercentage = 2 * bestColorDistance / (bestColorDistance + secondBestColorDistance)

              if ditherPercentage > 1 - (paletteColor?.dither or 0)
                if Math.abs(pixel.x % 2) + Math.abs(pixel.y % 2) is 1
                  destinationColor = secondBestColor

              ### Smooth shading routine
              #closest = THREE.Color.fromObject bestColor
              #farthest = THREE.Color.fromObject secondBestColor

              #blendFactor = bestColorDistance / (bestColorDistance + secondBestColorDistance)

              #destinationColor = closest.lerp(farthest, blendFactor)
              ###

            else
              destinationColor = shadedColor

          else
            destinationColor = sourceColor

        if erase
          @_imageData.data[pixelIndex + 3] = 0

        else
          @_imageData.data[pixelIndex] = destinationColor.r * 255
          @_imageData.data[pixelIndex + 1] = destinationColor.g * 255
          @_imageData.data[pixelIndex + 2] = destinationColor.b * 255
          @_imageData.data[pixelIndex + 3] = (destinationColor.a or 1) * 255

    @_canvas.putFullImageData @_imageData
