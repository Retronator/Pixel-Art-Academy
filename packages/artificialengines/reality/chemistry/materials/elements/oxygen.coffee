AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "1) J. Zhang, Z. H. Lu, and L. J. Wang. Precision refractive index measurements of air, N<sub>2</sub>, O<sub>2</sub>, Ar, and CO<sub>2</sub> with a frequency comb, <a href=\"https://doi.org/10.1364/AO.47.003143\"><i>Appl. Opt.</i> <b>47</b>, 3143-3151 (2008)</a><br>2) P. KÅ™en. Comment on \"Precision refractive index measurements of air, N<sub>2</sub>, O<sub>2</sub>, Ar, and CO<sub>2</sub> with a frequency comb\", <a href=\"https://doi.org/10.1364/AO.50.006484\"><i>Appl. Opt.</i> <b>50</b>, 6484-6485 (2011)</a>"
# COMMENTS: "Standard conditions: 20 Â°C, 101 325 Pa."

class AR.Chemistry.Materials.Elements.Oxygen extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Oxygen'

  @displayName: -> "oxygen"
  @formula: -> 'O₂'

  @initialize
    dispersion:
      coefficients: [1.181494e-4, 9.708931e-3, 75.4]
      temperature: AR.Celsius 20
      pressure: 101.325e3
    kingCorrectionFactorCoefficients: [1.096, 1.385e-15, 1.448e-28]
    vanDerWaalsConstants:
      a: 1.382 * AR.Liter ** 2 * AR.Bar
      b: 0.03186 * AR.Liter
