AP = Artificial.Pyramid
AR = Artificial.Reality

sinθ = new AP.ComplexNumber

class AR.Optics.SnellsLaw
  @getAngleOfRefraction: (angleOfIncidence, refractiveIndex1, refractiveIndex2) ->
    #        n₁sinθ
    # arcsin ------
    #          n₂
    θ = angleOfIncidence
    n1 = refractiveIndex1
    n2 = refractiveIndex2

    Math.asin n1 * Math.sin(θ) / n2

  @getComplexAngleOfRefraction: (angleOfIncidence, complexRefractiveIndex1, complexRefractiveIndex2, result) ->
    n1 = complexRefractiveIndex1
    n2 = complexRefractiveIndex2

    sinθ.set(angleOfIncidence, 0).sin()

    result ?= new AP.ComplexNumber
    result.copy(n1).divide(n2).multiply(sinθ).asin()
