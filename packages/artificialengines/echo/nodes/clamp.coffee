AEc = Artificial.Echo

# We need to save the Number class to a temporary variable since it will get set to the new class definition below.
NumberType = Number

class AEc.Node.Clamp extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Clamp'
  @displayName: -> 'Clamp'

  @initialize()
  
  @inputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  @parameters: -> [
    name: 'minimum'
    pattern: NumberType
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ,
    name: 'maximum'
    pattern: NumberType
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      inputValue = @readInput 'value'

      minimum = @readParameter 'minimum'
      maximum = @readParameter 'maximum'

      _.clamp inputValue, minimum, maximum
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'

    @value
