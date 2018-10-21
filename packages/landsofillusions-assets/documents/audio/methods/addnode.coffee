AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.addNode.method (audioId, nodeId, node) ->
  check audioId, Match.DocumentId
  check nodeId,  Match.DocumentId
  check node,
    type: String
    position:
      x: Number
      y: Number
    expanded: Boolean

  LOI.Assets.Audio._authorizeAudioAction()
  
  audio = LOI.Assets.Audio._requireAudio audioId

  forward = {}
  backward = {}

  if audio.nodes
    # Make sure the node doesn't already exist.
    throw new AE.InvalidOperationException "Node with this ID already exists." if audio.nodes?[nodeId]

    forward.$set ?= {}
    forward.$set["nodes.#{nodeId}"] = node

    backward.$unset ?= {}
    backward.$unset["nodes.#{nodeId}"] = true

  else
    # We have to create the nodes in the first place.
    nodes = {}
    nodes[nodeId] = node
    
    forward.$set ?= {}
    forward.$set.nodes = nodes

    backward.$unset ?= {}
    backward.$unset.nodes = true

  audio._applyOperation forward, backward
