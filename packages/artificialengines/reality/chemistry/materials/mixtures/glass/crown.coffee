AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "<a href=\"http://refractiveindex.info/download/data/2017/schott_2017-01-20b.agf\">SCHOTT Zemax catalog 2017-01-20b</a> (obtained from <a href=\"http://www.schott.com/advanced_optics/english/download/\">http://www.schott.com</a>)<br>See also <a href=\"http://refractiveindex.info/download/data/2017/schott_2017-01-20.pdf\">SCHOTT glass data sheets</a>"
# COMMENTS: "step 0.5 available"

class AR.Chemistry.Materials.Mixtures.Glass.Crown extends AR.Chemistry.Materials.Mixtures.Glass
  @id: -> 'Artificial.Reality.Chemistry.Materials.Mixtures.Glass.Crown'

  @displayName: -> "crown glass"
  @formula: -> 'BK7'

  @initialize
    sellmeierCoefficients: '0 1.03961212 0.00600069867 0.231792344 0.0200179144 1.01046945 103.560653'
    table: """
      0.300 2.8607E-06
      0.310 1.3679E-06
      0.320 6.6608E-07
      0.334 2.6415E-07
      0.350 9.2894E-08
      0.365 3.4191E-08
      0.370 2.7405E-08
      0.380 2.0740E-08
      0.390 1.3731E-08
      0.400 1.0227E-08
      0.405 9.0558E-09
      0.420 9.3912E-09
      0.436 1.1147E-08
      0.460 1.0286E-08
      0.500 9.5781E-09
      0.546 6.9658E-09
      0.580 9.2541E-09
      0.620 1.1877E-08
      0.660 1.2643E-08
      0.700 8.9305E-09
      1.060 1.0137E-08
      1.530 9.8390E-08
      1.970 1.0933E-06
      2.325 4.2911E-06
      2.500 8.1300E-06
    """
