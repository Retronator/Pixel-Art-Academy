AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Cluster extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Cluster'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @editor = new ComputedField =>
      @interface.getEditorForActiveFile()

    @cluster = new ComputedField =>
      return unless currentClusterHelper = @editor()?.currentClusterHelper()
      currentClusterHelper.cluster()

  events: ->
    super(arguments...).concat
      'change .coplanar-point .coordinate-input': @onChangeCoplanarPointCoordinate

  onChangeCoplanarPointCoordinate: (event) ->
    $coordinates = $(event.target).closest('.coordinates')

    coordinates = {}

    for property in ['x', 'y', 'z']
      coordinates[property] = @_parseFloatOrNull $coordinates.find(".coordinate-#{property} .coordinate-input").val()

    cluster = @cluster()
    properties = cluster.properties()

    if coordinates.x? or coordinates.y? or coordinates.z?
      properties ?= {}
      properties.coplanarPoint = coordinates

    else
      delete properties.coplanarPoint
      properties = null unless _.keys(properties).length

    cluster.properties properties

    # Trigger solver update with no changed clusters.
    cluster.layer.object.solver.update [], [], []

  _parseFloatOrNull: (string) ->
    float = parseFloat string

    if _.isNaN float then null else float

  class @ClusterProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

    load: ->
      cluster = @data()
      cluster.properties()?[@property]

    save: (value) ->
      cluster = @data()
      properties = cluster.properties()

      if @type is AM.DataInputComponent.Types.Number
        value = parseFloat value
        value = null if _.isNaN value

      if value?
        properties ?= {}
        properties[@property] = value

      else
        delete properties[@property]
        properties = null unless _.keys(properties).length

      cluster.properties properties

  class @Name extends @ClusterProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.Cluster.Name'

    constructor: ->
      super arguments...

      @property = 'name'

    placeholder: ->
      cluster = @data()
      "Cluster #{cluster.id}"

  class @Navigable extends @ClusterProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.Cluster.Navigable'

    constructor: ->
      super arguments...

      @property = 'navigable'
      @type = AM.DataInputComponent.Types.Checkbox
