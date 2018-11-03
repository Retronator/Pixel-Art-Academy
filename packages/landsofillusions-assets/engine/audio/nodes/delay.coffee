LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Delay extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Delay'
  @nodeName: -> 'Delay'

  @initialize()

  @inputs: -> [
    name: 'in'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  @outputs: -> [
    name: 'out'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'delayTime'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    min: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ,
    name: 'maxDelayTime'
    pattern: Match.OptionalOrNull Number
    default: 1
    max: 180
    min: 0
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  constructor: ->
    super arguments...

    @node = new ComputedField =>
      return unless audioManager = @audioManager()
      return unless audioManager.contextValid()

      # We must create a new delay node each time max delay time changes.
      maxDelayTime = @readParameter 'maxDelayTime'

      audioManager.context.createDelay maxDelayTime

    @autorun (computation) =>
      return unless node = @node()

      node.delayTime.value = @readParameter 'delayTime'

  getDestinationConnection: (input) ->
    return super arguments... unless input is 'in'

    destination: @node()

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node()
