AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "E. R. Peck and S. Hung. Refractivity and dispersion of hydrogen in the visible and near infrared, <a href=\"https://doi.org/10.1364/JOSA.67.001550\"><i>J. Opt. Soc. Am.</i> <b>67</b>, 1550-1554 (1977)</a>"
# COMMENTS: "Standard conditions. 0 Â°C, 760 torr (101.325 kPa)."

class AR.Chemistry.Materials.Elements.Hydrogen extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Hydrogen'

  @displayName: -> "hydrogen"
  @formula: -> 'H₂'

  @initialize
    dispersion:
      coefficients: [0, 0.0148956, 180.7, 0.0049037, 92]
      temperature: AR.Celsius 0
      pressure: 101325
    vanDerWaalsConstants:
      a: 0.2476 * AR.Liter ** 2 * AR.Bar
      b: 0.02661 * AR.Liter
