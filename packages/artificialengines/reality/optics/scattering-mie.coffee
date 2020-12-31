AP = Artificial.Pyramid
AR = Artificial.Reality

# Portions based on PyMieScatt
# https://github.com/bsumlin/PyMieScatt
class AR.Optics.Scattering extends AR.Optics.Scattering
  @getMieCrossSectionsAndAsymmetry: (refractiveIndex, extinctionCoefficient, wavelength, diameter, refractiveIndexMedium = 1) ->
    m = new AP.ComplexNumber refractiveIndex, extinctionCoefficient
    m.divideReal refractiveIndexMedium
    wavelength /= refractiveIndexMedium

    # Convert to nanometers.
    wavelength *= 1e9
    diameter *= 1e9

    x = Math.PI * diameter / wavelength

    createResult = (extinction, scattering, absorption, asymmetry) ->
      # Convert to meters squared.
      extinction /= 1e18
      scattering /= 1e18
      absorption /= 1e18

      {extinction, scattering, absorption, asymmetry}

    if x is 0
      createResult 0, 0, 0, 1.5

    else if x <= 0.05
      {extinction, scattering, absorption} = @_getMieRayleighCrossSections m, wavelength, diameter
      createResult extinction, scattering, absorption, 0

    else
      nMax = Math.round( 2 + x + 4 * (x ** (1 / 3)))

      n = [[], [], [], []]

      for i in [1..nMax]
        n1 = 2 * i + 1
        n[0].push i
        n[1].push n1
        n[2].push i * (i + 2) / (i + 1)
        n[3].push n1 / (i * (i + 1))

      x2 = x ** 2

      {an, bn} = @_getMieExternalFieldCoefficients m, x

      qExtinctionSum = 0
      qScatteringSum = 0

      aaa = for n1, i in n[1]
        qExtinctionSum += n1 * (an[i].real + bn[i].real)
        qScatteringSum += n1 * (an[i].real ** 2 + an[i].imaginary ** 2 + bn[i].real ** 2 + bn[i].imaginary ** 2)

        n1 * (an[i].real + bn[i].real)

      qExtinction = (2 / x2) * qExtinctionSum
      qScattering = (2 / x2) * qScatteringSum
      qAbsorption = qExtinction - qScattering

      crossSection = Math.PI * (diameter / 2) ** 2
      extinction = crossSection * qExtinction
      scattering = crossSection * qScattering
      absorption = crossSection * qAbsorption

      g1 = [
        (a.real for a in an[1...nMax])
        (a.imaginary for a in an[1...nMax])
        (b.real for b in bn[1...nMax])
        (b.imaginary for b in bn[1...nMax])
      ]

      g.push 0 for g in g1

      asymmetrySum = 0

      for n2, i in n[2]
        n3 = n[3][i]
        asymmetrySum += n2 * (an[i].real * g1[0][i] + an[i].imaginary * g1[1][i] + bn[i].real * g1[2][i] + bn[i].imaginary * g1[3][i])
        asymmetrySum += n3 * (an[i].real * bn[i].real + an[i].imaginary * bn[i].imaginary)

      asymmetry = 4 / (qScattering * x2) * asymmetrySum

      createResult extinction, scattering, absorption, asymmetry

  @_getMieExternalFieldCoefficients: (m, x) ->
    mx = m.clone().multiplyReal(x)

    nMax = Math.round(2 + x + 4 * (x ** (1 / 3)))
    nmx = Math.round(Math.max(nMax, mx.absoluteValue()) + 16)
    n = [1..nMax]
    nu = (i + 0.5 for i in n)

    sx = Math.sqrt(0.5 * Math.PI * x)

    j1 = (AP.BesselFunctions.J(i, x) for i in nu)
    j2 = (AP.BesselFunctions.Y(i, x) for i in nu)

    px = (sx * AP.BesselFunctions.J(i, x) for i in nu)
    p1x = [Math.sin(x), px...]

    chx = (-sx * AP.BesselFunctions.Y(i, x) for i in nu)
    ch1x = [Math.cos(x), chx...]

    gsx = []
    gs1x = []

    for i in [0...nMax]
      gsx.push new AP.ComplexNumber(px[i], 0).subtract AP.ComplexNumber.I.clone().multiplyReal chx[i]
      gs1x.push new AP.ComplexNumber(p1x[i], 0).subtract AP.ComplexNumber.I.clone().multiplyReal ch1x[i]

    Dn = (new AP.ComplexNumber for i in [0...nmx])

    t1 = new AP.ComplexNumber
    t2 = new AP.ComplexNumber
    t3 = new AP.ComplexNumber

    for i in [nmx - 1...1]
      t1.set(i, 0).divide(mx)
      t2.copy(Dn[i]).add(t1)
      t3.set(1, 0).divide(t2)
      Dn[i - 1].copy(t1).subtract(t3)

    an = []
    bn = []

    for d, i in Dn[1..nMax]
      da = new AP.ComplexNumber().copy(d).divide(m).addReal(n[i] / x)
      db = new AP.ComplexNumber().copy(m).multiply(d).addReal(n[i] / x)

      t1.copy(da).multiplyReal(px[i]).subtractReal(p1x[i])
      t2.copy(da).multiply(gsx[i]).subtract(gs1x[i])
      an.push new AP.ComplexNumber().copy(t1).divide(t2)

      t1.copy(db).multiplyReal(px[i]).subtractReal(p1x[i])
      t2.copy(db).multiply(gsx[i]).subtract(gs1x[i])
      bn.push new AP.ComplexNumber().copy(t1).divide(t2)

    {an, bn}

  @_getMieRayleighCrossSections: (m, wavelength, diameter) ->
    x = Math.PI * diameter / wavelength
    m = m.clone()
    m2 = m.clone().pow2()

    t1 = new AP.ComplexNumber().copy(m2).subtractReal(1)
    t2 = new AP.ComplexNumber().copy(m2).addReal(2)

    LL = new AP.ComplexNumber().copy(t1).divide(t2)
    LLabsSq = LL.absoluteValue() ** 2

    qScattering = 8 * LLabsSq * (x ** 4) / 3
    qAbsorption = 4 * x * LL.imaginary
    qExtinction = qScattering + qAbsorption

    crossSection = Math.PI * (diameter / 2) ** 2
    extinction = crossSection * qExtinction
    scattering = crossSection * qScattering
    absorption = crossSection * qAbsorption

    {extinction, scattering, absorption}

  @getMiePhaseFunctionForAsymmetry: (asymmetry) ->
    #  3 (1-g²)(1+μ²)
    # -- -------------------
    # 8π                 3/2
    #    (2+g²)(1+g²-2gμ)
    g = asymmetry
    g2 = g ** 2

    normalizationFactor = 3 * (1 - g2) / (8 * Math.PI * (2 + g2))

    (scatteringAngle) ->
      μ = Math.cos scatteringAngle
      μ2 = μ ** 2

      normalizationFactor * (1 + μ2) / ((1 + g2 - 2 * g * μ) ** 1.5)
