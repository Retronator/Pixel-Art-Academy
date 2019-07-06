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

  planePoint: ->
    cluster = @currentData()

    cluster.plane().point

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

    else if properties
      delete properties.coplanarPoint
      properties = null unless _.keys(properties).length

    if properties?
      cluster.properties properties

    else
      cluster.properties.clear()

    # Trigger solver update with the changed cluster.
    cluster.layer.object.solver.update [], [cluster.id], []

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

      if value? and value isnt ''
        properties ?= {}
        properties[@property] = value

      else if properties
        delete properties[@property]
        properties = null unless _.keys(properties).length

      if properties?
        cluster.properties properties

      else
        cluster.properties.clear()

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

  class @Attachment extends @ClusterProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.Cluster.Attachment'

    constructor: ->
      super arguments...

      @property = 'attachment'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = [
        name: 'None'
        value: ''
      ]

      for name, value of LOI.Assets.Mesh.Object.Layer.Cluster.AttachmentTypes
        options.push {name, value}

      options

    save: ->
      super arguments...

      # Trigger solver update with the changed cluster.
      cluster = @data()
      cluster.layer.object.solver.update [], [cluster.id], []
