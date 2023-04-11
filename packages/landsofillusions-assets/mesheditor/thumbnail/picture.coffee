AS = Artificial.Spectrum
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Thumbnail.Picture
  constructor: (@picture) ->
    @_updatedDependency = new Tracker.Dependency

  bounds: ->
    @_updatedDependency.depend()
    @_bounds

  drawToContext: (context) ->
    @_updatedDependency.depend()
    return unless bounds = @bounds()

    # Update the thumbnail if we don't have a canvas yet.
    @update() unless @_canvas

    # If the update still couldn't create a canvas, nothing to do yet.
    return unless @_canvas

    context.imageSmoothingEnabled = false
    context.drawImage @_canvas, bounds.x, bounds.y

  update: ->
    picture = @picture
    meshData = @picture.layer.object.mesh

    flagsMap = picture.maps.flags
    paletteColorMap = picture.maps.paletteColor
    materialIndexMap = picture.maps.materialIndex

    bounds = picture.bounds()
    @_bounds = bounds

    materialIndexFlagValue = LOI.Assets.Mesh.Object.Layer.Picture.Map.MaterialIndex.flagValue

    return unless paletteColorMap and bounds

    # Build a new canvas if needed.
    unless @_canvas?.width is bounds.width and @_canvas?.height is bounds.height
      @_canvas = new AM.ReadableCanvas bounds.width, bounds.height

    @_imageData = @_canvas.getFullImageData()

    # Clear the image buffer to transparent.
    @_imageData.data.fill 0

    # Prepare constants.
    palette = LOI.Assets.Palette.documents.findOne meshData.palette?._id

    for y in [0...bounds.height]
      for x in [0...bounds.width]
        continue unless picture.pixelExistsRelative x, y

        if flagsMap.pixelHasFlag x, y, materialIndexFlagValue
          materialIndex = materialIndexMap.getPixel x, y
          material = meshData.materials.get materialIndex

          # Note: When switching between active files, materials might not yet be available.
          ramp = material?.ramp
          shade = material?.shade

        else
          paletteColorMapIndex = paletteColorMap.calculateDataIndex x, y
          ramp = paletteColorMap.data[paletteColorMapIndex]
          shade = paletteColorMap.data[paletteColorMapIndex + 1]

        continue unless shades = palette.ramps[ramp]?.shades
        shadeIndex = THREE.Math.clamp shade, 0, shades.length - 1
        directColor = shades[shadeIndex]

        unless directColor
          console.warn "Missing color information in pixel", x, y
          continue

        destinationColor = THREE.Color.fromObject directColor

        pixelIndex = (x + y * bounds.width) * 4

        @_imageData.data[pixelIndex] = destinationColor.r * 255
        @_imageData.data[pixelIndex + 1] = destinationColor.g * 255
        @_imageData.data[pixelIndex + 2] = destinationColor.b * 255
        @_imageData.data[pixelIndex + 3] = (destinationColor.a or 1) * 255

    @_canvas.putFullImageData @_imageData

    @_updatedDependency.changed()
