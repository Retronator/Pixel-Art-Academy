LOI = LandsOfIllusions

# We need to save the Number class to a temporary variable since it will get set to the new class definition below.
NumberType = Number

class LOI.Assets.Engine.Audio.Number extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Number'
  @nodeName: -> 'Number'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ]

  @parameters: -> [
    name: 'number'
    pattern: Match.OptionalOrNull NumberType
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      @readParameter 'number'

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'

    @value
