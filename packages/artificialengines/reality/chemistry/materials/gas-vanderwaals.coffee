AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Chemistry.Materials.Gas extends AR.Chemistry.Materials.Gas
  # Van der Waals equation:
  #
  # ⎛      n²⎞
  # ⎜P + a --⎟ (V - nb) = nRT
  # ⎝      V²⎠
  #
  @getPressureForState: (state) ->
    #       ⎛  an     RT  ⎞
    # P = n ⎜- -- - ------⎟
    #       ⎝  V²   bn - V⎠
    a = @options.vanDerWaalsConstants.a
    b = @options.vanDerWaalsConstants.b
    n = state.amountOfSubstance
    V = state.volume
    T = state.temperature
    R = AR.GasConstant

    n * (-a * n / V ** 2 - R * T / (b * n - V))

  @getTemperatureForState: (state) ->
    #       (bn - V)(an² + PV²)
    # T = - -------------------
    #              nRV²
    a = @options.vanDerWaalsConstants.a
    b = @options.vanDerWaalsConstants.b
    n = state.amountOfSubstance
    V = state.volume
    P = state.pressure
    R = AR.GasConstant

    # Avoid boundary conditions.
    return 0 if V is 0

    -((b * n - V) * (a * n ** 2 + P * V ** 2)) / (n * R * V ** 2)

  @getVolumeForState: (state, significantDigits = 10) ->
    # We have to find the roots of equation
    #        ⎛      n²⎞
    # f(V) = ⎜P + a --⎟ (V - nb) - nRT = 0
    #        ⎝      V²⎠
    a = @options.vanDerWaalsConstants.a
    b = @options.vanDerWaalsConstants.b
    n = state.amountOfSubstance
    T = state.temperature
    P = state.pressure
    R = AR.GasConstant

    f = (V) -> (P + a * n ** 2 / V ** 2) * (V - n * b) - n * R * T

    # First derivative is
    #             an²   2abn³
    # f'(V) = P - --- + ----
    #              V²    V³
    fDerivative = (V) -> P - a * n ** 2 / V ** 2 + 2 * a * b * n ** 3 / V ** 3

    # We use Newton-Raphson to converge towards V where f(V) is 0. For V₀ we use the ideal gas law
    #     nRT
    # V = ---
    #      P
    V0 = n * R * T / P

    # Avoid boundary conditions.
    return 0 if V0 is 0
    return Number.POSITIVE_INFINITY if P is 0

    @_newtonRaphson(f, fDerivative, V0, significantDigits) or V0

  @_newtonRaphson: (f, fDerivative, initialValue, significantDigits) ->
    # We repeat the calculation
    #              f(xᵢ)
    # yᵢ₊₁ = yᵢ - ------
    #             f'(xᵢ)
    # until we reach the desired number of significant digits.
    maximalError = 10 ** (-significantDigits)
    iterationCount = 0
    x = initialValue

    loop
      error = f(x)

      return x if Math.abs(error) < maximalError

      if iterationCount++ > 100
        console.warn "Computing Van der Waals property did not converge."
        return null

      derivative = fDerivative(x)
      if derivative is 0
        console.warn "The derivative of the Van der Waals equation is flat."
        return null

      x -= error / derivative

  @getAmountOfSubstanceForState: (state, significantDigits = 10) ->
    # We have to find the roots of equation as above.
    a = @options.vanDerWaalsConstants.a
    b = @options.vanDerWaalsConstants.b
    V = state.volume
    T = state.temperature
    P = state.pressure
    R = AR.GasConstant

    f = (n) -> (P + a * n ** 2 / V ** 2) * (V - n * b) - n * R * T

    # First derivative is
    #         2an   3abn²
    # f'(n) = --- + ---- - bP - RT
    #          V     V²
    fDerivative = (n) -> 2 * a * n / V + 3 * a * b * n ** 2 / V ** 2 - b * P - R * T

    # For n₀ we use the ideal gas law
    #     VP
    # n = --
    #     RT
    n0 = V * P / (R * T)

    # Avoid boundary conditions.
    return 0 if n0 is 0
    return Number.POSITIVE_INFINITY if R * T is 0

    @_newtonRaphson(f, fDerivative, n0, significantDigits) or n0
