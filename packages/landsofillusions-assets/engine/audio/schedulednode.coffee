LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.ScheduledNode extends LOI.Assets.Engine.Audio.Node
  @PlayControl:
    StartOnly: 'start only'
    StartStop: 'start and stop'

  @Parameters:
    Constant: 'constant'
    Update: 'update'

  @inputs: -> [
    name: 'play'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'out'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]
    
  @parameters: -> [
    name: 'play control'
    pattern: String
    options: _.values @PlayControl
    default: @PlayControl.StartStop
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'parameters'
    pattern: String
    options: _.values @Parameters
    default: @Parameters.Update
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
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
      audioManager = @audioManager()

      unless audioManager
        @_lastPlay = null
        return
        
      @registerCreateDependencies()

      if audioManager.contextValid()
        # Create the out node if we haven't yet.
        outNode = Tracker.nonreactive => @outNode()
        @outNode audioManager.context.createGain() unless outNode

        # We start sources when play changes to truthy value.
        if play and not @_lastPlay
          sourceStarted = @_startSource audioManager

          # If no source was created, we aren't playing.
          play = false unless sourceStarted

        if @readParameter('play control') is @constructor.PlayControl.StartStop
          # We stop sources when play is falsy.
          @stopSources() unless play

        @_lastPlay = play

      else
        # If context was invalidated, stop existing sources.
        @stopSources()

        # Let go of the out node as well.
        @outNode null

    # Reactively update parameters.
    @autorun (computation) =>
      @updateSources @_sources if @readParameter('parameters') is @constructor.Parameters.Update

  destroy: ->
    super arguments...

    @stopSources()

  registerCreateDependencies: ->
    # Override and call reactive dependencies that influence creation of new sources.
    
  _startSource: (audioManager) ->
    return false unless source = @createSource audioManager.context

    source.onended = => _.pull @_sources, source
    @updateSources [source]
    source.connect @outNode()
    source.start()

    @_sources.push source

    true
    
  createSource: (context) ->
    throw new AE.NotImplementedException "You must create an audio node."

  updateSources: (sources) ->
    # Override to update parameters of the sources.

  stopSources: ->
    source.stop() for source in @_sources

    @_lastPlay = false

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @outNode()
