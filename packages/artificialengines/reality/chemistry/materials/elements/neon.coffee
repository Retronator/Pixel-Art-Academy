AR = Artificial.Reality

# Adapted from refractiveindex.info database.
# Refractiveindex.info database is in the public domain.
# Copyright and related rights waived via CC0 1.0.
#
# REFERENCES: "1) A. Bideau-Mehu, Y. Guern, R. Abjean, A. Johannin-Gilles. Measurement of refractive indices of neon, argon, krypton and xenon in the 253.7-140.4 nm wavelength range. Dispersion relations and estimated oscillator strengths of the resonance lines. <a href=\"https://doi.org/10.1016/0022-4073(81)90057-1\"><i>J. Quant. Spectrosc. Rad. Transfer</i> <b>25</b>, 395-402 (1981)</a><br><br>2) C. Cuthbertson and M. Cuthbertson. The refraction and dispersion of neon and helium. <a href=\"https://doi.org/10.1098/rspa.1932.0019\"><i>Proc. R. Soc. London A</i> <b>135</b>, 40-47 (1936)</a><br><br><sup>*</sup> Sellmeier formula is derived by the authors of ref. 1 using their own data in the 0.1404-0.2537 Î¼m range combined with data from ref. 2 at longer wavelengths.<br><br><sup>**</sup> A misprint is corrected in the Sellmeier formula: \"182.90\" is replaced by \"1.8290\" in the nominator of the second term before converting the formula to the form used in the refractiveindex.info database."
# COMMENTS: "Standard conditions: 0 Â°C, 760 torr (101.325 kPa)."

class AR.Chemistry.Materials.Elements.Neon extends AR.Chemistry.Materials.Gas
  @id: -> 'Artificial.Reality.Chemistry.Materials.Elements.Neon'

  @displayName: -> "neon"
  @formula: -> 'Ne'

  @initialize
    dispersion:
      coefficients: [0, 0.00128145, 184.661, 0.0220486, 376.840]
      temperature: AR.Celsius 0
      pressure: 101325
    vanDerWaalsConstants:
      a: 0.2135 * AR.Liter ** 2 * AR.Bar
      b: 0.01709 * AR.Liter
