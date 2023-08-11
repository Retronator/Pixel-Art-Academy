AEc = Artificial.Echo

# We need to save the Boolean class to a temporary variable since it will get set to the new class definition below.
BooleanType = Boolean

class AEc.Node.Boolean extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Boolean'
  @displayName: -> 'Boolean'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Boolean
  ]

  @parameters: -> [
    name: 'boolean'
    pattern: Match.OptionalOrNull BooleanType
    default: false
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Boolean
  ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      @readParameter 'boolean'
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'

    @value
