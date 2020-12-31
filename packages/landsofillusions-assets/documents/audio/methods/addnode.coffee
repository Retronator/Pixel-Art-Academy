AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.addNode.method (audioId, node) ->
  check audioId, Match.DocumentId
  check node,
    id: Match.DocumentId
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
    existingNode = _.find audio.nodes, (existingNode) -> existingNode.id is node.id
    throw new AE.InvalidOperationException "Node with this ID already exists." if existingNode

    forward.$push ?= {}
    forward.$push.nodes = node

    backward.$pop = {}
    backward.$pop.nodes = 1

  else
    # We have to create the nodes in the first place.
    forward.$set ?= {}
    forward.$set.nodes = [node]

    backward.$unset ?= {}
    backward.$unset.nodes = true

  audio._applyOperation forward, backward
