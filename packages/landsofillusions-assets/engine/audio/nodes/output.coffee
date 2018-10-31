LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Output extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Output'
  @nodeName: -> 'Output'

  @initialize()

  @inputs: -> [
    name: 'in'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  getDestinationConnection: (input) ->
    return unless audioManager = @audioManager()

    if input is 'in' and audioManager.contextValid()
      destination: audioManager.context.destination
