AE = Artificial.Everywhere
AR = Artificial.Reality

# Spectrum is a function of values for wavelengths.
class AR.Optics.Spectrum
  getValue: (wavelength) -> throw new AE.NotImplementedException "Spectrum must provide a value for a given wavelength."

  toXYZ: ->
    Artificial.Spectrum.Color.XYZ.getXYZForSpectrum @

  @matchesType: ->
    # Override to return true when two spectrums have the same internal
    # structure. This allows optimized manipulations in some cases.
    false
