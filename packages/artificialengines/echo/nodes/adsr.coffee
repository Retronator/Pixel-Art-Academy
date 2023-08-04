AEc = Artificial.Echo

class AEc.Node.ADSR extends AEc.Node
  @type: -> 'Artificial.Echo.Node.ADSR'
  @displayName: -> 'ADSR'

  @initialize()

  @inputs: -> [
    name: 'press'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Boolean
  ]

  @outputs: -> [
    name: 'out'
    type: AEc.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'amplitude'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: AEc.ConnectionTypes.Parameter
  ,
    name: 'attack'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ,
    name: 'decay'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ,
    name: 'sustain'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ,
    name: 'release'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  constructor: ->
    super arguments...

    # Create and connect internal nodes.
    context = @audio.context

    @constantNode = new ConstantSourceNode context
    @gainNode = new GainNode context gain: 0

    @constantNode.connect @gainNode
    @constantNode.start()

    # Update constant node as a parameter.
    @autorun (computation) =>
      @constantNode.offset.value = @readParameter 'amplitude'

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
