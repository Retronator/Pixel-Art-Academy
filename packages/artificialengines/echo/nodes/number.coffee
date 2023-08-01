AEc = Artificial.Echo

# We need to save the Number class to a temporary variable since it will get set to the new class definition below.
NumberType = Number

class AEc.Node.Number extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Number'
  @displayName: -> 'Number'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  @parameters: -> [
    name: 'number'
    pattern: Match.OptionalOrNull NumberType
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      @readParameter 'number'
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'

    @value
