AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Mixtures.GasMixture extends AR.Chemistry.Materials.Gas
  @initialize: (@options) ->
    super arguments...

    refractiveIndexSpectrum = {}
    kingCorrectionFactorSpectrum = {}
    gasVolumeRatios = {}

    @options.vanDerWaalsConstants =
      a: 0
      b: 0

    totalRelativeGasVolume = _.sum _.values @options.relativeGasVolumes

    for gasId, relativeGasVolume of @options.relativeGasVolumes
      gasClass = AR.Chemistry.Materials.getClassForId gasId

      refractiveIndexSpectrum[gasId] = gasClass.getRefractiveIndexSpectrum()
      kingCorrectionFactorSpectrum[gasId] = gasClass.getKingCorrectionFactorSpectrum()

      gasVolumeRatios[gasId] = relativeGasVolume / totalRelativeGasVolume

      @options.vanDerWaalsConstants.a += gasVolumeRatios[gasId] * gasClass.options.vanDerWaalsConstants.a
      @options.vanDerWaalsConstants.b += gasVolumeRatios[gasId] * gasClass.options.vanDerWaalsConstants.b

    @_refractiveIndexSpectrum = (wavelength) ->
      sum = 0

      for gasId, gasVolumeRatio of gasVolumeRatios
        sum += gasVolumeRatio * (refractiveIndexSpectrum[gasId](wavelength) ** 2 - 1)

      Math.sqrt 1 + sum

    @_kingCorrectionFactorSpectrum = (wavelength) ->
      sum = 0

      for gasId, gasVolumeRatio of gasVolumeRatios
        sum += gasVolumeRatio * (kingCorrectionFactorSpectrum[gasId]?(wavelength) or 1)

      sum

  @getRefractiveIndexSpectrum: -> @_refractiveIndexSpectrum

  @getRefractiveIndexSpectrumForState: (state) ->
    TRatio = AR.StandardTemperatureAndPressure.Temperature / state.temperature
    pRatio = state.pressure / AR.StandardTemperatureAndPressure.Pressure

    refractiveIndexSpectrum = @_refractiveIndexSpectrum

    (wavelength) ->
      refractiveIndex = refractiveIndexSpectrum wavelength

      # Derived by assuming constant molar refractivity.
      Math.sqrt 1 + TRatio * pRatio * (refractiveIndex ** 2 - 1)
