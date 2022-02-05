AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Scattering extends AR.Pages.Chemistry.Materials.Scattering
  _initializeRayProperties: ->
    # Automatically update the ray properties when material changes.
    @rayPropertiesDependency = new Tracker.Dependency

    @autorun (computation) =>
      return unless resources = @resources()
      materialClass = @materialClass()
      raysCount = @raysCount()
      schematicView = @schematicView()

      refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
      extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

      for rayIndex in [0...raysCount]
        if schematicView
          wavelengthNanometers = 550

        else
          wavelengthNanometers = 380 + 400 * rayIndex / raysCount

        wavelength = wavelengthNanometers * 1e-9

        rayXYZ = AS.Color.XYZ.getRelativeXYZForWavelength wavelength
        rayRGB = AS.Color.SRGB.getRGBForXYZ rayXYZ

        refractiveIndex = refractiveIndexSpectrum.getValue wavelength
        extinctionCoefficient = extinctionCoefficientSpectrum?.getValue(wavelength) or 0

        pixelOffset = rayIndex * 8
        resources.rayPropertiesData[pixelOffset] = Math.max 0, rayRGB.r
        resources.rayPropertiesData[pixelOffset + 1] = Math.max 0, rayRGB.g
        resources.rayPropertiesData[pixelOffset + 2] = Math.max 0, rayRGB.b
        resources.rayPropertiesData[pixelOffset + 4] = refractiveIndex
        resources.rayPropertiesData[pixelOffset + 5] = extinctionCoefficient

      resources.rayPropertiesDataTexture.needsUpdate = true
      @rayPropertiesDependency.changed()
