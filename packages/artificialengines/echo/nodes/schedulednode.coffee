AEc = Artificial.Echo

class AEc.Node.ScheduledNode extends AEc.Node
  @PlayControl:
    StartOnly: 'start only'
    StartStop: 'start and stop'

  @Parameters:
    Constant: 'constant'
    Update: 'update'

  @inputs: -> [
    name: 'play'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Press
  ]

  @outputs: -> [
    name: 'out'
    type: AEc.ConnectionTypes.Channels
  ]
  
  @parameters: -> [
    name: 'play control'
    pattern: String
    options: _.values @PlayControl
    default: @PlayControl.StartStop
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ,
    name: 'parameters'
    pattern: String
    options: _.values @Parameters
    default: @Parameters.Update
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ]
  
  @fixedParameterNames: -> ['play control', 'parameters']
  
  constructor: ->
    super arguments...

    # Create a map of child parameters (not connected with play scheduling) so we can quickly update them.
    @_childParameterFieldNames = {}
    
    for parameter in @parameters when parameter.name not in @constructor.fixedParameterNames()
      @_childParameterFieldNames[parameter.name] = _.camelCase parameter.name

    @_sources = []
    @_lastPlay = null
    
    # We use intermediate (dummy) nodes to wire sources to so we can connect them using normal logic.
    @_outNode = new ReactiveField null
    @_parameterNodes = {}
    @_intermediateNodesCreated = false

    for parameter in @parameters when parameter.type is AEc.ConnectionTypes.Parameter
      @_parameterNodes[parameter.name] = new ReactiveField null

    # Reactively create and destroy audio sources.
    @autorun (computation) =>
      play = @readInput 'play'
      context = @audio.context

      @registerCreateDependencies()

      # Create the out node if we haven't yet.
      unless @_intermediateNodesCreated
        @_outNode new GainNode context
        
        for parameterName of @_parameterNodes
          @_parameterNodes[parameterName] new GainNode context

        @_intermediateNodesCreated = true

      # We start sources when play changes to truthy value.
      if play and not @_lastPlay
        sourceStarted = @_startSource context

        # If no source was created, we aren't playing.
        play = false unless sourceStarted

      if @readParameter('play control') is @constructor.PlayControl.StartStop
        # We stop sources when play is falsy.
        @stopSources() unless play

      @_lastPlay = play

    # Reactively update parameters.
    @autorun (computation) =>
      @updateSources @_sources if @readParameter('parameters') is @constructor.Parameters.Update

  destroy: ->
    super arguments...

    @stopSources()

  registerCreateDependencies: ->
    # Override and call reactive dependencies that influence creation of new sources.
    
  _startSource: (context) ->
    return false unless source = @createSource context

    source.onended = =>
      _.pull @_sources, source

      for parameterName, parameterNode of @_parameterNodes
        parameterNode().disconnect source[@_childParameterFieldNames[parameterName]]

    @updateSources [source]

    source.connect @_outNode()

    for parameterName, parameterNode of @_parameterNodes
      parameterNode().connect source[@_childParameterFieldNames[parameterName]]

    source.start()

    @_sources.push source

    true
    
  createSource: (context) ->
    throw new AE.NotImplementedException "You must create an audio node."

  updateSources: (sources) ->
    parameterValues = {}
    parameterValues[parameter.name] = @readParameter parameter.name for parameter in @parameters
    
    for source in sources
      for parameter in @parameters when @_childParameterFieldNames[parameter.name]
        switch parameter.type
          when AEc.ConnectionTypes.ReactiveValue
            source[@_childParameterFieldNames[parameter.name]] = parameterValues[parameter.name]

          when AEc.ConnectionTypes.Parameter
            source[@_childParameterFieldNames[parameter.name]].value = parameterValues[parameter.name]

  stopSources: ->
    source.stop() for source in @_sources

    @_lastPlay = false

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @_outNode()

  getDestinationConnection: (input) ->
    return (super arguments...) unless @_parameterNodes[input]

    destination: @_parameterNodes[input]()
