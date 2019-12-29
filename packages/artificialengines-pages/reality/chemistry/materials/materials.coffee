AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials extends AM.Component
  @ReflectanceTypes:
    VacuumToMaterial: 'VacuumToMaterial'
    MaterialToVacuum: 'MaterialToVacuum'

  @PreviewTypes:
    SpecularReflection: 'SpecularReflection'
    DiffuseReflection: 'DiffuseReflection'
    Dispersion: 'Dispersion'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @materialId = new ReactiveField AR.Chemistry.Materials.Mixtures.Glass.Crown.id()

    @materialClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @materialId()
      
    @reflectanceType = new ReactiveField @constructor.ReflectanceTypes.VacuumToMaterial
    @reflectanceWavelengthNanometers = new ReactiveField 380

    @previewType = new ReactiveField @constructor.PreviewTypes.Dispersion

  onRendered: ->
    super arguments...

    # Automatically update the properties graph.
    @autorun (computation) => @drawPropertiesGraph()

    # Automatically update the reflectance graph.
    @autorun (computation) => @drawReflectanceGraph()

    # Automatically update the preview.
    @autorun (computation) =>
      switch @previewType()
        when @constructor.PreviewTypes.SpecularReflection, @constructor.PreviewTypes.DiffuseReflection
          @drawReflectancePreview()

        when @constructor.PreviewTypes.Dispersion
          @drawDispersionPreview()

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  events: ->
    super(arguments...).concat
      'mousemove .properties-graph': @moveMovePropertiesGraph

  moveMovePropertiesGraph: (event) ->
    @reflectanceWavelengthNanometers event.offsetX + 380 - 30

  class @PropertyInputComponent extends AM.DataInputComponent
    onCreated: ->
      super arguments

      @materials = @ancestorComponentOfType AR.Pages.Chemistry.Materials

    load: ->
      @materials[@propertyName]()

    save: (value) ->
      @materials[@propertyName] value

  class @MaterialId extends @PropertyInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.MaterialId'

    constructor: ->
      super arguments...

      @propertyName = 'materialId'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = for materialClass in AR.Chemistry.Materials.getClasses()
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

  class @ReflectanceType extends @PropertyInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.ReflectanceType'

    constructor: ->
      super arguments...

      @propertyName = 'reflectanceType'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      names =
        VacuumToMaterial: 'Vacuum to material'
        MaterialToVacuum: 'Material to vacuum'

      {value, name} for value, name of names

  class @PreviewType extends @PropertyInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.PreviewType'

    constructor: ->
      super arguments...

      @propertyName = 'previewType'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      names =
        SpecularReflection: 'Specular reflection'
        DiffuseReflection: 'Diffuse reflection'
        Dispersion: 'Dispersion'

      {value, name} for value, name of names
