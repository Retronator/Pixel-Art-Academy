AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.removeNode.method (audioId, nodeId) ->
  check audioId, Match.DocumentId
  check nodeId,  Match.DocumentId

  LOI.Assets.Audio._authorizeAudioAction()

  audio = LOI.Assets.Audio._requireAudio audioId
  {node, nodeIndex} = LOI.Assets.Audio._requireNode audio, nodeId

  forward = {}
  backward = {}

  forward.$pull ?= {}
  forward.$pull.nodes = id: nodeId

  backward.$push ?= {}
  backward.$push.nodes =
    $each: [node]
    $position: nodeIndex

  # TODO: Remove all connections to this node.

  audio._applyOperation forward, backward
