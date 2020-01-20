AE = Artificial.Everywhere
AR = Artificial.Reality

# Spectrum is a function of values for wavelengths.
class AR.Optics.Spectrum
  getValue: (wavelength) -> throw new AE.NotImplementedException "Spectrum must provide a value for a given wavelength."
