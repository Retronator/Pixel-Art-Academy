LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Sound extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Sound'
  @nodeName: -> 'Sound'

  @initialize()

  @outputs: -> [
    name: 'stereo'
  ]
