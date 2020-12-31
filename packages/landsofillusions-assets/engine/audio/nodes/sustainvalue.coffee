LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.SustainValue extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.SustainValue'
  @nodeName: -> 'Sustain Value'

  @initialize()

  @inputs: -> [
    name: 'value'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  @outputs: -> [
    name: 'value'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  @parameters: -> [
    name: 'duration'
    pattern: Match.OptionalOrNull Number
    default: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Number
  ]
    
  constructor: ->
    super arguments...

    @_value = null
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
