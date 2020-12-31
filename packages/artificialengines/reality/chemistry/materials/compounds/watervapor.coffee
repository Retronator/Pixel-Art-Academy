AR = Artificial.Reality

class AR.Chemistry.Materials.Compounds.WaterVapor extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Compounds.WaterVapor'

  @displayName: -> "water vapor"
  @formula: -> 'H₂O'

  @initialize
    dispersion:
      coefficients: [295.235, 2.6422, -0.03238, 0.004028]
      temperature: AR.Celsius 20
      pressure: 1333
    vanDerWaalsConstants:
      a: 5.536 * AR.Liter ** 2 * AR.Bar
      b: 0.03049 * AR.Liter

  @initialize: (@options) ->
    super arguments...

    # Prepare refractive index function based on the supplied dispersion coefficients.
    #            ⎛    B₁   B₂   B₃⎞
    # n(λ) = 1 + ⎜A + -- + -- + --⎟ * 10⁻⁸
    #            ⎝    λ²   λ⁴   λ⁶⎠
    A = @options.dispersion.coefficients[0]
    B = @options.dispersion.coefficients

    @_refractiveIndexSpectrum = new AR.Optics.Spectrum.Formulated (wavelength) ->
      wavelengthFactor = (wavelength * 1e6) ** 2
      wavelengthFactor2 = wavelengthFactor ** 2
      wavelengthFactor3 = wavelengthFactor * wavelengthFactor2

      1 + 1e-8 * (A + B[1] / wavelengthFactor + B[2] / wavelengthFactor2 + B[3] / wavelengthFactor3)
