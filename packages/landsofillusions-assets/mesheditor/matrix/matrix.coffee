AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Matrix extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.Matrix'

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

  rows: ->
    matrix = new THREE.Matrix4().elements

    if matrixData = @options.load()
      matrix = _.defaults matrixData, matrix

    for rowName, rowIndex in ['x', 'y', 'z', 'w']
      name: rowName
      index: rowIndex
      x: matrix[rowIndex * 4]
      y: matrix[rowIndex * 4 + 1]
      z: matrix[rowIndex * 4 + 2]
      w: matrix[rowIndex * 4 + 3]

  # Events

  events: ->
    super(arguments...).concat
      'change .element-input': @onChangeElement

  onChangeElement: (event) ->
    row = @currentData()
    $row = $(event.target).closest('.row')

    matrix = @options.load() or []

    for property, index in ['x', 'y', 'z', 'w']
      matrix[row.index * 4 + index] = @_parseFloatOrZero $row.find(".element-#{property} .element-input").val()

    @options.save matrix

  _parseFloatOrZero: (string) ->
    float = parseFloat string

    if _.isNaN float then 0 else float
