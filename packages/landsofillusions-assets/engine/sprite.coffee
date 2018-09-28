LOI = LandsOfIllusions

class LOI.Assets.Engine.Sprite
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return unless spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette?._id

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()

    @_render renderOptions

    # Right now we're using canvas' drawing capabilities, without using our depth data. This is done for simplicity
    # since we can let canvas' context deal with transformations and stuff. Eventually we'll want to move to either
    # a custom drawing routine or upgrade to WebGL.
    bounds = @options.spriteData().bounds

    context.imageSmoothingEnabled = false
    context.drawImage @_canvas, bounds.x, bounds.y

  _render: (renderOptions) ->
    spriteData = @options.spriteData()
    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

    # Build a new canvas if needed.
    @_canvas ?= $('<canvas>')[0]

    # Resize the canvas if needed.
    @_canvas.width = spriteData.bounds.width unless @_canvas.width is spriteData.bounds.width
    @_canvas.height = spriteData.bounds.height unless @_canvas.height is spriteData.bounds.height

    @_context = @_canvas.getContext '2d'
    @_imageData = @_context.getImageData 0, 0, @_canvas.width, @_canvas.height
    @_canvasPixelsCount = @_canvas.width * @_canvas.height

    # Clear the image buffer to transparent.
    @_imageData.data.fill 0

    # Build the depth buffer if needed.
    unless @_depthBuffer?.length is @_canvasPixelsCount
      @_depthBuffer = new Float32Array @_canvasPixelsCount

    # Clear the depth buffer to smallest value.
    @_depthBuffer.fill Number.NEGATIVE_INFINITY

    # Prepare constants.
    inverseLightDirection = renderOptions.lightDirection?()?.clone().multiplyScalar(-1)
    materialsData = @options.materialsData?()
    visualizeNormals = @options.visualizeNormals?()

    for layer in spriteData.layers
      continue unless layer.pixels

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
            backward = new THREE.Vector3 0, 0, 1

            horizontalAngle = Math.atan2(normal.y, normal.x) + Math.PI
            verticalAngle = normal.angleTo backward

            hue = horizontalAngle / (2 * Math.PI)
            saturation = verticalAngle / (Math.PI / 2)

            destinationColor = new THREE.Color().setHSL hue, saturation, 0.5

          else
            destinationColor = r: 0, g: 0, b: 0

        else if renderOptions.renderNormalData
          # Rendering of raw normal data for use in shaders.
          if pixel.normal
            destinationColor = r: pixel.normal.x, g: pixel.normal.y, b: pixel.normal.z

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
              r: paletteColor.ramp / palette.ramps.length
              g: paletteColor.shade / palette.ramps[paletteColor.ramp].shades.length
              b: paletteColor.dither or 0
            
          else
            destinationColor = r: 0, g: 0, b: 0, a: 0

        else
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

          else if pixel.directColor
            directColor = pixel.directColor

          if paletteColor
            shades = palette.ramps[paletteColor.ramp].shades
            shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1
            directColor = shades[shadeIndex]

          sourceColor = THREE.Color.fromObject directColor

          # Shade color based on the normal.
          if inverseLightDirection
            if pixel.normal
              normal = new THREE.Vector3 pixel.normal.x, pixel.normal.y, pixel.normal.z
              normal.x *= -1 if @options.flippedHorizontal

            else
              normal = new THREE.Vector3 0, 0, 1

            shadeFactor = 0.4 + 0.6 * THREE.Math.clamp normal.dot(inverseLightDirection), 0, 1

          else
            shadeFactor = 1

          if shadeFactor < 1
            shadedColor = sourceColor.multiplyScalar(shadeFactor)

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

              # Dither routine

              ditherPercentage = 2 * bestColorDistance / (bestColorDistance + secondBestColorDistance)

              if ditherPercentage > 1 - (paletteColor.dither or 0)
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

        @_imageData.data[pixelIndex] = destinationColor.r * 255
        @_imageData.data[pixelIndex + 1] = destinationColor.g * 255
        @_imageData.data[pixelIndex + 2] = destinationColor.b * 255
        @_imageData.data[pixelIndex + 3] = destinationColor.a or 255

    @_context.putImageData @_imageData, 0, 0
