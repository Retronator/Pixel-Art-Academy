AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "1) C. Cuthbertson and M. Cuthbertson. The refraction and dispersion of neon and helium. <a href=\"https://doi.org/10.1098/rspa.1932.0019\"><i>Proc. R. Soc. London A</i> <b>135</b>, 40-47 (1936)</a><br><br>2) C. Cuthbertson and M. Cuthbertson. On the refraction and dispersion of neon. <a href=\"https://doi.org/10.1098/rspa.1910.0001\"><i>Proc. R. Soc. London A</i> <b>83</b>, 149-151 (1910)</a><br><br><sup>*</sup> Ref. 1 doesn't cite gas temperature and pressure. See the earlier publication by the same authors (ref. 2) instead."
# COMMENTS: "Standard conditions: 0 Â°C, 760 torr (101.325 kPa)."

class AR.Chemistry.Materials.Elements.Helium extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Helium'

  @displayName: -> "helium"
  @formula: -> 'He'

  @initialize
    dispersion:
      coefficients: [0, 0.014755297, 426.29740]
      temperature: AR.Celsius 0
      pressure: 101325
    vanDerWaalsConstants:
      a: 0.0346 * AR.Liter ** 2 * AR.Bar
      b: 0.0238 * AR.Liter
