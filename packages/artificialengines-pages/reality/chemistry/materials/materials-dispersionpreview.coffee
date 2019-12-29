AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  @register 'Artificial.Reality.Pages.Chemistry.Materials'

  drawDispersionPreview: ->
    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.fillStyle = 'black'
    context.fillRect 0, 0, canvas.width, canvas.height

    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    refractiveIndexOutside = 1
    extinctionCoefficientOutside = 0

    materialClass = @materialClass()
    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

    reflectanceSpectrum = (wavelength) =>
      refractiveIndexMaterial = refractiveIndexSpectrum wavelength
      extinctionCoefficientMaterial = extinctionCoefficientSpectrum? wavelength

      AR.Optics.FresnelEquations.getReflectance angleOfIncidence, refractiveIndexOutside, refractiveIndexMaterial, extinctionCoefficientOutside, extinctionCoefficientMaterial

    transmissionSpectrum = (wavelength) =>
      1 - reflectanceSpectrum wavelength

    surfaceNormal = new THREE.Vector2(-1, 0).normalize()
    surfaceNegativeNormal = surfaceNormal.clone().negate()
    incidentPoint = new THREE.Vector2(canvas.width / 2 + 0.5, canvas.height / 2)
    surfaceTangent = new THREE.Vector2(-surfaceNormal.y, surfaceNormal.x)

    incidentLightDirection = new THREE.Vector2(1, -1).normalize()
    reflectedLightDirection = incidentLightDirection.clone().addScaledVector(surfaceNormal, -2 * incidentLightDirection.dot(surfaceNormal))
    angleOfIncidence = _.angleDifference incidentLightDirection.angle(), surfaceNegativeNormal.angle()

    imageData = context.getImageData 0, 0, canvas.width, canvas.height

    dTop = new THREE.Vector2
    dBottom = new THREE.Vector2

    minRefractiveIndex = null
    maxRefractiveIndex = null

    refractedLightSpectrum = (wavelength) =>
      refractiveIndex = refractiveIndexSpectrum wavelength
      return 0 unless minRefractiveIndex < refractiveIndex < maxRefractiveIndex

      D65EmissionSpectrum(wavelength) * transmissionSpectrum(wavelength)

    for x in [0...canvas.width]
      for y in [-1...canvas.height]
        dTop.copy dBottom
        angleTop = angleBottom

        dBottom.set(x, y + 1).sub(incidentPoint)
        angleBottom = _.angleDistance dBottom.angle(), surfaceNegativeNormal.angle()

        # Don't color the first line.
        continue if y is -1

        # Don't color outside the material.
        continue if angleTop > Math.PI / 2 or angleBottom > Math.PI / 2

        refractiveIndexTop = refractiveIndexBottom
        angleOfRefractionBottom = _.angleDifference dBottom.angle(), surfaceNegativeNormal.angle()

        if angleOfRefractionBottom
          refractiveIndexBottom = Math.sin(angleOfIncidence) * refractiveIndexOutside / Math.sin(angleOfRefractionBottom)

        else
          refractiveIndexBottom = Number.POSITIVE_INFINITY

        # Don't color on the other side of the ray.
        continue if refractiveIndexTop < 0 or refractiveIndexBottom < 0

        minRefractiveIndex = Math.min refractiveIndexBottom, refractiveIndexTop
        maxRefractiveIndex = Math.max refractiveIndexBottom, refractiveIndexTop

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
    context.globalAlpha = 0.1
    context.fillRect 0, -200, 400, 400

    context.globalAlpha = 1
