AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "E. R. Peck and D. J. Fisher. Dispersion of argon, <a href=\"https://doi.org/10.1364/JOSA.54.001362\"><i>J. Opt. Soc. Am.</i> <b>54</b>, 1362-1364 (1964)</a>"
# COMMENTS: "Standard conditions: 0 Â°C, 760 torr (101.325 kPa)."

class AR.Chemistry.Materials.Elements.Argon extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Argon'

  @displayName: -> "argon"
  @formula: -> 'Ar'

  @initialize
    dispersion:
      coefficients: [6.7867e-5, 3.0182943e-2, 144]
      temperature: AR.Celsius 0
      pressure: 101325
    vanDerWaalsConstants:
      a: 1.355 * AR.Liter ** 2 * AR.Bar
      b: 0.03201 * AR.Liter
