AEc = Artificial.Echo

class AEc.Node.ValueEquals extends AEc.Node
  @type: -> 'Artificial.Echo.Node.ValueEquals'
  @displayName: -> 'Value Equals'

  @initialize()

  @inputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'equals'
    type: AEc.ConnectionTypes.Boolean
  ]

  @parameters: -> [
    name: 'values'
    pattern: [String]
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ]
  
  constructor: ->
    super arguments...
    
    @equals = new ComputedField =>
      return unless value = @readInput('value')?.toString()
    
      values = @readParameter 'values'
      
      # Create arrays if needed.
      if values?
        values = [values] unless _.isArray values
        
      else
        values = []
      
      value in values
    ,
      true
    
  destroy: ->
    super arguments...
    
    @equals.stop()
  
  getReactiveValue: (output) ->
    return super arguments... unless output is 'equals'
    
    @equals
