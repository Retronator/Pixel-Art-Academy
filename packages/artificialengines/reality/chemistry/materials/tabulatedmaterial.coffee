AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.TabulatedMaterial extends AR.Chemistry.Materials.Material
  @initialize: (table) ->
    super arguments...

    rows = table.split '\n'

    refractiveIndices = []
    extinctionCoefficients = null

    for row in rows
      values = row.split ' '
      wavelengthMicrometers = parseFloat values[0]
      wavelength = wavelengthMicrometers / 1e6

      refractiveIndex = parseFloat values[1]
      refractiveIndices.push {wavelength, value: refractiveIndex}

      if values[2]?
        extinctionCoefficient = parseFloat values[2]
        extinctionCoefficients ?= []
        extinctionCoefficients.push {wavelength, value: extinctionCoefficient}

    # Create the linearly interpolated functions to query the values at any x.
    @_refractiveIndexSpectrum = new AR.Optics.Spectrum.Sampled refractiveIndices
    @_extinctionCoefficientSpectrum = new AR.Optics.Spectrum.Sampled extinctionCoefficients if extinctionCoefficients

  @getRefractiveIndexSpectrum: -> @_refractiveIndexSpectrum
  @getExtinctionCoefficientSpectrum: -> @_extinctionCoefficientSpectrum
