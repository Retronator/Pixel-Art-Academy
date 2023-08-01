AE = Artificial.Everywhere
AEc = Artificial.Echo
LOI = LandsOfIllusions

LOI.Assets.Audio.updateNodeParameters.method (audioId, nodeId, parameters) ->
  check audioId, Match.DocumentId
  check nodeId, Match.DocumentId

  LOI.Assets.Audio._authorizeAudioAction()

  audio = LOI.Assets.Audio._requireAudio audioId
  {node, nodeIndex} = LOI.Assets.Audio._requireNode audio, nodeId

  # Nothing to do if same parameters are sent in.
  return if EJSON.equals parameters, node.parameters

  nodeClass = AEc.Node.getClassForType node.type
  parametersInfo = nodeClass.parameters()

  # Make sure the new parameters match the required patterns.
  for parameterName, parameterValue of parameters
    parameterInfo = _.find parametersInfo, (parameterInfo) => parameterInfo.name is parameterName
    throw new AE.ArgumentException "Parameter #{parameterName} is not valid for node type #{node.type}" unless parameterInfo

    check parameterValue, parameterInfo.pattern

  if node.parameters
    forward = $set: {}
    backward = $set: {}

    for parameterName, parameterValue of parameters
      forward.$set["nodes.#{nodeIndex}.parameters.#{parameterName}"] = parameterValue
      backward.$set["nodes.#{nodeIndex}.parameters.#{parameterName}"] = node.parameters[parameterName]

  else
    forward = $set: "nodes.#{nodeIndex}.parameters": parameters
    backward = $unset: "nodes.#{nodeIndex}.parameters": true

  audio._applyOperation forward, backward
