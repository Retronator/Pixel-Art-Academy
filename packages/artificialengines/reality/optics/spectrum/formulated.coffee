AR = Artificial.Reality

# A formulated spectrum computes values for wavelengths based on a formula.
class AR.Optics.Spectrum.Formulated extends AR.Optics.Spectrum
  constructor: (@formula) ->
    super arguments...

  getValue: (wavelength) ->
    @formula wavelength
