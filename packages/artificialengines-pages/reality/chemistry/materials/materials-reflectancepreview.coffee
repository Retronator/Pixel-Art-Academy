AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  drawReflectancePreview: ->
    previewType = @previewType()

    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0

    switch previewType
      when @constructor.PreviewTypes.SpecularReflection
        backgroundColor = 'white'

      when @constructor.PreviewTypes.DiffuseReflection
        backgroundColor = 'black'

    context.fillStyle = backgroundColor
    context.fillRect 0, 0, canvas.width, canvas.height

    previewSize = 100
    radius = previewSize / 2
    previewLeft = (canvas.width - previewSize) / 2
    previewTop = (canvas.height - previewSize) / 2

    imageData = context.getImageData previewLeft, previewTop, previewSize, previewSize

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

    for x in [0...previewSize]
      for y in [0...previewSize]
        dx = x / radius - 1
        dy = y / radius - 1
        dr = Math.sqrt dx ** 2 + dy ** 2
        pixelDistance = Math.floor dr * radius

        continue unless color = rgbPerPixelDistance[pixelDistance]

        pixelOffset = (x + y * previewSize) * 4
        imageData.data[pixelOffset] = color.r * 255
        imageData.data[pixelOffset + 1] = color.g * 255
        imageData.data[pixelOffset + 2] = color.b * 255
        imageData.data[pixelOffset + 3] = 255

    context.putImageData imageData, previewLeft, previewTop
