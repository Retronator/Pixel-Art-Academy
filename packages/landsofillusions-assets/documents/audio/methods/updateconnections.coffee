AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Audio.updateConnections.method (audioId, nodeId, addedConnection, removedConnection) ->
  check audioId, Match.DocumentId
  check nodeId,  Match.DocumentId
  check addedConnection, Match.OptionalOrNull connectionPattern
  check removedConnection, Match.OptionalOrNull connectionPattern

  LOI.Assets.Audio._authorizeAudioAction()

  audio = LOI.Assets.Audio._requireAudio audioId
  node = LOI.Assets.Audio._requireNode audio, nodeId

  forward = {}
  backward = {}

  # See if we need to create the connections array.
  if node.connections
    if removedConnection
      # Make sure the connection to be removed exists.
      existingConnectionIndex = _.findIndex node.connections, (connection) => EJSON.equals connection, removedConnection
      throw new AE.ArgumentException "Connection to be removed does not exist." unless existingConnectionIndex > -1

      if addedConnection
        existingConnection = _.find node.connections, (connection) => EJSON.equals connection, addedConnection
        throw new AE.ArgumentException "Connection to be added already exists." if existingConnection

        # We are modifying an existing connection. Simply replace it in place.
        forward.$set ?= {}
        forward.$set["nodes.#{nodeId}.connections.#{existingConnectionIndex}"] = addedConnection

        backward.$set ?= {}
        backward.$set["nodes.#{nodeId}.connections.#{existingConnectionIndex}"] = removedConnection

      else
        # We are removing a connection.
        forward.$pull ?= {}
        forward.$pull["nodes.#{nodeId}.connections"] = removedConnection

        backward.$push ?= {}
        backward.$push["nodes.#{nodeId}.connections"] =
          $each: [removedConnection]
          $position: existingConnectionIndex

    else if addedConnection
      # Make sure the connection to be added doesn't already exist.
      existingConnection = _.find node.connections, (connection) => EJSON.equals connection, addedConnection
      throw new AE.ArgumentException "Connection to be added already exists." if existingConnection

      # We are adding a connection.
      forward.$push ?= {}
      forward.$push["nodes.#{nodeId}.connections"] = addedConnection

      backward.$pop ?= {}
      backward.$pop["nodes.#{nodeId}.connections"] = 1

    else
      throw new AE.ArgumentException "A connection needs to be added, removed, or both."

  else
    # We have to create the connections in the first place. Make sure connection is only being added in this step.
    throw new AE.ArgumentException "Connection to be removed does not exist." if removedConnection
    throw new AE.ArgumentException "No connection to be added was specified." unless addedConnection

    forward.$set ?= {}
    forward.$set["nodes.#{nodeId}.connections"] = [addedConnection]

    backward.$unset ?= {}
    backward.$unset["nodes.#{nodeId}.connections"] = true

  audio._applyOperation forward, backward

connectionPattern =
  nodeId: Match.DocumentId
  input: String
  output: String
