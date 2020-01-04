AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Optics.Scattering extends AM.Component
  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @materialId = new ReactiveField AR.Chemistry.Materials.Elements.Nitrogen.id()

    @materialClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @materialId()

    @densityFactor = new ReactiveField 1

  onRendered: ->
    super arguments...

    # Automatically update Rayleigh scattering preview.
    @autorun (computation) => @drawRayleighScattering()

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  class @MaterialId extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Scattering.MaterialId'

    constructor: ->
      super arguments...

      @propertyName = 'materialId'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = for materialClass in AR.Chemistry.Materials.getClasses() when materialClass.prototype instanceof AR.Chemistry.Materials.Gas
        if displayName = materialClass.displayName()
          if formula = materialClass.formula()
            name = "#{displayName} (#{formula})"

          else
            name = displayName

        else
          name = materialClass.id()

        value: materialClass.id()
        name: name

      _.sortBy options, 'name'

  class @DensityFactor extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Scattering.DensityFactor'

    constructor: ->
      super arguments...

      @propertyName = 'densityFactor'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 10
        step: 0.1
