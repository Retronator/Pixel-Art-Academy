AEc = Artificial.Echo

class AEc.Node.KeepValue extends AEc.Node
  @type: -> 'Artificial.Echo.Node.KeepValue'
  @displayName: -> 'Keep Value'

  @initialize()

  @inputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @parameters: -> [
    name: 'minimumDuration'
    pattern: Match.OptionalOrNull Number
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]
  
  constructor: ->
    super arguments...

    @value = new ReactiveField null
    
    currentValueStartTime = null

    @autorun (computation) =>
      newValue = @readInput 'value'

      # We only want to recompute on changes of value.
      Tracker.nonreactive =>
        currentValue = @value()
        changeDelay = 0
        
        Meteor.clearTimeout @_changeValueTimeout

        # Make sure the current value will be output for the minimum amount of time.
        if currentValue
          minimumDuration = @readParameter('minimumDuration') * 1000
          currentDuration = Date.now() - currentValueStartTime
          changeDelay = Math.max 0, minimumDuration - currentDuration
        
        @_changeValueTimeout = Meteor.setTimeout =>
          @value newValue
          currentValueStartTime = Date.now()
        ,
          changeDelay

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'
    
    @value
