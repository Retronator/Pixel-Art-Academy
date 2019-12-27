AR = Artificial.Reality

class AR.Optics.LightSources.BlackBody
  @getRadianceForTemperature: (temperature) ->
    # Return radiance in W / sr⋅m²
    σ = AR.StefanBoltzmanConstant
    ᴨ = Math.PI
    T = temperature

    #     1
    # σT⁴ -
    #     ᴨ
    σ * T ** 4 / ᴨ

  @getEmissionSpectrumForTemperature: (temperature) ->
    # Return spectral radiance in W / sr⋅m³
    (wavelength) ->
      λ = wavelength
      h = AR.PlanckConstant
      kʙ = AR.BoltzmanConstant
      c = AR.SpeedOfLight
      T = temperature
      e = Math.E

      #   2hc²     1
      #   ---- ---------
      #    λ⁵    hc
      #         ----
      #         λkʙT
      #        e     - 1
      2 * h * c ** 2 / λ ** 5 / (e ** (h * c / (λ * kʙ * T)) - 1)
