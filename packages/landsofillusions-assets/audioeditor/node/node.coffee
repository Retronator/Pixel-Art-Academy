AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node'
  @register @id()

  constructor: (options) ->
    super

    # We support sending in a node instance (with its ID and audio
    # canvas) or just the node class for a generic display of the node.
    {@id, @nodeClass, @audioCanvas} = options

    @data = => @audioCanvas?.audioEditor.audioData()?.nodes?[@id]

    @temporaryPosition = new ReactiveField null

    @borderWidth = 1
    @padding =
      left: 6
      bottom: 6

  onCreated: ->
    super

    @display = @callAncestorWith 'display'

    @nameHeight = new ReactiveField 20
    
    @inputPositionsByName = new ReactiveField null
    @outputPositionsByName = new ReactiveField null

  onRendered: ->
    super
    
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

    # Update input positions.
    @autorun (computation) =>
      scale = @display.scale()

      # Measure name heights after they had a chance to update.
      Meteor.setTimeout =>
        requestAnimationFrame =>
          for connectionType in ['input', 'output']
            positions = {}
            
            names = (connection.name for connection in @nodeClass["#{connectionType}s"]())
  
            for name, index in names
              positions[name] = index * 20
  
            @["#{connectionType}PositionsByName"] positions
      ,
        0

  position: ->
    @temporaryPosition() or @data()?.position

  nodeName: ->
    @nodeClass.nodeName()

  inputs: ->
    @nodeClass.inputs()

  outputs: ->
    @nodeClass.outputs()

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

    return height unless @expanded?()

    height + @parametersSize().height + @InputsHeight() + @padding.bottom

  expandedClass: ->
    'expanded' if @expanded?()

  validTargetClass: ->
    connection = @currentData()

    return unless draggedConnection = @audioCanvas?.draggedConnection()

    if connection is draggedConnection.input or draggedConnection.output then 'valid-target' else 'invalid-target'

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
    inputName = @currentData()
    return unless inputPositionsByName = @inputPositionsByName()

    left = inputPositionsByName[inputName]

    left: "#{left}rem"

  outputStyle: ->
    outputName = @currentData()
    return unless outputPositionsByName = @outputPositionsByName()

    left = outputPositionsByName[outputName]

    left: "#{left}rem"

  events: ->
    super.concat
      'mousedown .landsofillusions-assets-audioeditor-node': @onMouseDownNode
      'click .landsofillusions-assets-audioeditor-node > .name': @onClickName
      'mousedown .inputs .input .connector': @onMouseDownInputConnector
      'mouseup .inputs .input': @onMouseUpInput
      'mouseenter .inputs .input': @onMouseEnterInput
      'mouseleave .inputs .input': @onMouseLeaveInput
      'mousedown .outputs .output .connector': @onMouseDownOutputConnector
      'mouseup .outputs .output': @onMouseUpOutput
      'mouseenter .outputs .output': @onMouseEnterOutput
      'mouseleave .outputs .output': @onMouseLeaveOutput

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

    @audioCanvas.modifyConnection
      nodeId: @id
      input: input

  onMouseUpInput: (event) ->
    input = @currentData()

    @audioCanvas.endConnection
      nodeId: @id
      input: input

  onMouseEnterInput: (event) ->
    input = @currentData()

    @audioCanvas.startHoverInput
      nodeId: @id
      input: input

  onMouseLeaveInput: (event) ->
    @audioCanvas.endHoverInput()

  onMouseDownOutputConnector: (event) ->
    output = @currentData()

    # Prevent selection.
    event.preventDefault()

    # Prevent node drag.
    event.stopPropagation()

    @audioCanvas.modifyConnection
      nodeId: @id
      output: output

  onMouseUpOutput: (event) ->
    output = @currentData()

    @audioCanvas.endConnection
      nodeId: @id
      output: output

  onMouseEnterOutput: (event) ->
    output = @currentData()

    @audioCanvas.startHoverOutput
      nodeId: @id
      output: output

  onMouseLeaveOutput: (event) ->
    @audioCanvas.endHoverOutput()
