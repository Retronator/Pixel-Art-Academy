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
  ]

  constructor: ->
    super arguments...

    # Reactively create and destroy audio sources.
    @_sources = []
    @_lastPlay = null

    @autorun (computation) =>
      play = @readInput 'play'
      buffer = @readParameter 'buffer'
      audioManager = @audioManager()

      unless buffer and audioManager
        @_lastPlay = null
        return

      if audioManager.contextValid()
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

  destroy: ->
    super arguments...

    @_stopSources()

  _startSource: (audioManager, buffer) ->
    source = audioManager.context.createBufferSource()

    source.buffer = buffer
    source.onended = => _.pull @_sources, source

    # Find which destination we're connected to.
    if autorun = _.find @_connectionAutoruns, (autorun) => autorun.audioOutput is 'out'
      destinationConnection = autorun.audioNode.getDestinationConnection autorun.audioInput
      if destination = destinationConnection?.destination
        inputIndex = destinationConnection.index or 0
    
        console.log "Player source connected #{@_connectionDescription autorun.audioNode, 'out', autorun.audioInput}" if LOI.Assets.Engine.Audio.debug
    
        source.connect destination, 0, inputIndex
        source.connected = true
    
    source.start()

    @_sources.push source

  _stopSources: ->
    source.stop() for source in @_sources

  _connect: (node, output, input) ->
    super arguments...

    destinationConnection = node.getDestinationConnection input
    return unless destination = destinationConnection?.destination

    inputIndex = destinationConnection.index or 0

    # Connect all sources.
    for source in @_sources
      console.log "Player source connected #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug
      source.connect destination, 0, inputIndex
      source.connected = true

  _disconnect: (node, output, input, stop) ->
    super arguments...

    destinationConnection = node.getDestinationConnection input
    return unless destination = destinationConnection?.destination

    inputIndex = destinationConnection.index or 0

    # Disconnect all sources.
    for source in @_sources when source.connected
      console.log "Player source disconnected #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug
      source.disconnect destination, 0, inputIndex
      source.connected = false
