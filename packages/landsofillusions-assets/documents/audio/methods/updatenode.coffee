AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.updateNode.method (audioId, nodeId, properties) ->
  check audioId, Match.DocumentId
  check nodeId,  Match.DocumentId
  check properties,
    position: Match.Optional
      x: Number
      y: Number
    expanded: Match.Optional Boolean

  LOI.Assets.Audio._authorizeAudioAction()

  audio = LOI.Assets.Audio._requireAudio audioId
  node = LOI.Assets.Audio._requireNode audio, nodeId

  forward = $set: {}
  backward = $set: {}

  change = false

  for property in ['position', 'expanded']
    if properties[property]
      forward.$set["nodes.#{nodeId}.#{property}"] = properties[property]
      backward.$set["nodes.#{nodeId}.#{property}"] = node[property]
      change = true

  throw new AE.ArgumentNullException "One of the properties needs to be updated." unless change

  audio._applyOperation forward, backward
