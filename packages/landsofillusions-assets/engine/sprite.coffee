LOI = LandsOfIllusions

class LOI.Assets.Engine.Sprite
  constructor: (@options) ->
    @_imageCanvas = new ReactiveField null

    @_imageUpdateAutorun = Tracker.autorun =>
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds

      # Subscribe to this sprite's palette, if we have one.
      if spriteData.palette?._id
        @_paletteSubscription = LOI.Assets.Palette.forId.subscribe spriteData.palette._id

        palette = LOI.Assets.Palette.documents.findOne spriteData.palette._id
        return unless palette

      # Build a new canvas if needed.
      @_canvas ?= $('<canvas>')[0]
      @_canvas.width = spriteData.bounds.width unless @_canvas.width is spriteData.bounds.width
      @_canvas.height = spriteData.bounds.height unless @_canvas.height is spriteData.bounds.height

      context = @_canvas.getContext '2d'
      imageData = context.getImageData 0, 0, @_canvas.width, @_canvas.height
      canvasPixelsCount = @_canvas.width * @_canvas.height
      
      # Clear the image buffer to transparent.
      imageData.data.fill 0

      # Build the depth buffer if needed.
      unless @_depthBuffer?.length is canvasPixelsCount
        @_depthBuffer = new Float32Array canvasPixelsCount

      # Clear the depth buffer to smallest value.
      @_depthBuffer.fill Number.NEGATIVE_INFINITY

      # Prepare constants.
      inverseLightDirection = @options.lightDirection?()?.clone().multiplyScalar(-1)
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
          pixelIndex = (x + y * @_canvas.width) * 4

          # Cull by depth.
          z = layerOrigin.z + pixel.z
          continue if z < @_depthBuffer[pixelIndex]
          
          # Update depth buffer.
          @_depthBuffer[pixelIndex] = z

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

          else
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

              else
                normal = new THREE.Vector3 0, 0, 1

              shadeFactor = THREE.Math.clamp normal.dot(inverseLightDirection), 0, 1

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

                ditherPercentage = 2 * bestColorDistance / (bestColorDistance + secondBestColorDistance)

                destinationColor = bestColor

                if ditherPercentage > 1 - (paletteColor.dither or 0)
                  if Math.abs(pixel.x % 2) + Math.abs(pixel.y % 2) is 1
                    destinationColor = secondBestColor

              else
                destinationColor = shadedColor

            else
              destinationColor = sourceColor

          imageData.data[pixelIndex] = destinationColor.r * 255
          imageData.data[pixelIndex + 1] = destinationColor.g * 255
          imageData.data[pixelIndex + 2] = destinationColor.b * 255
          imageData.data[pixelIndex + 3] = 255

          context.putImageData imageData, 0, 0
          @_imageCanvas @_canvas

  destroy: ->
    @_imageUpdateAutorun.stop()
    @_paletteSubscription.stop()

  imageCanvas: ->
    @_imageCanvas()

  drawToContext: (context) ->
    return unless imageCanvas = @_imageCanvas()
    return unless bounds = @options.spriteData()?.bounds

    context.imageSmoothingEnabled = false
    context.drawImage imageCanvas, bounds.x, bounds.y
