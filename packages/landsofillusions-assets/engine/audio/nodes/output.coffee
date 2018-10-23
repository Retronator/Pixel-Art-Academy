LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Output extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Output'
  @nodeName: -> 'Output'

  @initialize()

  @inputs: -> [
    name: 'stereo'
  ]
