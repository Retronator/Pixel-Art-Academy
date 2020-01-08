AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "E. R. Peck and B. N. Khanna. Dispersion of nitrogen, <a href=\"https://doi.org/10.1364/JOSA.56.001059\"><i>J. Opt. Soc. Am.</i> <b>56</b>, 1059-1063 (1966)</a>"
# COMMENTS: "Standard conditions: 0 Â°C, 760 torr (101.325 kPa)."

class AR.Chemistry.Materials.Elements.Nitrogen extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Nitrogen'

  @displayName: -> "nitrogen"
  @formula: -> 'N₂'

  @initialize
    dispersion:
      coefficients: [6.8552e-5, 3.243157e-2, 144]
      temperature: AR.Celsius 0
      pressure: 101.325e3
    standardMolarVolume: 0.02239 # m³ / mol
    vanDerWaalsConstants:
      a: 1.370 * AR.Liter ** 2 * AR.Bar / AR.Mole ** 2
      b: 0.0387 * AR.Liter / AR.Mole
