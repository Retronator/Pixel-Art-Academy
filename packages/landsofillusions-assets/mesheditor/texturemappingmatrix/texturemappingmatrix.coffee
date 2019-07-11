AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.TextureMappingMatrix extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.TextureMappingMatrix'

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

  rows: ->
    matrix = [1, 0, 0, 0, 1, 0]

    if matrixData = @options.load()
      matrix = _.defaults [], matrixData, matrix

    for rowName, rowIndex in ['u', 'v']
      name: rowName
      index: rowIndex
      x: matrix[rowIndex * 3]
      y: matrix[rowIndex * 3 + 1]
      z: matrix[rowIndex * 3 + 2]

  # Events

  events: ->
    super(arguments...).concat
      'change .element-input': @onChangeElement

  onChangeElement: (event) ->
    row = @currentData()
    $row = $(event.target).closest('.row')

    matrix = @options.load() or []

    for property, index in ['x', 'y', 'z']
      matrix[row.index * 3 + index] = _.parseFloatOrZero $row.find(".element-#{property} .element-input").val()

    @options.save matrix
