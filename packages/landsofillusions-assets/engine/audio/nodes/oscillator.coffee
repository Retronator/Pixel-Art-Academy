LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Oscillator extends LOI.Assets.Engine.Audio.ScheduledNode
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Oscillator'
  @nodeName: -> 'Oscillator'

  @Types:
    Sine: 'sine'
    Square: 'square'
    Sawtooth: 'sawtooth'
    Triangle: 'triangle'
    Custom: 'custom'

  @initialize()

  @parameters: ->
    super(arguments...).concat
      name: 'frequency'
      pattern: Match.OptionalOrNull Number
      default: 440
      step: 10
      type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
    ,
      name: 'detune'
      pattern: Match.OptionalOrNull Number
      default: 0
      step: 100
      type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
    ,
      name: 'type'
      pattern: String
      options: _.values @Types
      default: @Types.Sine
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue

  createSource: (context) ->
    context.createOscillator()
