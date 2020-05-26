AR = Artificial.Reality

class AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5 extends AR.Optics.Spectrum.UniformlySampled
  @ArrayLength: 81 # = (780 - 380) / 5 + 1

  constructor: (values) ->
    super
      values: values
      startingWavelength: 380e-9
      wavelengthSpacing: 5e-9
