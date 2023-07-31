AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.removeNode.method (audioId, nodeId) ->
  check audioId, Match.DocumentId
  check nodeId,  Match.DocumentId

  LOI.Assets.Audio._authorizeAudioAction()

  audio = LOI.Assets.Audio._requireAudio audioId
  {node, nodeIndex} = LOI.Assets.Audio._requireNode audio, nodeId
  
  # Remove any connections to the node before we remove it.
  # Note: Minimongo does not support the positional operator $[], so we have to do the traversal manually.
  
  forward = $pull: {}
  backward = $push: {}
  
  connectionsFound = false
  
  for otherNode, otherNodeIndex in audio.nodes when otherNode isnt node and otherNode.connections
    for connection in otherNode.connections when connection.nodeId is nodeId
      forward.$pull["nodes.#{otherNodeIndex}.connections"] = {nodeId}
      backward.$push["nodes.#{otherNodeIndex}.connections"] = connection
      connectionsFound = true
      
  if connectionsFound
    audio._applyOperation forward, backward
    
    # Re-fetch to get the updated document.
    audio = LOI.Assets.Audio.documents.findOne audioId
  
  # Remove the node itself.
  
  forward = $pull: nodes: id: nodeId

  backward = $push: nodes:
    $each: [node]
    $position: nodeIndex

  if connectionsFound
    audio._applyOperationAndConnectHistory forward, backward

  else
    audio._applyOperation forward, backward
