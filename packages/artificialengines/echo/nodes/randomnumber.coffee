AEc = Artificial.Echo

class AEc.Node.RandomNumber extends AEc.Node
  @type: -> 'Artificial.Echo.Node.RandomNumber'
  @displayName: -> 'Random Number'

  @initialize()
  
  @inputs: -> [
    name: 'generate'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Trigger
  ]
  
  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]

  @parameters: -> [
    name: 'minimum'
    pattern: Number
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ,
    name: 'maximum'
    pattern: Number
    default: 1
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ,
    name: 'integer'
    pattern: Boolean
    default: false
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Boolean
  ]

  constructor: ->
    super arguments...
    
    @value = new ReactiveField @_generate()
    
    # Reactively generate new values.
    @autorun (computation) =>
      return unless @readInput 'generate'
      @value @_generate()
      
  _generate: ->
    minimum = @readParameter 'minimum'
    maximum = @readParameter 'maximum'
    
    if integer = @readParameter 'integer'
      minimum = Math.floor minimum
      maximum = Math.floor maximum
      
    range = Math.abs maximum - minimum
    lowest = Math.min minimum, maximum
    
    if integer
      lowest + Math.floor (range + 1) * Math.random()
      
    else
      lowest + range * Math.random()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'

    @value
