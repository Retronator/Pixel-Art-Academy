LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Player extends LOI.Assets.Engine.Audio.ScheduledNode
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Player'
  @nodeName: -> 'Player'

  @initialize()

  @parameters: -> 
    parameters = super arguments...
    
    parameters.unshift
      name: 'buffer'
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
      
    parameters.push 
      name: 'loop'
      pattern: Boolean
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    ,
      name: 'loop start'
      pattern: Match.OptionalOrNull Number
      default: 0
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    ,
      name: 'loop end'
      pattern: Match.OptionalOrNull Number
      default: 0
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    ,
      name: 'playback rate'
      pattern: Match.OptionalOrNull Number
      default: 1
      step: 0.1
      type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
    ,
      name: 'detune'
      pattern: Match.OptionalOrNull Number
      default: 0
      step: 100
      type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
      
    parameters

  @fixedParameterNames: ->
    super(arguments...).concat 'buffer'

  registerCreateDependencies: ->
    # Sources should get created when buffer is connected.
    unless @readParameter 'buffer'
      # Buffer was removed, stop all sources as well.
      @stopSources()

  createSource: (context) ->
    return unless buffer = @readParameter 'buffer'

    source = context.createBufferSource()
    source.buffer = buffer

    source
