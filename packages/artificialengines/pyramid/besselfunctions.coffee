AP = Artificial.Pyramid
π = Math.PI
e = Math.E

class AP.BesselFunctions
  #         1 ⌠π                   sinαπ ⌠π  -x sinht - αt
  # J𝛼(x) = - ⎮  cos(ατ-xsinτ)dτ - ----- ⎮  e              dt
  #         π ⌡0                     π   ⌡0
  @J: (α, x, minimumSpacing = 0.01) ->
    integral1 = AP.Integration.integrateWithMidpointRule (τ) ->
      Math.cos(α * τ - x * Math.sin(τ))
    ,
      0, π, minimumSpacing

    integral2 = AP.Integration.integrateWithMidpointRule (t) ->
      e ** (-x * Math.sinh(t) - α * t)
    ,
      0, π, minimumSpacing

    (integral1 - Math.sin(α * π) * integral2) / π

  #         J𝛼(x)cos(απ) - J₋𝛼(x)
  # Y𝛼(x) = ---------------------
  #                sin(απ)
  @Y: (α, x, minimumSpacing = 0.01) ->
    απ = α * π

    (@J(α, x, minimumSpacing) * Math.cos(απ) - @J(-α, x, minimumSpacing)) / Math.sin(απ)
