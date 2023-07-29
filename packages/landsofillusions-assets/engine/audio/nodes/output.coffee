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
    return super arguments... unless context = @audio.context()

    if input is 'in'
      destination: context.destination
