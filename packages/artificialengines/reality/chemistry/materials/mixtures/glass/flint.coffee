AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "<a href=\"http://refractiveindex.info/download/data/2017/schott_2017-01-20b.agf\">SCHOTT Zemax catalog 2017-01-20b</a> (obtained from <a href=\"http://www.schott.com/advanced_optics/english/download/\">http://www.schott.com</a>)<br>See also <a href=\"http://refractiveindex.info/download/data/2017/schott_2017-01-20.pdf\">SCHOTT glass data sheets</a>"

class AR.Chemistry.Materials.Mixtures.Glass.Flint extends AR.Chemistry.Materials.Mixtures.Glass
  @id: -> 'Artificial.Reality.Chemistry.Materials.Mixtures.Glass.Flint'

  @displayName: -> "flint glass"
  @formula: -> 'BAF10'

  @initialize
    sellmeierCoefficients: '0 1.5851495 0.00926681282 0.143559385 0.0424489805 1.08521269 105.613573'
    table: """
      0.350 5.1305E-06
      0.365 1.3607E-06
      0.370 9.6691E-07
      0.380 5.0260E-07
      0.390 2.7701E-07
      0.400 1.6276E-07
      0.405 1.3583E-07
      0.420 8.2721E-08
      0.436 6.5355E-08
      0.460 4.9135E-08
      0.500 3.0530E-08
      0.546 1.7467E-08
      0.580 1.8555E-08
      0.620 1.7842E-08
      0.660 2.1114E-08
      0.700 1.3409E-08
      1.060 2.0305E-08
      1.530 9.8390E-08
      1.970 5.2286E-07
      2.325 2.8542E-06
      2.500 6.3543E-06
    """
