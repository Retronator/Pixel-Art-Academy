AEc = Artificial.Echo

class AEc.Node.ValueChange extends AEc.Node
  @type: -> 'Artificial.Echo.Node.ValueChange'
  @displayName: -> 'Value Change'

  @initialize()

  @inputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'change'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @parameters: -> [
    name: 'from'
    pattern: [String]
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ,
    name: 'to'
    pattern: [String]
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ]
  
  constructor: ->
    super arguments...
    
    @change = new ReactiveField false
    
    @autorun (computation) =>
      newValue = @readInput('value')?.toString()
      
      # Trigger change when we're changing between listed values from a different value (excluding initial state).
      if @value isnt undefined
        fromValues = @readParameter 'from'
        toValues = @readParameter 'to'
        
        # Create arrays if needed.
        if fromValues?
          fromValues = [fromValues] unless _.isArray fromValues
        
        if toValues?
          toValues = [toValues] unless _.isArray toValues
          
        fromValue = if fromValues then @value in fromValues else true
        toValue = if toValues then newValue in toValues else true
        
        if fromValue and toValue and newValue isnt @value
          @change true
          
          Meteor.setTimeout =>
            @change false
      
      @value = newValue
  
  getReactiveValue: (output) ->
    return super arguments... unless output is 'change'
    
    @change
