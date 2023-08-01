AEc = Artificial.Echo

class AEc.Node.Oscillator extends AEc.Node.ScheduledNode
  @type: -> 'Artificial.Echo.Node.Oscillator'
  @displayName: -> 'Oscillator'

  @Types:
    Sine: 'sine'
    Square: 'square'
    Sawtooth: 'sawtooth'
    Triangle: 'triangle'
    Custom: 'custom'

  @initialize()

  @parameters: ->
    super(arguments...).concat
      name: 'type'
      pattern: String
      options: _.values @Types
      default: @Types.Sine
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.String
    ,
      name: 'frequency'
      pattern: Match.OptionalOrNull Number
      default: 440
      step: 1
      type: AEc.ConnectionTypes.Parameter
    ,
      name: 'detune'
      pattern: Match.OptionalOrNull Number
      default: 0
      step: 100
      type: AEc.ConnectionTypes.Parameter

  createSource: (context) ->
    context.createOscillator()
