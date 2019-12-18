AR = Artificial.Reality

class AR.Optics.LightSources.CIE.A.Formulated extends AR.Optics.LightSources.LightSource
  @correlatedColorTemperature = 2855.54 # K

  @getRelativeEmissionSpectrum: ->
    # Return radiance in W / sr⋅m³
    (wavelength) ->
      λ = wavelength * 1e9

      #             1.435×10⁷
      #             --------- - 1
      #             2848×560
      #     ⎛560⎞⁵ e
      # 100 ⎜---⎟  --------------
      #     ⎝ λ ⎠   1.435×10⁷
      #             --------- - 1
      #               2848λ
      #            e
      100 * Math.pow(560 / λ, 5) * (Math.exp(1.435e7 / (2848 * 560)) - 1) / (Math.exp(1.435e7 / (2848 * λ)) - 1)
