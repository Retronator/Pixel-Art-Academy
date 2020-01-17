AR = Artificial.Reality

class AR.Chemistry.Materials.IdealGas extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.IdealGas'

  @displayName: -> "ideal gas"

  @initialize
    dispersion:
      # Using data for Helium, see elements/helium.coffee for reference.
      coefficients: [0, 0.014755297, 426.29740]
      temperature: AR.Celsius 0
      pressure: 101325
    vanDerWaalsConstants:
      a: 0
      b: 0
