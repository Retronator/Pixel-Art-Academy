AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  @register 'Artificial.Reality.Pages.Chemistry.Materials'

  drawDispersionPreview: ->
    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.fillStyle = 'black'
    context.fillRect 0, 0, canvas.width, canvas.height

    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    vacuumToMaterial = @reflectanceType() is @constructor.ReflectanceTypes.VacuumToMaterial
    materialClass = @materialClass()
    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

    reflectanceSpectrum = (wavelength) =>
      refractiveIndexMaterial = refractiveIndexSpectrum wavelength
      extinctionCoefficientMaterial = extinctionCoefficientSpectrum? wavelength

      if vacuumToMaterial
        AR.Optics.FresnelEquations.getReflectance angleOfIncidence, 1, refractiveIndexMaterial, 0, extinctionCoefficientMaterial

      else
        AR.Optics.FresnelEquations.getReflectance angleOfIncidence, refractiveIndexMaterial, 1, extinctionCoefficientMaterial, 0

    transmissionSpectrum = (wavelength) =>
      1 - reflectanceSpectrum wavelength

    surfaceNormal = new THREE.Vector2(-1, 0).normalize()
    surfaceNegativeNormal = surfaceNormal.clone().negate()
    incidentPoint = new THREE.Vector2(canvas.width / 2 + 0.5, canvas.height / 2 + 0.5)
    surfaceTangent = new THREE.Vector2(-surfaceNormal.y, surfaceNormal.x)

    incidentLightDirection = new THREE.Vector2(2, -1).normalize()
    reflectedLightDirection = incidentLightDirection.clone().addScaledVector(surfaceNormal, -2 * incidentLightDirection.dot(surfaceNormal))
    angleOfIncidence = _.angleDifference incidentLightDirection.angle(), surfaceNegativeNormal.angle()
    sineSquaredAngleOfIncidence = Math.sin(angleOfIncidence) ** 2

    imageData = context.getImageData 0, 0, canvas.width, canvas.height

    dBottom = new THREE.Vector2

    refractiveIndexFromEffectiveRefractiveIndex = (N, k) =>
      k /= 1e2
      k2 = k ** 2
      N2 = N ** 2
      k2PlusN2 = k2 + N2
      Math.sqrt(k2PlusN2) * Math.sqrt(N2 - sineSquaredAngleOfIncidence) / Math.sqrt(k2PlusN2 - sineSquaredAngleOfIncidence)

    refractedLightSpectrum = (wavelength) =>
      refractiveIndex = refractiveIndexSpectrum wavelength
      extinctionCoefficient = extinctionCoefficientSpectrum?(wavelength) or 0

      if effectiveRefractiveIndexTop is Number.POSITIVE_INFINITY
        refractiveIndexTop = Number.POSITIVE_INFINITY

      else
        refractiveIndexTop = refractiveIndexFromEffectiveRefractiveIndex effectiveRefractiveIndexTop, extinctionCoefficient

      if effectiveRefractiveIndexBottom is Number.POSITIVE_INFINITY
        refractiveIndexBottom = Number.POSITIVE_INFINITY

      else
        refractiveIndexBottom = refractiveIndexFromEffectiveRefractiveIndex effectiveRefractiveIndexBottom, extinctionCoefficient

      if refractiveIndexBottom < refractiveIndexTop
        return 0 unless refractiveIndexBottom < refractiveIndex < refractiveIndexTop

      else
        return 0 unless refractiveIndexTop < refractiveIndex < refractiveIndexBottom

      attenuationCoefficient = 4 * Math.PI * extinctionCoefficient / wavelength
      attenuation = Math.E ** (-attenuationCoefficient * depth)

      D65EmissionSpectrum(wavelength) * transmissionSpectrum(wavelength) * attenuation

    for x in [0...canvas.width]
      for y in [-1...canvas.height]
        angleTop = angleBottom
        effectiveRefractiveIndexTop = effectiveRefractiveIndexBottom

        dBottom.set(x, y + 1).sub(incidentPoint)
        angleOfRefractionBottom = _.angleDifference dBottom.angle(), surfaceNegativeNormal.angle()
        angleBottom = Math.abs angleOfRefractionBottom

        if angleOfRefractionBottom
          if vacuumToMaterial
            effectiveRefractiveIndexBottom = Math.sin(angleOfIncidence) / Math.sin(angleOfRefractionBottom)

          else
            effectiveRefractiveIndexBottom = Math.sin(angleOfRefractionBottom) / Math.sin(angleOfIncidence)

        else
          effectiveRefractiveIndexBottom = -1

        # Set refractive index to infinity on the negative side of transmitted angles so that all Ns will be included when crossing the normal.
        if effectiveRefractiveIndexBottom < 0
          if vacuumToMaterial
            effectiveRefractiveIndexBottom = Number.POSITIVE_INFINITY

          else
            effectiveRefractiveIndexBottom = 0

        # Don't color the first line.
        continue if y is -1

        # Don't color outside the material.
        continue if angleTop > Math.PI / 2 or angleBottom > Math.PI / 2

        # Nothing to do when range is zero.
        continue if effectiveRefractiveIndexTop is effectiveRefractiveIndexBottom

        depth = dBottom.dot(surfaceNegativeNormal) * 5e-10 # 1px = 0.5nm

        refractedLightXYZ = AS.Color.CIE1931.getXYZForSpectrum refractedLightSpectrum, 5e-10
        refractedLightRGB = AS.Color.SRGB.getRGBForXYZ refractedLightXYZ

        pixelOffset = (x + y * canvas.width) * 4
        imageData.data[pixelOffset] = refractedLightRGB.r * 255
        imageData.data[pixelOffset + 1] = refractedLightRGB.g * 255
        imageData.data[pixelOffset + 2] = refractedLightRGB.b * 255

    context.putImageData imageData, 0, 0

    # Draw incident light ray.
    context.beginPath()
    context.moveTo incidentPoint.x, incidentPoint.y
    context.lineTo incidentPoint.clone().addScaledVector(incidentLightDirection, -200).toArray()...
    context.strokeStyle = 'white'
    context.stroke()

    # Draw reflected light ray.
    reflectedLightXYZ = AS.Color.CIE1931.getXYZForSpectrum (wavelength) =>
      D65EmissionSpectrum(wavelength) * reflectanceSpectrum(wavelength)

    reflectedLightRGB = AS.Color.SRGB.getRGBForXYZ reflectedLightXYZ
    reflectedLightStyle = "rgb(#{reflectedLightRGB.r * 255}, #{reflectedLightRGB.g * 255}, #{reflectedLightRGB.b * 255})"

    context.beginPath()
    context.moveTo incidentPoint.x, incidentPoint.y
    context.lineTo incidentPoint.clone().addScaledVector(reflectedLightDirection, 200).toArray()...
    context.strokeStyle = reflectedLightStyle
    context.stroke()

    # Draw surface.
    context.beginPath()
    context.moveTo incidentPoint.clone().addScaledVector(surfaceTangent, 200).toArray()...
    context.lineTo incidentPoint.clone().addScaledVector(surfaceTangent, -200).toArray()...
    context.strokeStyle = 'gainsboro'
    context.lineWidth = 1
    context.globalAlpha = 0.2
    context.stroke()

    context.translate incidentPoint.x, incidentPoint.y
    context.rotate surfaceNegativeNormal.angle()
    context.fillStyle = reflectedLightStyle
    context.globalAlpha = 0.05

    if vacuumToMaterial
      context.fillRect 0, -200, 400, 400

    else
      context.fillRect -400, -200, 400, 400

    context.globalAlpha = 1
