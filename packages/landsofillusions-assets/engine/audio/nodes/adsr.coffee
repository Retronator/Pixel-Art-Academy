LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.ADSR extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.ADSR'
  @nodeName: -> 'ADSR'

  @initialize()

  @inputs: -> [
    name: 'press'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Press
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
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ,
    name: 'decay'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ,
    name: 'sustain'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ,
    name: 'release'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ]

  constructor: ->
    super arguments...

    # Create and connect internal nodes.
    context = @audio.context

    @constantNode = context.createConstantSource()
    @gainNode = context.createGain()
    @gainNode.gain.value = 0

    @constantNode.connect gainNode
    @constantNode.start()

    # Update constant node as a parameter.
    @autorun (computation) =>
      @constantNode().offset.value = @readParameter 'amplitude'

    # Apply envelope on press changes.
    @_press = false

    @autorun (computation) =>
      newPress = @readInput 'press'
      currentTime = context.currentTime

      @gainNode.gain.cancelScheduledValues Math.max 0, currentTime - 1 unless newPress is @_press

      if newPress and not @_press
        # Start attack + decay.
        attack = @readParameter 'attack'
        decay = @readParameter 'decay'
        sustain = @readParameter 'sustain'
        @gainNode.gain.linearRampToValueAtTime 1, currentTime + attack
        @gainNode.gain.linearRampToValueAtTime sustain, currentTime + attack + decay

      else if @_press and not newPress
        # Start release.
        release = @readParameter 'release'
        @gainNode.gain.linearRampToValueAtTime 0, currentTime + release

      @_press = newPress

  getDestinationConnection: (input) ->
    return(super arguments...) unless input is 'amplitude'

    destination: @constantNode.offset

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @gainNode
