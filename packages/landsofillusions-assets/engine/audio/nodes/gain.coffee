LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Gain extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Gain'
  @nodeName: -> 'Gain'

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
    name: 'gain'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ]

  constructor: ->
    super arguments...

    @node = new ComputedField =>
      return unless audioManager = @audioManager()
      return unless audioManager.contextValid()
      
      audioManager.context.createGain()

    @autorun (computation) =>
      return unless node = @node()

      node.gain.value = @readParameter 'gain'

  getDestinationConnection: (input) ->
    empty = super arguments...

    switch input
      when 'in'
        destination: @node()

      when 'gain'
        destination: @node()?.gain

      else
        empty

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node()
