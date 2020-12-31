AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Matrix extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.Matrix'

  constructor: (@options) ->
    super arguments...

    @rowsCount = @options.rowsCount or @options.dimensions
    @columnsCount = @options.columnsCount or @options.dimensions

    # If we couldn't determine the row or column count, try to see if we can determine it from the initial value.
    unless @rowCount and @columnCount
      if initialValue = @options.load()
        if initialValue.length is 4
          @rowsCount = 2
          @columnsCount = 2
        
        else if initialValue.length is 9
          @rowsCount = 3
          @columnsCount = 3
          
        else if initialValue.length is 16
          @rowsCount = 4
          @columnsCount = 4
      
      throw new AE.ArgumentNullException "Dimensions of the matrix must be specified." unless @rowsCount and @columnsCount
      
    @defaultNames = ['x', 'y', 'z', 'w']
    
    @columnNames = (_.deburr name for name in (@options.columnNames or @defaultNames)[...@columnsCount])
    @rowNames = (_.deburr name for name in (@options.rowNames or @defaultNames)[...@rowsCount])

  onCreated: ->
    super arguments...
    
  columns: ->
    for columnLetter in @columnNames
      name: columnLetter

  rows: ->
    matrixData = @options.load()

    for rowName, rowIndex in @rowNames
      name: rowName
      columns: for columnName, columnIndex in @columnNames
        value = matrixData?[rowIndex * @columnsCount + columnIndex]
        
        # By default, we should output an identity matrix.
        value ?= if columnIndex is rowIndex then 1 else 0
          
        name: columnName
        rowIndex: rowIndex
        columnIndex: columnIndex
        value: value

  # Events

  events: ->
    super(arguments...).concat
      'change .element-input': @onChangeElement

  onChangeElement: (event) ->
    cell = @currentData()
    value = _.parseFloatOrZero $(event.target).val()

    matrix = @options.load() or []

    # Store value in row-major order.
    matrix[cell.rowIndex * @columnsCount + cell.columnIndex] = value

    @options.save matrix
