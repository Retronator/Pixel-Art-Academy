AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.removeNode.method (audioId, nodeId) ->
  check audioId, Match.DocumentId
  check nodeId,  Match.DocumentId

  LOI.Assets.Audio._authorizeAudioAction()

  audio = LOI.Assets.Audio._requireAudio audioId
  node = LOI.Assets.Audio._requireNode audio, nodeId

  forward = {}
  backward = {}

  forward.$unset ?= {}
  forward.$unset["nodes.#{nodeId}"] = true

  backward.$set ?= {}
  backward.$set["nodes.#{nodeId}"] = node

  # TODO: Remove all connections to this node.

  audio._applyOperation forward, backward
