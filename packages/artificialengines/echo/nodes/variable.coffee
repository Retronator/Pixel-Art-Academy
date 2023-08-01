AEc = Artificial.Echo

class AEc.Node.Variable extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Variable'
  @displayName: -> 'Variable'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @parameters: -> [
    name: 'id'
    pattern: String
    options: AEc.Variable.getVariableIds()
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      id = @readParameter 'id'
      variable = AEc.Variable.getVariableForId id
      variable?.value()
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'

    @value
