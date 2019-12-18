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
    σ * Math.pow(T, 4) / ᴨ

  @getEmissionSpectrumForTemperature: (temperature) ->
    # Return spectral radiance in W / sr⋅m³
    (wavelength) ->
      λ = wavelength
      h = AR.PlanckConstant
      kʙ = AR.BoltzmanConstant
      c = AR.SpeedOfLight
      T = temperature

      #   2hc²     1
      #   ---- ---------
      #    λ⁵    hc
      #         ----
      #         λkʙT
      #        e     - 1
      2 * h * Math.pow(c, 2) / Math.pow(λ, 5) / (Math.exp(h * c / (λ * kʙ * T)) - 1)
