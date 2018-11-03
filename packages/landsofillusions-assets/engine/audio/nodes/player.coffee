LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Player extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Player'
  @nodeName: -> 'Player'
    
  @PlayControl:
    StartOnly: 'start only'
    StartStop: 'start and stop'

  @Parameters:
    Constant: 'constant'
    Update: 'update'

  @initialize()

  @inputs: -> [
    name: 'play'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'out'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'buffer'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'play control'
    pattern: String
    options: _.values @PlayControl
    default: @PlayControl.StartOnly
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'parameters'
    pattern: String
    options: _.values @Parameters
    default: @Parameters.Constant
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
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
  ]

  constructor: ->
    super arguments...

    @_sources = []
    @_lastPlay = null

    # We use an intermediate (dummy) node to wire sources through so we can connect it using normal logic.
    @outNode = new ReactiveField null

    # Reactively create and destroy audio sources.
    @autorun (computation) =>
      play = @readInput 'play'
      buffer = @readParameter 'buffer'
      audioManager = @audioManager()

      unless buffer and audioManager
        @_lastPlay = null
        return

      if audioManager.contextValid()
        # Create the out node if we haven't yet.
        outNode = Tracker.nonreactive => @outNode()
        @outNode audioManager.context.createGain() unless outNode

        # We start sources when play changes to truthy value.
        if play and not @_lastPlay
          @_startSource audioManager, buffer

        if @readParameter('play control') is @constructor.PlayControl.StartStop
          # We stop sources when play is falsy.
          @_stopSources() unless play

        @_lastPlay = play

      else
        # If context was invalidated, stop existing sources.
        @_stopSources()

        # Let go of the out node as well.
        @outNode null

    # Reactively update parameters.
    @autorun (computation) =>
      @_updateSources @_sources if @readParameter('parameters') is @constructor.Parameters.Update

  destroy: ->
    super arguments...

    @_stopSources()

  _startSource: (audioManager, buffer) ->
    source = audioManager.context.createBufferSource()

    source.buffer = buffer
    source.onended = => _.pull @_sources, source
    @_updateSources [source]
    source.connect @outNode()
    source.start()

    @_sources.push source

  _stopSources: ->
    source.stop() for source in @_sources

  _updateSources: (sources) ->
    loopEnabled = @readParameter 'loop'
    loopStart = @readParameter 'loop start'
    loopEnd = @readParameter 'loop end'
    playbackRate = @readParameter 'playback rate'
    detune = @readParameter 'detune'

    for source in sources
      source.loop = loopEnabled
      source.loopStart = loopStart
      source.loopEnd = loopEnd
      source.playbackRate.value = playbackRate
      source.detune.value = detune

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @outNode()
