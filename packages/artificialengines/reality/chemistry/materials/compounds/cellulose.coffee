AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "N. Sultanova, S. Kasarova and I. Nikolov. Dispersion properties of optical polymers, <a href=\"http://przyrbwn.icm.edu.pl/APP/ABSTR/116/a116-4-42.html\"><i>Acta Physica Polonica A</i> <b>116</b>, 585-587 (2009)</a><br> (fit of the experimental data with the Sellmeier dispersion formula: Mikhail Polyanskiy)"
# COMMENTS: "20 Â°C"

class AR.Chemistry.Materials.Compounds.Cellulose extends AR.Chemistry.Materials.SellmeierMaterial
  @id: -> 'Artificial.Reality.Chemistry.Materials.Compounds.Cellulose'

  @displayName: -> "cellulose"
  @formula: -> 'C₆H₁₀O₅'

  @initialize
    sellmeierCoefficients: '0 1.124 0.011087'
