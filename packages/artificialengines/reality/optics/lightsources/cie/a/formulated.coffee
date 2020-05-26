AR = Artificial.Reality

class AR.Optics.LightSources.CIE.A.Formulated extends AR.Optics.LightSources.LightSource
  @correlatedColorTemperature = 2855.54 # K

  @getRelativeEmissionSpectrum: ->
    # Return radiance in W / sr⋅m³
    new AR.Optics.Spectrum.Formulated (wavelength) ->
      λ = wavelength * 1e9
      e = Math.E

      #             1.435×10⁷
      #             ---------
      #             2848×560
      #     ⎛560⎞⁵ e          - 1
      # 100 ⎜---⎟  --------------
      #     ⎝ λ ⎠   1.435×10⁷
      #             ---------
      #               2848λ
      #            e          - 1
      100 * (560 / λ) ** 5 * (e ** (1.435e7 / (2848 * 560)) - 1) / (e ** (1.435e7 / (2848 * λ)) - 1)
