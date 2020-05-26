AR = Artificial.Reality

class AR.Chemistry.Materials.Mixtures.Air.MoistMixture3Percent extends AR.Chemistry.Materials.Mixtures.GasMixture
  @id: -> 'Artificial.Reality.Chemistry.Materials.Mixtures.Air.MoistMixture3Percent'

  @displayName: -> "air (moist mixture 3%)"

  @initialize
    relativeGasVolumes:
      "#{AR.Chemistry.Materials.Elements.Nitrogen.id()}": 78.084
      "#{AR.Chemistry.Materials.Elements.Oxygen.id()}": 20.946
      "#{AR.Chemistry.Materials.Elements.Argon.id()}": 0.9340
      "#{AR.Chemistry.Materials.Elements.CarbonDioxide.id()}": 0.041332
      "#{AR.Chemistry.Materials.Compounds.WaterVapor.id()}": 3.09
