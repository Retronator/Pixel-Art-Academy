AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  drawReflectancePreview: ->
    previewType = @previewType()

    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    offsetLeft = 50
    offsetTop = 10
    context.translate offsetLeft, offsetTop

    switch previewType
      when @constructor.PreviewTypes.SpecularReflection
        backgroundColor = 'white'

      when @constructor.PreviewTypes.DiffuseReflection
        backgroundColor = 'black'

    previewWidth = 180
    previewHeight = 150

    context.fillStyle = backgroundColor
    context.fillRect 0, 0, previewWidth, previewHeight

    sphereSize = 100
    radius = sphereSize / 2
    previewLeft = offsetLeft + (previewWidth - sphereSize) / 2
    previewTop = offsetTop + (previewHeight - sphereSize) / 2

    imageData = context.getImageData previewLeft, previewTop, sphereSize, sphereSize

    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    materialClass = @materialClass()
    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

    # Compute colors per center distance.
    rgbPerPixelDistance = []

    for pixelDistance in [0..radius]
      dr = pixelDistance / radius
      angleOfIncidence = Math.asin dr

      switch previewType
        when @constructor.PreviewTypes.SpecularReflection
          reflectanceFactor = 1

        when @constructor.PreviewTypes.DiffuseReflection
          reflectanceFactor = Math.cos angleOfIncidence

      reflectanceSpectrum = (wavelength) =>
        refractiveIndexMaterial = refractiveIndexSpectrum wavelength
        extinctionCoefficientMaterial = extinctionCoefficientSpectrum? wavelength

        AR.Optics.FresnelEquations.getReflectance angleOfIncidence, 1, refractiveIndexMaterial, 0, extinctionCoefficientMaterial

      xyz = AS.Color.CIE1931.getXYZForSpectrum (wavelength) =>
        D65EmissionSpectrum(wavelength) * reflectanceSpectrum(wavelength) * reflectanceFactor

      rgbPerPixelDistance[pixelDistance] = AS.Color.SRGB.getRGBForXYZ xyz

    for x in [0...sphereSize]
      for y in [0...sphereSize]
        dx = x / radius - 1
        dy = y / radius - 1
        dr = Math.sqrt dx ** 2 + dy ** 2
        pixelDistance = Math.floor dr * radius

        continue unless color = rgbPerPixelDistance[pixelDistance]

        pixelOffset = (x + y * sphereSize) * 4
        imageData.data[pixelOffset] = color.r * 255
        imageData.data[pixelOffset + 1] = color.g * 255
        imageData.data[pixelOffset + 2] = color.b * 255
        imageData.data[pixelOffset + 3] = 255

    context.putImageData imageData, previewLeft, previewTop

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, 180, 150
