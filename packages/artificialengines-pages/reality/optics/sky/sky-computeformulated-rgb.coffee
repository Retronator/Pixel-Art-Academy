AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

SpectrumClass = AR.Optics.Spectrum.RGB
D65EmissionSpectrumRGB = null
rayleighCoefficientSpectrumCacheRGB = []

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeFormulatedRGB: ->
    D65EmissionSpectrumRGB ?= new SpectrumClass().copy @SunEmissionSpectrum

    @_computeFormulatedFast SpectrumClass, D65EmissionSpectrumRGB, rayleighCoefficientSpectrumCacheRGB
