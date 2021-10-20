AE = Artificial.Everywhere
AM = Artificial.Mirage
AR = Artificial.Reality
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.ObjectDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.ObjectDialog'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @object = new ComputedField =>
      return unless dialogData = @data()
      @mesh()?.objects.get dialogData.objectIndex

  windowData: ->
    title: @object()?.name or 'Object'

  solverType: ->
    @object()?.solver.constructor.type

  class @ObjectProperty extends AM.DataInputComponent
    load: ->
      object = @data()
      object[@property]()

    save: (value) ->
      object = @data()

      if @type is AM.DataInputComponent.Types.Number
        value = _.parseFloatOrNull value

      object[@property] value

  class @Name extends @ObjectProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.ObjectDialog.Name'

    constructor: ->
      super arguments...

      @property = 'name'

  class @Type extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.MeshEditor.ObjectDialog.Type'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      {name, value} for name, value of LOI.Assets.Mesh.Object.Solver.Types

    load: ->
      object = @data()
      object.solver.constructor.type

    save: (value) ->
      object = @data()
      object.setSolver value

  class @SolverProperty extends AM.DataInputComponent
    load: ->
      object = @data()
      options = object.solverOptions[@solverType]()
      options?[@property]

    save: (value) ->
      object = @data()
      options = object.solverOptions[@solverType]() or {}

      if @type is AM.DataInputComponent.Types.Number
        value = _.parseFloatOrNull value

      options[@property] = value

      object.solverOptions[@solverType] options

      # Recompute the object to apply new solver options.
      object.recompute()

  class @CleanEdgePixels extends @SolverProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.ObjectDialog.CleanEdgePixels'

    constructor: ->
      super arguments...

      @solverType = LOI.Assets.Mesh.Object.Solver.Types.Polyhedron
      @property = 'cleanEdgePixels'
      @type = AM.DataInputComponent.Types.Checkbox
