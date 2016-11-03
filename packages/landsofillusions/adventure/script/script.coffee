LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Adventure.Script
  constructor: (@options) ->
    @startNode = @options.startNode

    # Gather all the nodes in this graph for easier processing.
    @nodes = []

    # First we add the main node.
    @_addNode @startNode

    # Second we add all the label nodes since some might be only reachable from jump calls.
    @_addNode label for labelName, label of @startNode.labels

    # Now process the script nodes.
    @_processOnServer() if Meteor.isServer
    @_processOnClient() if Meteor.isClient

  _processOnServer: ->
    # On the server we need to prepare translation documents for the script.

  _processOnClient: ->
    # On the client we need to load the translation documents.
    
    # Also replace jump nodes with actual label nodes they point to.
    for node in @nodes
      for property in ['node', 'next']
        if node[property] instanceof @constructor.Nodes.Jump
          jumpNode = node[property]
          node[property] = @startNode.labels[jumpNode.labelName]

    # Set the script reference to all nodes.
    node.script = @ for node in @nodes

    # Prepare the state objects.
    @state = new ReactiveField {}
    
    @ephemeralState = new ReactiveField {}
    @_stateChangeAutorun = AM.PersistentStorage.persist
      storageKey: "#{@options.id}.state"
      storage: sessionStorage
      field: @ephemeralState

  destroy: ->
    @_stateChangeAutorun.stop()

  id: ->
    @startNode.id

  setDirector: (director) ->
    # Set the director node on all the nodes.
    node.director = director for node in @nodes

  setActors: (actors) ->
    # Replace actor names with actual object instances.
    for node in @nodes
      if node.actor and _.isString node.actor
        unless actors[node.actor]
          console.warn "Unknown actor", node.actor
          return

        node.actor = actors[node.actor]

  setCallbacks: (callbacks) ->
    # Set callbacks to callback nodes
    for name, callback of callbacks
      unless @startNode.callbacks[name]
        console.warn "Unknown callback", name
        return

      @startNode.callbacks[name].callback = callback

  _addNode: (node) ->
    # Add the node only if it hasn't already added.
    return if not node or node in @nodes

    @nodes.push node

    # Recursively add the next and node node.
    @_addNode node.next
    @_addNode node.node
