AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "P. E. Ciddor. Refractive index of air: new equations for the visible and near infrared, <a href=\"https://doi.org/10.1364/AO.35.001566\"><i>Appl. Optics</i> <b>35</b>, 1566-1573 (1996)</a><br>[<a href=\"https://github.com/polyanskiy/refractiveindex.info-scripts/blob/master/scripts/Ciddor%201996%20-%20air.py\">Calculation script (Python)</a> - can be used for calculating refractive index of air at a given humidity, temperatire, pressure, and CO<sub>2</sub> concentration]"
# COMMENTS: "Standard air: dry air at 15 Â°C, 101.325 kPa and with 450 ppm CO<sub>2</sub> content."

class AR.Chemistry.Materials.Mixtures.Air.DryDirect extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Mixtures.Air.DryDirect'

  @displayName: -> "air (dry)"

  @initialize
    dispersion:
      coefficients: [0, 0.05792105, 238.0185, 0.00167917, 57.362]
      temperature: AR.Celsius 15
      pressure: 101325
    vanDerWaalsConstants:
      a: 1.34e-9
      b: 3.5e-6
