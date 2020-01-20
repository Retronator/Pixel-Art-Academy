AP = Artificial.Pyramid
AR = Artificial.Reality

# A sampled spectrum linearly interpolates the values between provided sample points (at arbitrary wavelengths).
class AR.Optics.Spectrum.Sampled extends AR.Optics.Spectrum.Formulated
  constructor: (samples) ->
    points = for sample in samples
      x: sample.wavelength
      y: sample.value

    calculation = AP.Interpolation.PiecewisePolynomial.getFunctionForPoints points, 1, AP.Interpolation.PiecewisePolynomial.ExtrapolationTypes.Constant

    super calculation

  @matchesType: ->
    # Override to return true when two spectrums have the same internal
    # structure. This allows optimized manipulations in some cases.
    false
