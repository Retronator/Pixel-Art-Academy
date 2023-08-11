AEc = Artificial.Echo

class AEc.Node.Player extends AEc.Node.ScheduledNode
  @type: -> 'Artificial.Echo.Node.Player'
  @displayName: -> 'Player'

  @initialize()

  @parameters: ->
    parameters = super arguments...
    
    parameters.unshift
      name: 'buffer'
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.Buffer
      
    parameters.push
      name: 'offset'
      pattern: Match.OptionalOrNull Number
      default: 0
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.Number
    ,
      name: 'duration'
      pattern: Match.OptionalOrNull Number
      default: null
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.Number
    ,
      name: 'loop'
      pattern: Boolean
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.Boolean
    ,
      name: 'loop start'
      pattern: Match.OptionalOrNull Number
      default: 0
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.Number
    ,
      name: 'loop end'
      pattern: Match.OptionalOrNull Number
      default: 0
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.Number
    ,
      name: 'playback rate'
      pattern: Match.OptionalOrNull Number
      default: 1
      step: 0.1
      type: AEc.ConnectionTypes.Parameter
    ,
      name: 'detune'
      pattern: Match.OptionalOrNull Number
      default: 0
      step: 100
      type: AEc.ConnectionTypes.Parameter
      
    parameters

  @fixedParameterNames: ->
    super(arguments...).concat 'buffer', 'offset', 'duration'

  registerCreateDependencies: ->
    # Sources should get created when buffer is connected.
    unless @readParameter 'buffer'
      # Buffer was removed, stop all sources as well.
      @stopSources()

  createSource: (context) ->
    return unless buffer = @readParameter 'buffer'

    new AudioBufferSourceNode context, {buffer}
  
  startSource: (source, context) ->
    whenToStart = context.currentTime + @readParameter 'when'
    offset = @readParameter 'offset'
    duration = @readParameter 'duration'
    
    if duration?
      source.start whenToStart, offset, duration
      
    else
      source.start whenToStart, offset
