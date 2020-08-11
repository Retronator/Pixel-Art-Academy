AR = Artificial.Reality

class AR.Chemistry.Materials.Mixtures.Air.MarsMixture extends AR.Chemistry.Materials.Mixtures.GasMixture
  @id: -> 'Artificial.Reality.Chemistry.Materials.Mixtures.Air.MarsMixture'

  @displayName: -> "martian air (mixture)"

  @initialize
    relativeGasVolumes:
      "#{AR.Chemistry.Materials.Compounds.CarbonDioxide.id()}": 95.32
      "#{AR.Chemistry.Materials.Elements.Nitrogen.id()}": 2.6
      "#{AR.Chemistry.Materials.Elements.Argon.id()}": 1.9
      "#{AR.Chemistry.Materials.Elements.Oxygen.id()}": 0.174
