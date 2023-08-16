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
    @gainNode = new GainNode context, gain: 0

    @constantNode.connect @gainNode
    @constantNode.start()

    # Update constant node as a parameter.
    @autorun (computation) =>
      @constantNode.offset.value = @readParameter 'amplitude'

    # Apply envelope on press changes.
    @_press = false

    @autorun (computation) =>
      newPress = if @readInput('press') then true else false
      currentTime = context.currentTime

      unless newPress is @_press
        value = @gainNode.gain.value
        @gainNode.gain.cancelScheduledValues currentTime
        
      if newPress and not @_press
        # Start attack + decay.
        attack = @readParameter 'attack'
        decay = @readParameter 'decay'
        sustain = @readParameter 'sustain'
        
        if attack and decay
          @gainNode.gain.setValueAtTime value, currentTime
          @gainNode.gain.linearRampToValueAtTime 1, currentTime + attack
          @gainNode.gain.linearRampToValueAtTime sustain, currentTime + attack + decay
          @_lastPressValue = value
          
        else if attack
          @gainNode.gain.setValueAtTime value, currentTime
          @gainNode.gain.linearRampToValueAtTime 1, currentTime + attack
          @gainNode.gain.setValueAtTime sustain, currentTime + attack
          @_lastPressValue = value
          
        else if decay
          @gainNode.gain.setValueAtTime 1, currentTime
          @gainNode.gain.linearRampToValueAtTime sustain, currentTime + decay
          @_lastPressValue = 0
          
        else
          @gainNode.gain.setValueAtTime sustain, currentTime
          @_lastPressValue = sustain
        
        @_lastPressTime = currentTime

      else if @_press and not newPress
        # Start release.
        release = @readParameter 'release'
        
        if release
          # If release happens in the same frame as the press, the value hasn't had the
          # chance to update itself yet, so we resort to saved desired value on press.
          value = @_lastPressValue if currentTime is @_lastPressTime
          
          @gainNode.gain.setValueAtTime value, currentTime
          @gainNode.gain.linearRampToValueAtTime 0, currentTime + release
          
        else
          @gainNode.gain.setValueAtTime 0, currentTime

      @_press = newPress

  getDestinationConnection: (input) ->
    return(super arguments...) unless input is 'amplitude'

    destination: @constantNode.offset

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @gainNode
