AEc = Artificial.Echo

class AEc.Node.SustainValue extends AEc.Node
  @type: -> 'Artificial.Echo.Node.SustainValue'
  @displayName: -> 'Sustain Value'

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
    name: 'duration'
    pattern: Match.OptionalOrNull Number
    default: 0
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Number
  ]
  
  constructor: ->
    super arguments...

    @value = new ReactiveField null

    @autorun (computation) =>
      newValue = @readInput 'value'

      currentValue = null
      duration = 0

      # We only want to recompute on changes of value.
      Tracker.nonreactive =>
        currentValue = @value()
        duration = @readParameter('duration') * 1000

      if currentValue
        # When changing an existing value, change it with the delay.
        Meteor.setTimeout =>
          @value newValue
        ,
          duration

      else
        # When setting a value from a falsy value, we immediately set it.
        @value newValue

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'
    
    @value
