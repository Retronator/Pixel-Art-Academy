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

    # Copy the ID for reactive rendering.
    @_id = @id

    @temporaryPosition = new ReactiveField null

    @borderWidth = 1
    @padding =
      top: 3
      bottom: 6
      left: 7
      right: 7

    @parametersMargin = 5

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'

    @nameHeight = new ReactiveField 20
    @contentSize = new ReactiveField width: 74, height: 0

    @inputPositionsByName = new ReactiveField null
    @outputPositionsByName = new ReactiveField null
    @parameterPositionsByName = new ReactiveField null

    # Do extra preparations for nodes on the canvas (not in the library).
    if @audioCanvas
      # Enable reading output data.
      @outputData = new ReactiveField {}
      
      @autorun (computation) =>
        return unless audioNode = @audioCanvas.audioEditor.audio().getNode @id

        # Note: We have to read output data non-reactively since we're assigning it later.
        outputData = Tracker.nonreactive => @outputData()

        for output in @nodeClass.outputs()
          # By default we read the reactive value.
          outputData[output.name] = Tracker.nonreactive => audioNode.getReactiveValue output.name

          # If we have a valid audio source, we instead provide values from an analyser.
          sourceConnection = audioNode.getSourceConnection output.name
          audioManager = @audioCanvas.audioEditor.world()?.audioManager()

          if sourceConnection.source and audioManager?.contextValid()
            # Wire output to an analyzer.
            analyser = audioManager.context.createAnalyser()
            analyser.fftSize = 2048
            sourceConnection.source.connect analyser, sourceConnection.index
            outputData[output.name] = analyser

        @outputData outputData

      # Create custom content component.
      if @nodeClass is LOI.Assets.Engine.Audio.Sound
        @customContent = new LOI.Assets.AudioEditor.Node.Sound @

    # Isolate reactivity of data.
    @data = new ComputedField =>
      @audioCanvas?.audioEditor.audioData()?.nodes?[@id]
    ,
      EJSON.equals

    @parametersData = new ComputedField =>
      @data()?.parameters
    ,
      EJSON.equals

  onRendered: ->
    super arguments...
    
    # Update name height when in audioCanvas.
    @autorun (computation) =>
      # Depend on scale.
      scale = @display.scale()

      # Depend on parameters data.
      @parametersData()

      # Measure elements after they had a chance to update.
      Meteor.setTimeout =>
        # HACK: Also make sure the elements are being rendered since they will return 0 otherwise.
        requestAnimationFrame =>
          @nameHeight @$('.landsofillusions-assets-audioeditor-node > .name').outerHeight() / scale

          $parameters = @$('.landsofillusions-assets-audioeditor-node > .content')
          @contentSize
            width: $parameters.outerWidth() / scale
            height: $parameters.outerHeight() / scale
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

    # Update parameters positions.
    @autorun (computation) =>
      scale = @display.scale()
      @parametersData()

      # Measure parameters heights after they had a chance to update.
      Meteor.setTimeout =>
        requestAnimationFrame =>
          positions = {}
          top = 0

          for parameter in @$('.parameters .parameter')
            $parameter = $(parameter)
            name = $parameter.data 'name'

            top += @parametersMargin
            positions[name] = top

            # Move down by the parameter height.
            height = $parameter.outerHeight() / scale
            top += height

          @parameterPositionsByName positions
      ,
        0

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

  parameters: ->
    @nodeClass.parameters()

  parameterOptions: ->
    parameter = @currentData()

    Tracker.nonreactive =>
      _.extend {}, parameter,
        load: =>
          @parametersData()?[parameter.name] or parameter.default

        save: (value) =>
          @audioCanvas.audioEditor.changeNodeParameter @id, parameter.name, value

  inputPositionForName: (name) ->
    return unless @isCreated()

    if x = @inputPositionsByName()?[name]
      x: x
      y: 0

    else if y = @parameterPositionsByName()?[name]
      if @expanded()
        x: 0
        y: y + @nameHeight()

      else
        x: 0
        y: @nodeHeight() / 2

  outputPositionForName: (name) ->
    return unless @isCreated()

    x = @outputPositionsByName()?[name]
    return unless x?

    x: x
    y: @nodeHeight()

  isParameter: (name) ->
    _.find @nodeClass.parameters(), (parameter) => parameter.name is name

  audioManager: ->
    @audioCanvas?.audioEditor.world()?.audioManager()

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
    width: "88rem"
    height: "#{@nodeHeight()}rem"

  nodeWidth: ->
    @padding.left + @contentSize().width + @padding.right + 2 * @borderWidth

  nodeHeight: ->
    height = @nameHeight() + 2 * @borderWidth

    return height unless @expanded()

    height + @padding.top + @contentSize().height + @padding.bottom

  expandedClass: ->
    'expanded' if @expanded()

  contentStyle: ->
    top: "#{@nameHeight()}rem"
    left: "#{@padding.left}rem"

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
      'mouseenter .landsofillusions-assets-audioeditor-node': @onMouseEnter
      'mouseleave .landsofillusions-assets-audioeditor-node': @onMouseLeave
      'mouseup .landsofillusions-assets-audioeditor-node': @onMouseUp

  onMouseDownNode: (event) ->
    # We only deal with drag & drop for nodes inside the canvas.
    return unless @audioCanvas

    # Ignore actions inside parameters.
    return if $(event.target).closest('.parameters').length
    
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
      inputs = _.union @nodeClass.inputs(), @nodeClass.parameters()
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
