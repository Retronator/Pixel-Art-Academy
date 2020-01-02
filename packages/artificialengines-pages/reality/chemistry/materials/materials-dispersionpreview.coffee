AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  @register 'Artificial.Reality.Pages.Chemistry.Materials'

  prepareDispersionPreview: ->
    @dispersionImage = new AM.Canvas 180, 150
    context = @dispersionImage.context

    context.setTransform 1, 0, 0, 1, 0, 0
    context.fillStyle = 'black'
    context.fillRect 0, 0, @dispersionImage.width, @dispersionImage.height

    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    vacuumToMaterial = @reflectanceType() is @constructor.ReflectanceTypes.VacuumToMaterial
    materialClass = @materialClass()
    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

    @dispersionReflectanceSpectrum = (wavelength) =>
      refractiveIndexMaterial = refractiveIndexSpectrum wavelength
      extinctionCoefficientMaterial = extinctionCoefficientSpectrum? wavelength

      if vacuumToMaterial
        AR.Optics.FresnelEquations.getReflectance angleOfIncidence, 1, refractiveIndexMaterial, 0, extinctionCoefficientMaterial

      else
        AR.Optics.FresnelEquations.getReflectance angleOfIncidence, refractiveIndexMaterial, 1, extinctionCoefficientMaterial, 0

    @dispersionAbsorptanceSpectrum = (wavelength) =>
      refractiveIndexMaterial = refractiveIndexSpectrum wavelength
      extinctionCoefficientMaterial = extinctionCoefficientSpectrum? wavelength
  
      if vacuumToMaterial
        AR.Optics.FresnelEquations.getAbsorptance angleOfIncidence, 1, refractiveIndexMaterial, 0, extinctionCoefficientMaterial
  
      else
        AR.Optics.FresnelEquations.getAbsorptance angleOfIncidence, refractiveIndexMaterial, 1, extinctionCoefficientMaterial, 0

    @dispersionSurfaceNormal = new THREE.Vector2(-1, 0).normalize()
    @dispersionSurfaceNegativeNormal = @dispersionSurfaceNormal.clone().negate()
    @dispersionIncidentPoint = new THREE.Vector2(@dispersionImage.width / 2 + 0.5, @dispersionImage.height / 2 + 0.5)
    @dispersionSurfaceTangent = new THREE.Vector2(-@dispersionSurfaceNormal.y, @dispersionSurfaceNormal.x)
    @dispersionPreviewMagnification = 1e9 # 1px = 1nm

    incidentLightDirection = new THREE.Vector2(2, -1).normalize()
    reflectedLightDirection = incidentLightDirection.clone().addScaledVector(@dispersionSurfaceNormal, -2 * incidentLightDirection.dot(@dispersionSurfaceNormal))
    angleOfIncidence = _.angleDifference incidentLightDirection.angle(), @dispersionSurfaceNegativeNormal.angle()
    sineSquaredAngleOfIncidence = Math.sin(angleOfIncidence) ** 2

    imageData = context.getImageData 0, 0, @dispersionImage.width, @dispersionImage.height

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

      D65EmissionSpectrum(wavelength) * @dispersionAbsorptanceSpectrum(wavelength) * attenuation

    for x in [0...@dispersionImage.width]
      for y in [-1...@dispersionImage.height]
        angleTop = angleBottom
        effectiveRefractiveIndexTop = effectiveRefractiveIndexBottom

        dBottom.set(x, y + 1).sub(@dispersionIncidentPoint)
        angleOfRefractionBottom = _.angleDifference dBottom.angle(), @dispersionSurfaceNegativeNormal.angle()
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

        depth = dBottom.dot(@dispersionSurfaceNegativeNormal) / @dispersionPreviewMagnification

        refractedLightXYZ = AS.Color.CIE1931.getXYZForSpectrum refractedLightSpectrum, 5e-10
        refractedLightRGB = AS.Color.SRGB.getRGBForXYZ refractedLightXYZ

        pixelOffset = (x + y * @dispersionImage.width) * 4
        imageData.data[pixelOffset] = refractedLightRGB.r * 255
        imageData.data[pixelOffset + 1] = refractedLightRGB.g * 255
        imageData.data[pixelOffset + 2] = refractedLightRGB.b * 255

    context.putImageData imageData, 0, 0

    # Draw incident light ray.
    context.beginPath()
    context.moveTo @dispersionIncidentPoint.x, @dispersionIncidentPoint.y
    context.lineTo @dispersionIncidentPoint.clone().addScaledVector(incidentLightDirection, -200).toArray()...
    context.strokeStyle = 'white'
    context.stroke()

    # Draw reflected light ray.
    reflectedLightXYZ = AS.Color.CIE1931.getXYZForSpectrum (wavelength) =>
      D65EmissionSpectrum(wavelength) * @dispersionReflectanceSpectrum(wavelength)

    reflectedLightRGB = AS.Color.SRGB.getRGBForXYZ reflectedLightXYZ
    reflectedLightStyle = "rgb(#{reflectedLightRGB.r * 255}, #{reflectedLightRGB.g * 255}, #{reflectedLightRGB.b * 255})"

    context.beginPath()
    context.moveTo @dispersionIncidentPoint.x, @dispersionIncidentPoint.y
    context.lineTo @dispersionIncidentPoint.clone().addScaledVector(reflectedLightDirection, 200).toArray()...
    context.strokeStyle = reflectedLightStyle
    context.stroke()

    # Draw surface.
    context.translate @dispersionIncidentPoint.x, @dispersionIncidentPoint.y
    context.rotate @dispersionSurfaceNegativeNormal.angle()
    context.fillStyle = reflectedLightStyle
    context.globalAlpha = 0.05

    if vacuumToMaterial
      context.fillRect 0, -200, 400, 400

    else
      context.fillRect -400, -200, 400, 400

    context.globalAlpha = 1

  drawDispersionPreview: ->
    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    offsetLeft = 50
    offsetTop = 10
    context.translate offsetLeft, offsetTop

    context.drawImage @dispersionImage, 0, 0

    # Clip drawing to the graph area.
    context.save()
    context.beginPath()
    context.rect 0, 0, 180, 150
    context.clip()

    # Draw depth line.
    depth = @transmissionDepth()
    depthPreview = depth * @dispersionPreviewMagnification
    depthPoint = @dispersionIncidentPoint.clone().addScaledVector(@dispersionSurfaceNegativeNormal, depthPreview)

    context.beginPath()
    context.moveTo depthPoint.clone().addScaledVector(@dispersionSurfaceTangent, 200).toArray()...
    context.lineTo depthPoint.clone().addScaledVector(@dispersionSurfaceTangent, -200).toArray()...
    context.strokeStyle = 'gainsboro'
    context.lineWidth = 1
    context.globalAlpha = 0.2
    context.stroke()

    # Restore to no clipping.
    context.restore()

    # Draw transmission color.
    materialClass = @materialClass()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()
    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    refractedLightSpectrum = (wavelength) =>
      extinctionCoefficient = extinctionCoefficientSpectrum?(wavelength) or 0

      attenuationCoefficient = 4 * Math.PI * extinctionCoefficient / wavelength
      attenuation = Math.E ** (-attenuationCoefficient * depth)

      D65EmissionSpectrum(wavelength) * @dispersionAbsorptanceSpectrum(wavelength) * attenuation

    xyz = AS.Color.CIE1931.getXYZForSpectrum refractedLightSpectrum
    rgb = AS.Color.SRGB.getRGBForXYZ xyz
    context.fillStyle = "rgba(#{rgb.r * 255}, #{rgb.g * 255}, #{rgb.b * 255}, 0.5)"

    context.fillRect 160, 130, 15, 15

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, 180, 150

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "depth (nm)", 90, 190

    context.beginPath()

    directionToAxis = new THREE.Vector2(0, 1)

    for depthNanometers in [-100..100] by 20
      # Write the number on the axis.
      depthPreview = depthNanometers / 1e9 * @dispersionPreviewMagnification
      depthPoint = @dispersionIncidentPoint.clone().addScaledVector(@dispersionSurfaceNegativeNormal, depthPreview)
      distanceToAxis = 150 - depthPoint.y
      tangentScalar = distanceToAxis / @dispersionSurfaceTangent.dot(directionToAxis)
      axisPoint = depthPoint.clone().addScaledVector(@dispersionSurfaceTangent, tangentScalar)

      continue unless 0 < axisPoint.x < 180

      context.textAlign = 'center'
      context.fillText depthNanometers, axisPoint.x, 166
