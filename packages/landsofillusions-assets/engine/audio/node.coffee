AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Node
  @_nodeClassesByType = {}

  @getClassForType: (type) ->
    @_nodeClassesByType[type]

  @getClasses: ->
    _.values @_nodeClassesByType

  # String for this node used to identify the node in code.
  @type: -> throw new AE.NotImplementedException "You must specify node's type."

  # Name is how the node is represented in the editor. Not that we can't 
  # call it simply name because it conflicts with the class name property.
  @nodeName: -> throw new AE.NotImplementedException "You must specify node's name."

  # Override to provide inputs and outputs of the node.
  @inputs: -> []
  @outputs: -> []
    
  # Override to provide available parameters of this node.
  @parameters: -> []

  @initialize: ->
    # Store node class by type.
    @_nodeClassesByType[@type()] = @
    
  constructor: (@id, @audio, initialParameters) ->
    # Parameters data is compared by equality to minimize changes in the audio engine.
    @parametersData = new ReactiveField initialParameters, EJSON.equals

    # Further we also create computed fields to minimize reactivity per parameter.
    @_parameterFields = {}

    # Reactive value fields hold reactive value getters for connected inputs and parameters.
    @_reactiveValueFields = {}

    # Provide support for autorun calls that stop when node is destroyed.
    @_autorunHandles = []

    # Prepare autoruns for reactively connecting when audio connection info changes.
    @_connectionAutoruns = []
    
    # Create an instance copy of parameters info.
    @parameters = @constructor.parameters()

  destroy: ->
    handle.stop() for handle in @_autorunHandles

    @_disconnectAutoruns @_connectionAutoruns

    parameterField.stop() for parameter, parameterField of @_parameterFields

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  type: -> @constructor.type()
  nodeName: -> @constructor.nodeName()

  readInput: (input) ->
    return unless reactiveValue = @_getReactiveValueField(input)()

    reactiveValue()

  readParameter: (parameter) ->
    unless @_parameterFields[parameter]
      @_parameterFields[parameter] = Tracker.nonreactive => new ComputedField =>
        if reactiveValue = @_getReactiveValueField(parameter)()
          # We always return whatever is coming from the connection.
          reactiveValue()

        else
          # We return the constant value set on the node or default.
          @parametersData()?[parameter] ? _.find(@constructor.parameters(), (parameterInfo) => parameterInfo.name is parameter)?.default
      ,
        true

    @_parameterFields[parameter]()

  _getReactiveValueField: (name) ->
    @_reactiveValueFields[name] ?= new ReactiveField null

  connect: (node, output, input) ->
    console.log "Connecting audio node #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

    @_connect arguments...
    
    node.onConnect input, @, output

  _connect: (node, output, input) ->
    # Reactively connect to node input.
    autorun = Tracker.nonreactive => Tracker.autorun (computation) =>
      # Remove existing audio connection.
      @_disconnect node, output, input, false

      destinationConnection = node.getDestinationConnection input
      return unless destination = destinationConnection?.destination

      sourceConnection = @getSourceConnection output
      return unless source = sourceConnection?.source

      inputIndex = destinationConnection.index
      outputIndex = sourceConnection.index

      console.log "Audio node connection created #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

      if destination instanceof AudioNode
        source.connect destination, outputIndex, inputIndex

      else if destination instanceof AudioParam
        # Audio params don't have an input index.
        source.connect destination, outputIndex

      else
        console.error "Invalid audio destination type.", destination

      Tracker.afterFlush =>
        autorun.audioSource = source
        autorun.audioDestination = destination
        autorun.audioInputIndex = inputIndex
        autorun.audioOutputIndex = outputIndex

    # Store connection parameters on autorun so we can disconnect it later.
    autorun.audioNode = node
    autorun.audioOutput = output
    autorun.audioInput = input

    @_connectionAutoruns.push autorun

  disconnect: (node, output, input) ->
    console.log "Disconnecting audio node #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

    @_disconnect arguments...

    node.onDisconnect input, @, output

  _disconnect: (node, output, input, stop) ->
    # Stop the autoruns that establish connections.
    connectionAutoruns = _.filter @_connectionAutoruns, (autorun) =>
      autorun.audioNode is node and autorun.audioOutput is output and autorun.audioInput is input

    @_disconnectAutoruns connectionAutoruns, stop

  _disconnectAutoruns: (autoruns, stop = true) ->
    for autorun in autoruns
      if autorun.audioSource
        console.log "Audio node connection removed #{@_connectionDescription autorun.audioNode, autorun.audioOutput, autorun.audioInput}" if LOI.Assets.Engine.Audio.debug

        if autorun.audioDestination instanceof AudioNode
          autorun.audioSource.disconnect autorun.audioDestination, autorun.audioOutputIndex, autorun.audioInputIndex

        else if autorun.audioDestination instanceof AudioParam
          autorun.audioSource.disconnect autorun.audioDestination, autorun.audioOutputIndex

        else
          console.error "Invalid audio destination type.", autorun.audioDestination

      autorun.stop() if stop

    _.pullAll @_connectionAutoruns, autoruns if stop

  audioManager: ->
    @audio.world()?.audioManager()

  onConnect: (input, node, output) ->
    @_getReactiveValueField(input) node.getReactiveValue output
    
  onDisconnect: (input, node, output) ->
    @_getReactiveValueField(input) null

  getDestinationConnection: (input) ->
    # Override to provide destination and input index for the caller to connect to.
    destination: null
    index: 0

  getSourceConnection: (output) ->
    # Override to provide the source and output index for connecting from.
    source: null
    index: @getOutputIndex output

  getReactiveValue: (output) ->
    # Override to provide a reactive value for desired output.
    null

  getOutputIndex: (outputName) ->
    # By default, audio index matches index in the outputs definition.
    outputs = @constructor.outputs()
    index = _.findIndex outputs, (output) => output.name is outputName

    if index < 0
      console.warn "Trying to connect invalid output #{@id}:#{outputName}"
      null

    else
      index
      
  _connectionDescription: (node, output, input) ->
    "#{@_connectorDescription @, output} -> #{@_connectorDescription node, input}"

  _connectorDescription: (node, connector) ->
    "#{node.constructor.nodeName()}(#{_.toLower(node.id).substring 0, 5}):#{_.toUpper connector}"
