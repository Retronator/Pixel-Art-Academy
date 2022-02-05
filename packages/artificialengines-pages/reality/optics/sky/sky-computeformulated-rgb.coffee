AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

SpectrumClass = AR.Optics.Spectrum.RGB
sunEmissionSpectrumRGB = null
rayleighCoefficientSpectrumCacheRGB = []

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeFormulatedRGB: ->
    sunEmissionSpectrumRGB ?= new SpectrumClass().copy @sunEmissionSpectrum

    @_computeFormulatedFast SpectrumClass, sunEmissionSpectrumRGB, rayleighCoefficientSpectrumCacheRGB
