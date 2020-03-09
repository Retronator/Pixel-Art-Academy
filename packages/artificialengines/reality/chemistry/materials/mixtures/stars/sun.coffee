AR = Artificial.Reality

class AR.Chemistry.Materials.Mixtures.Stars.Sun extends AR.Chemistry.Materials.Mixtures.GasMixture
  @id: -> 'Artificial.Reality.Chemistry.Materials.Mixtures.Stars.Sun'

  @displayName: -> "sun (mixture)"

  @initialize
    relativeGasVolumes:
      "#{AR.Chemistry.Materials.Elements.Hydrogen.id()}": 73.46
      "#{AR.Chemistry.Materials.Elements.Helium.id()}": 24.85
      "#{AR.Chemistry.Materials.Elements.Oxygen.id()}": 0.77
