LOI = LandsOfIllusions

class LOI.Adventure.Script
  constructor: (@options) ->
    @startNode = @options.startNode

    # Process the script nodes.
    @_processOnServer() if Meteor.isServer
    @_processOnClient() if Meteor.isClient

  _processOnServer: ->
    # On the server we need to prepare translation documents for the script.

  _processOnClient: ->
    # On the client we need to load the translation documents.
    
    # Also replace jump nodes with actual label nodes they point to.
    @_processNodes @startNode, (node) =>
      if node.next instanceof @constructor.Nodes.Jump
        jumpNode = node.next
        node.next = @startNode.labels[jumpNode.labelName]

  setActors: (actors) ->
    # Replace actor names with actual object instances.
    @_processNodes @startNode, (node) =>
      if node.actor and _.isString node.actor
        unless actors[node.actor]
          console.warn "Unknown actor", node.actor
          return

        node.actor = actors[node.actor]

  setDirector: (director) ->
    # Set the director node on all the nodes.
    @_processNodes @startNode, (node) =>
      node.director = director

  _processNodes: (node, action) ->
    # Call action on all the nodes of the script.
    loop
      action node

      # If the node has sub-nodes, process those too.
      @_processNodes node.node, action if node.node

      # Continue until we don't have a next node anymore.
      break unless node = node.next
