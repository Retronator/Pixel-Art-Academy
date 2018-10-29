AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node'
  @register @id()

  constructor: (options) ->
    super arguments...

    # We support sending in a node instance (with its ID and audio
    # canvas) or just the node class for a generic display of the node.
    {@id, @nodeClass, @audioCanvas} = options

    @data = => @audioCanvas?.audioEditor.audioData()?.nodes?[@id]

    @temporaryPosition = new ReactiveField null

    @borderWidth = 1
    @padding =
      top: 3
      left: 6
      bottom: 6

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'

    @nameHeight = new ReactiveField 20
    
    @inputPositionsByName = new ReactiveField null
    @outputPositionsByName = new ReactiveField null

  onRendered: ->
    super arguments...
    
    # Update name height when in audioCanvas.
    @autorun (computation) =>
      # Depend on node name and scale.
      scale = @display.scale()

      # Measure name height after it had a chance to update.
      Meteor.setTimeout =>
        # HACK: Also make sure the elements are being rendered since they will return 0 otherwise.
        requestAnimationFrame =>
          @nameHeight @$('.landsofillusions-assets-audioeditor-node > .name').outerHeight() / scale
      ,
        0

    # Update input/output positions.
    @autorun (computation) =>
      for connectionType in ['input', 'output']
        positions = {}

        names = (connection.name for connection in @nodeClass["#{connectionType}s"]())

        # Spread the connections around the middle of the node edge.
        spacing = @nodeWidth() / (names.length + 1)

        for name, index in names
          positions[name] = (index + 1) * spacing

        @["#{connectionType}PositionsByName"] positions

  position: ->
    @temporaryPosition() or @data()?.position

  expanded: ->
    @data()?.expanded

  nodeName: ->
    @nodeClass.nodeName()

  inputs: ->
    @nodeClass.inputs()

  outputs: ->
    @nodeClass.outputs()

  inputPositionForName: (name) ->
    return unless @isCreated()

    x = @inputPositionsByName()?[name]
    return unless x?

    x: x
    y: -1

  outputPositionForName: (name) ->
    return unless @isCreated()

    x = @outputPositionsByName()?[name]
    return unless x?

    x: x
    y: @nodeHeight()

  nodeStyle: ->
    # Make sure we have position present, as it will disappear when node is being deleted.
    return @libraryNodeStyle() unless position = @position()

    scale = @audioCanvas.camera().scale()

    position: 'absolute'
    left: "#{position.x * scale}rem"
    top: "#{position.y * scale}rem"
    width: "#{@nodeWidth()}rem"
    height: "#{@nodeHeight()}rem"

  libraryNodeStyle: ->
    width: "#{@nodeWidth()}rem"
    height: "#{@nodeHeight()}rem"

  nodeWidth: ->
    @padding.left + @parametersSize().width + 2 * @borderWidth

  nodeHeight: ->
    height = @nameHeight() + 2 * @borderWidth

    return height unless @expanded()

    height + @padding.top + @parametersSize().height + @padding.bottom

  expandedClass: ->
    'expanded' if @expanded()

  parametersSize: ->
    width: 80
    height: 10

  parametersStyle: ->
    parametersSize = @parametersSize()

    top: "#{@nameHeight()}rem"
    left: "#{@padding.left}rem"
    width: "#{parametersSize.width}rem"
    height: "#{parametersSize.height}rem"

  inputStyle: ->
    input = @currentData()
    return unless inputPositionsByName = @inputPositionsByName()

    left = inputPositionsByName[input.name]

    left: "#{left}rem"

  outputStyle: ->
    output = @currentData()
    return unless outputPositionsByName = @outputPositionsByName()

    left = outputPositionsByName[output.name]

    left: "#{left}rem"

  connectorName: ->
    connector = @currentData()

    # Return just the first letter in uppercase.
    _.toUpper(connector.name)[0]

  events: ->
    super(arguments...).concat
      'mousedown .landsofillusions-assets-audioeditor-node': @onMouseDownNode
      'click .landsofillusions-assets-audioeditor-node > .name': @onClickName
      'mousedown .input .connector': @onMouseDownInputConnector
      'mouseup .input': @onMouseUpInput
      'mouseenter .input': @onMouseEnterInput
      'mouseleave .input': @onMouseLeaveInput
      'mousedown .output .connector': @onMouseDownOutputConnector
      'mouseup .output': @onMouseUpOutput
      'mouseenter .output': @onMouseEnterOutput
      'mouseleave .output': @onMouseLeaveOutput
      'mouseenter': @onMouseEnter
      'mouseleave': @onMouseLeave
      'mouseup': @onMouseUp

  onMouseDownNode: (event) ->
    # We only deal with drag & drop for nodes inside the canvas.
    return unless @audioCanvas
    
    # Prevent browser select/dragging behavior
    event.preventDefault()
    
    @audioCanvas.startDrag
      nodeId: @id
      nodePosition: @data().position

  onClickName: (event) ->
    return unless @audioCanvas

    @audioCanvas.audioEditor.changeNodeExpanded @id, not @data().expanded

  onMouseDownInputConnector: (event) ->
    input = @currentData()

    # Prevent selection.
    event.preventDefault()

    # Prevent node drag.
    event.stopPropagation()

    # See if we want to start a new connection or modify an existing one.
    connections = @audioCanvas.connections()

    if existingConnection = _.find(connections, (connection) => connection.endNodeId is @id and connection.input is input.name)
      @audioCanvas.modifyConnection existingConnection

    else
      @audioCanvas.startConnection
        nodeId: @id
        input: input.name

  onMouseUpInput: (event) ->
    input = @currentData()

    @audioCanvas.endConnection
      nodeId: @id
      input: input.name

  onMouseEnterInput: (event) ->
    input = @currentData()

    @audioCanvas.startHoverInput
      nodeId: @id
      input: input.name

  onMouseLeaveInput: (event) ->
    @audioCanvas.endHoverInput()

  onMouseDownOutputConnector: (event) ->
    output = @currentData()

    # Prevent selection.
    event.preventDefault()

    # Prevent node drag.
    event.stopPropagation()

    @audioCanvas.startConnection
      nodeId: @id
      output: output.name

  onMouseUpOutput: (event) ->
    output = @currentData()

    @audioCanvas.endConnection
      nodeId: @id
      output: output.name

  onMouseEnterOutput: (event) ->
    output = @currentData()

    @audioCanvas.startHoverOutput
      nodeId: @id
      output: output.name

  onMouseLeaveOutput: (event) ->
    @audioCanvas.endHoverOutput()

  onMouseEnter: (event) ->
    return unless draggedConnection = @audioCanvas?.draggedConnection()

    if draggedConnection.output
      inputs = @nodeClass.inputs()
      return unless inputs.length is 1

      @audioCanvas.startHoverInput
        nodeId: @id
        input: inputs[0].name

    else
      outputs = @nodeClass.outputs()
      return unless outputs.length is 1

      @audioCanvas.startHoverOutput
        nodeId: @id
        output: outputs[0].name

  onMouseLeave: (event) ->
    return unless @audioCanvas

    @audioCanvas.endHoverInput()
    @audioCanvas.endHoverOutput()

  onMouseUp: (event) ->
    return unless draggedConnection = @audioCanvas?.draggedConnection()

    if draggedConnection.output
      inputs = @nodeClass.inputs()
      return unless inputs.length is 1

      @audioCanvas.endConnection
        nodeId: @id
        input: inputs[0].name

    else
      outputs = @nodeClass.outputs()
      return unless outputs.length is 1

      @audioCanvas.endConnection
        nodeId: @id
        output: outputs[0].name
