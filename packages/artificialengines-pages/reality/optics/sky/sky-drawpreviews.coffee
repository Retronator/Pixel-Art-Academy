AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  @register 'Artificial.Reality.Pages.Optics.Sky'

  drawPreviews: ->
    return unless sidePreviewData = @sidePreview.data()
    return unless hemispherePreviewData = @hemispherePreview.data()

    exposure = 2 ** @exposureValue()

    getGammaRGBForXYZ = (xyz) =>
      AS.Color.SRGB.getGammaRGBForXYZ
        x: xyz.x * exposure
        y: xyz.y * exposure
        z: xyz.z * exposure

    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    # Draw side preview.
    previewImageData = @context.getImageData @offsetLeft, @offsetTop, @sidePreview.width, @sidePreview.height

    for x in [0..360]
      for y in [0...@sidePreview.height]
        rgb = getGammaRGBForXYZ sidePreviewData[x][y]

        pixelOffset = (x + y * previewImageData.width) * 4

        previewImageData.data[pixelOffset] = rgb.r * 255
        previewImageData.data[pixelOffset + 1] = rgb.g * 255
        previewImageData.data[pixelOffset + 2] = rgb.b * 255
        previewImageData.data[pixelOffset + 3] = 255

    @context.putImageData previewImageData, @offsetLeft, @offsetTop

    # Draw hemisphere preview.
    previewImageData = @context.getImageData @offsetLeftHemisphere, @offsetTopHemisphere, @hemispherePreview.width, @hemispherePreview.height

    for x in [0..180]
      vx = x / 90 - 1

      for y in [0..90]
        vy = -(y / 90 - 1)

        vz2 = vx ** 2 + vy ** 2
        continue if vz2 > 1

        inclination = Math.acos 1 - vz2
        inclinationDegrees = Math.round AR.Conversions.radiansToDegrees inclination

        azimuthDivisions = hemispherePreviewData[inclinationDegrees].length - 1

        azimuth = Math.abs Math.atan2 vy, vx
        azimuthStep = Math.round azimuth / Math.PI * azimuthDivisions

        rgb = getGammaRGBForXYZ hemispherePreviewData[inclinationDegrees][azimuthStep]

        for ry in [y, 180 - y]
          pixelOffset = (x + ry * previewImageData.width) * 4

          previewImageData.data[pixelOffset] = rgb.r * 255
          previewImageData.data[pixelOffset + 1] = rgb.g * 255
          previewImageData.data[pixelOffset + 2] = rgb.b * 255
          previewImageData.data[pixelOffset + 3] = 255

    @context.putImageData previewImageData, @offsetLeftHemisphere, @offsetTopHemisphere

    # Draw Skydome preview.
    previewImageData = @context.getImageData @offsetLeftSkydome, @offsetTopSkydome, @skydomePreview.width, @skydomePreview.height

    for x in [0..360]
      azimuthDegrees = x - 180
      azimuth = Math.abs AR.Degrees azimuthDegrees

      for y in [0..90]
        inclinationDegrees = y
        azimuthDivisions = hemispherePreviewData[inclinationDegrees].length - 1
        azimuthStep = Math.round azimuth / Math.PI * azimuthDivisions

        rgb = getGammaRGBForXYZ hemispherePreviewData[inclinationDegrees][azimuthStep]

        pixelOffset = (x + y * previewImageData.width) * 4

        previewImageData.data[pixelOffset] = rgb.r * 255
        previewImageData.data[pixelOffset + 1] = rgb.g * 255
        previewImageData.data[pixelOffset + 2] = rgb.b * 255
        previewImageData.data[pixelOffset + 3] = 255

    @context.putImageData previewImageData, @offsetLeftSkydome, @offsetTopSkydome

    # Draw the rest of the elements.
    @_drawPreviewElements()
