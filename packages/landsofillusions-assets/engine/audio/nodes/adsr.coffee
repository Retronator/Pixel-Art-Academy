LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.ADSR extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.ADSR'
  @nodeName: -> 'ADSR'

  @initialize()

  @inputs: -> [
    name: 'press'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'out'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'amplitude'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ,
    name: 'attack'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'decay'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'sustain'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'release'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  constructor: ->
    super arguments...

    @constantNode = new ReactiveField null
    @gainNode = new ReactiveField null

    # Create and connect internal nodes.
    @autorun (computation) =>
      return unless audioManager = @audioManager()
      return unless audioManager.contextValid()

      constantNode = audioManager.context.createConstantSource()
      gainNode = audioManager.context.createGain()
      gainNode.gain.value = 0

      constantNode.connect gainNode
      constantNode.start()

      @constantNode constantNode
      @gainNode gainNode

    # Update constant node as a parameter.
    @autorun (computation) =>
      return unless constantNode = @constantNode()

      constantNode.offset.value = @readParameter 'amplitude'

    # Apply envelope on press changes.
    @_press = false

    @autorun (computation) =>
      return unless audioManager = @audioManager()
      return unless gainNode = @gainNode()

      newPress = @readInput 'press'
      currentTime = audioManager.context.currentTime

      gainNode.gain.cancelScheduledValues currentTime - 1 unless newPress is @_press

      if newPress and not @_press
        # Start attack + decay.
        attack = @readParameter 'attack'
        decay = @readParameter 'decay'
        sustain = @readParameter 'sustain'
        gainNode.gain.linearRampToValueAtTime 1, currentTime + attack
        gainNode.gain.linearRampToValueAtTime sustain, currentTime + attack + decay

      else if @_press and not newPress
        # Start release.
        release = @readParameter 'release'
        gainNode.gain.linearRampToValueAtTime 0, currentTime + release

      @_press = newPress

  getDestinationConnection: (input) ->
    return(super arguments...) unless input is 'amplitude'

    destination: @constantNode()?.offset

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @gainNode()
