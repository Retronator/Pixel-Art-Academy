AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio
  @debug = false

  @ConnectionTypes:
    Channels: 'Channels'
    Parameter: 'Parameter'
    ReactiveValue: 'ReactiveValue'

  @ValueTypes:
    Buffer: 'Buffer'
    Trigger: 'Trigger'
    Press: 'Press'
    Number: 'Number'
    String: 'String'

  constructor: (@options) ->
    @data = @options.audioData
    
    @_nodes = {}
    @_nodesDependency = new Tracker.Dependency

    @_connections = []
    @_connectionsDependency = new Tracker.Dependency

    @_waitingConnections = []

    @nodesDictionary = new AE.ReactiveDictionary =>
      nodes = {}

      if nodes = @data()?.nodes
        nodes[node.id] = node for node in nodes

      nodes  
    ,
      added: (nodeId, node) =>
        console.log "Added audio node", node if LOI.Assets.Engine.Audio.debug

        # Create a new engine node instance that will execute the required audio operation.
        nodeClass = LOI.Assets.Engine.Audio.Node.getClassForType node.type
        @_nodes[nodeId] = Tracker.nonreactive => new nodeClass nodeId, @, node.parameters
        @_rewireNode nodeId, null, node.connections
        @_processWaitingConnections()
        @_nodesDependency.changed()
        @_connectionsDependency.changed()

      updated: (nodeId, node, oldNode) =>
        # Relay (potentially) updated node parameters to the instance.
        @_nodes[nodeId].parametersData node.parameters
        @_rewireNode nodeId, oldNode.connections, node.connections
        @_processWaitingConnections()

      removed: (nodeId, node) =>
        console.log "Removed audio node", node if LOI.Assets.Engine.Audio.debug

        @_rewireNode nodeId, node.connections, null
        @_removeConnectionsToNode nodeId
        @_nodes[nodeId].destroy()
        delete @_nodes[nodeId]
        @_nodesDependency.changed()
        @_connectionsDependency.changed()
        
  destroy: ->
    @nodesDictionary.stop()

    # Remove all connections.
    for connection in @_connections
      startNode = @_nodes[connection.startNodeId]
      endNode = @_nodes[connection.endNodeId]
      startNode.disconnect endNode, connection.output, connection.input

    # Remove all nodes.
    node.destroy() for node in @_nodes
    
  world: ->
    if _.isFunction @options.world
      @options.world()
      
    else
      @options.world

  nodes: ->
    @_nodesDependency.depend()
    @_nodes

  getNode: (id) ->
    _.find @nodes(), (node) => node.id is id
    
  connections: ->
    @_connectionsDependency.depend()
    @_connections

  _rewireNode: (nodeId, previousConnections, currentConnections) ->
    # Create full connection objects.
    previousConnections = @_createConnections nodeId, previousConnections
    currentConnections = @_createConnections nodeId, currentConnections

    # Add new connections to waiting so they will be created when possible.
    addedConnections = _.differenceWith currentConnections, previousConnections, EJSON.equals
    @_waitingConnections.push addedConnections...

    # Unwire removed connections immediately.
    removedConnections = _.differenceWith previousConnections, currentConnections, EJSON.equals

    # Pull the connection from connections or waiting connections (it should be in one of those places).
    for connectionArray in [@_connections, @_waitingConnections]
      _.pullAllWith connectionArray, removedConnections, EJSON.equals

    # Now also make actual disconnections in the audio engine.
    for connection in removedConnections
      # Make sure the end node is still available since it might have been removed in the same update.
      continue unless endNode = @_nodes[connection.endNodeId]
      @_nodes[connection.startNodeId].disconnect endNode, connection.output, connection.input
      @_connectionsDependency.changed()

  _createConnections: (nodeId, connections) ->
    return [] unless connections

    for connection in connections
      startNodeId: nodeId
      endNodeId: connection.nodeId
      input: connection.input
      output: connection.output

  _removeConnectionsToNode: (nodeId) ->
    processedConnections = []

    for connection in @_connections
      continue unless connection.endNodeId is nodeId

      startNode = @_nodes[connection.startNodeId]
      endNode = @_nodes[nodeId]

      startNode.disconnect endNode, connection.output, connection.input
      processedConnections.push connection

      @_connectionsDependency.changed()

    _.pullAll @_connections, processedConnections

  _processWaitingConnections: ->
    processedConnections = []

    for connection in @_waitingConnections
      continue unless startNode = @_nodes[connection.startNodeId]
      continue unless endNode = @_nodes[connection.endNodeId]

      startNode.connect endNode, connection.output, connection.input
      processedConnections.push connection
      @_connections.push connection

      @_connectionsDependency.changed()

    _.pullAll @_waitingConnections, processedConnections
