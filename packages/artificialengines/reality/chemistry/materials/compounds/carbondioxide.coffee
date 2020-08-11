AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "A. Bideau-Mehu, Y. Guern, R. Abjean and A. Johannin-Gilles. Interferometric determination of the refractive index of carbon dioxide in the ultraviolet region, <a href=\"https://doi.org/10.1016/0030-4018(73)90289-7\"><i>Opt. Commun.</i> <b>9</b>, 432-434 (1973)</a>"
# COMMENTS: "Standard conditions: 0 Â°C, 760 torr (101.325 kPa)."

class AR.Chemistry.Materials.Compounds.CarbonDioxide extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Compounds.CarbonDioxide'

  @displayName: -> "carbon dioxide"
  @formula: -> 'CO₂'

  @initialize
    dispersion:
      coefficients: [0, 6.99100e-2, 166.175, 1.44720e-3, 79.609, 6.42941e-5, 56.3064, 5.21306e-5, 46.0196, 1.46847e-6, 0.0584738]
      temperature: AR.Celsius 0
      pressure: 101.325e3
    kingCorrectionFactorCoefficients: [1.1364, 25.3e-16]
    vanDerWaalsConstants:
      a: 3.640 * AR.Liter ** 2 * AR.Bar
      b: 0.04267 * AR.Liter
