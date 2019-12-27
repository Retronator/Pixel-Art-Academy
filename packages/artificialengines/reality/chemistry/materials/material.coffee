AE = Artificial.Everywhere
AR = Artificial.Reality

class AR.Chemistry.Materials.Material
  @id: -> throw new AE.NotImplementedException 'Material must have an ID.'

  @displayName: -> null # Override to provide a name of the material.
  @formula: -> null # Override to provide a chemical formula of the material.

  @initialize: ->
    AR.Chemistry.Materials.registerMaterial @

  @getRefractiveIndexSpectrum: -> throw new AE.NotImplementedException "Material must provide a function of refractive index per wavelength."

  @getExtinctionCoefficientSpectrum: -> null # Override to provide a function of k per wavelength. 0 is assumed otherwise.
