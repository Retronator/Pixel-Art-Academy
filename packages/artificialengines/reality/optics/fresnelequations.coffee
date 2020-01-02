AR = Artificial.Reality
AP = Artificial.Pyramid

complexAngleOfReflection = new AP.ComplexNumber
n1 = new AP.ComplexNumber
n2 = new AP.ComplexNumber
sinθi = new AP.ComplexNumber
sinθj = new AP.ComplexNumber
cosθi = new AP.ComplexNumber
cosθj = new AP.ComplexNumber
n1cosθi = new AP.ComplexNumber
n2cosθj = new AP.ComplexNumber
n1cosθj = new AP.ComplexNumber
n2cosθi = new AP.ComplexNumber
numerator = new AP.ComplexNumber
denominator = new AP.ComplexNumber
fraction = new AP.ComplexNumber

class AR.Optics.FresnelEquations
  @getReflectanceS: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1 = 0, extinctionCoefficient2 = 0) ->
    @_prepareCommonVariables angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2
    @_getReflectanceS()

  @_prepareCommonVariables: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2) ->
    n1.set refractiveIndex1, extinctionCoefficient1
    n2.set refractiveIndex2, extinctionCoefficient2
    AR.Optics.SnellsLaw.getComplexAngleOfRefraction angleOfIncidence, n1, n2, complexAngleOfReflection

    cosθi.set(angleOfIncidence, 0).cos()
    cosθj.copy(complexAngleOfReflection).cos()

  @_getReflectanceS: ->
    # |n₁cosθᵢ-n₂cosθⱼ|²
    # |---------------|
    # |n₁cosθᵢ+n₂cosθⱼ|
    n1cosθi.copy(n1).multiply(cosθi)
    n2cosθj.copy(n2).multiply(cosθj)

    numerator.copy(n1cosθi).subtract(n2cosθj)
    denominator.copy(n1cosθi).add(n2cosθj)

    fraction.copy(numerator).divide(denominator)

    fraction.absoluteValue() ** 2

  @getReflectanceP: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1 = 0, extinctionCoefficient2 = 0) ->
    @_prepareCommonVariables angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2
    @_getReflectanceP()

  @_getReflectanceP: ->
    # |n₁cosθᵢ-n₂cosθⱼ|²
    # |---------------|
    # |n₁cosθᵢ+n₂cosθⱼ|
    n1cosθj.copy(n1).multiply(cosθj)
    n2cosθi.copy(n2).multiply(cosθi)

    numerator.copy(n1cosθj).subtract(n2cosθi)
    denominator.copy(n1cosθj).add(n2cosθi)

    fraction.copy(numerator).divide(denominator)

    fraction.absoluteValue() ** 2

  @getReflectance: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1 = 0, extinctionCoefficient2 = 0) ->
    @_prepareCommonVariables angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2

    reflectanceS = @_getReflectanceS()
    reflectanceP = @_getReflectanceP()

    (reflectanceS + reflectanceP) / 2

  @_getAbsorptanceS: ->
    # n₂cosθⱼ |   2n₁cosθᵢ    |²
    # ------- |---------------|
    # n₁cosθᵢ |n₁cosθᵢ+n₂cosθⱼ|
    n1cosθi.copy(n1).multiply(cosθi)
    n2cosθj.copy(n2).multiply(cosθj)

    numerator.copy(n1cosθi).multiplyReal(2)
    denominator.copy(n1cosθi).add(n2cosθj)

    fraction.copy(numerator).divide(denominator)

    scalar = fraction.absoluteValue() ** 2

    fraction.copy(n2cosθj).divide(n1cosθi).real * scalar

  @getAbsorptanceS: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1 = 0, extinctionCoefficient2 = 0) ->
    @_prepareCommonVariables angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2
    @_getAbsorptanceS()

  @_getAbsorptanceP: ->
    # n₂cosθⱼ |   2n₁cosθᵢ    |²
    # ------- |---------------|
    # n₁cosθᵢ |n₂cosθᵢ+n₁cosθⱼ|
    n1cosθi.copy(n1).multiply(cosθi)
    n2cosθj.copy(n2).multiply(cosθj)
    n1cosθj.copy(n1).multiply(cosθj)
    n2cosθi.copy(n2).multiply(cosθi)

    numerator.copy(n1cosθi).multiplyReal(2)
    denominator.copy(n2cosθi).add(n1cosθj)

    fraction.copy(numerator).divide(denominator)

    scalar = fraction.absoluteValue() ** 2

    fraction.copy(n2cosθj).divide(n1cosθi).real * scalar

  @getAbsorptanceP: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1 = 0, extinctionCoefficient2 = 0) ->
    @_prepareCommonVariables angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2
    @_getAbsorptanceS()

  @getAbsorptance: (angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1 = 0, extinctionCoefficient2 = 0) ->
    @_prepareCommonVariables angleOfIncidence, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2

    absorptanceS = @_getAbsorptanceS()
    absorptanceP = @_getAbsorptanceP()

    (absorptanceS + absorptanceP) / 2
