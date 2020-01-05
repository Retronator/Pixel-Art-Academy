AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "E. R. Peck and B. N. Khanna. Dispersion of nitrogen, <a href=\"https://doi.org/10.1364/JOSA.56.001059\"><i>J. Opt. Soc. Am.</i> <b>56</b>, 1059-1063 (1966)</a>"
# COMMENTS: "15 Â°C, 760 torr (101.325 kPa)"

class AR.Chemistry.Materials.Elements.Nitrogen extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Nitrogen'

  @displayName: -> "nitrogen"
  @formula: -> 'N₂'

  @initialize
    sellmeierCoefficients: '0 6.497378E-5 3.0738649E-2 144'
    standardMolarVolume: 0.02239 # m³/mol
