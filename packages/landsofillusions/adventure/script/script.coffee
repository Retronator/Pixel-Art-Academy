LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Adventure.Script
  @_scriptClassesById = {}

  @getClassForId: (id) ->
    @_scriptClassesById[id]

  @initialize: ->
    # Store script class by ID.
    @_scriptClassesById[@id()] = @

    @stateAddress = new LOI.StateAddress "scripts.#{@id()}"
    @state = new LOI.StateObject address: @stateAddress
    
  constructor: (@options) ->
    @startNode = @options.startNode
    @things = {}

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
    character = LOI.character()

    # Process nodes.
    for node in @nodes
      # Save the original next so we can query it in cases when nodes get rewired.
      node.originalNext = node.next

      # Replace jump nodes with actual label nodes they point to.
      for property in ['node', 'next']
        if node[property] instanceof @constructor.Nodes.Jump
          jumpNode = node[property]
          node[property] = @startNode.labels[jumpNode.labelName]

      # Replace char actor with character instance's avatar.
      node.actor = character?.avatar if node.actorName is 'char'

      if node instanceof @constructor.Nodes.Choice
        if node.node.actorName is 'player'
          # We want to force the player to say this, so don't set the actor.
          node.node.actor = null
          
        else if character
          # When synced with the character, character delivers choice node dialog.
          node.node.actor = character.avatar

    # Set the script reference to all nodes.
    node.script = @ for node in @nodes

    # Prepare the state objects.
    @stateAddress = @constructor.stateAddress
    @state = @constructor.state

    @ephemeralState = new LOI.EphemeralStateObject

    @_stateChangeAutorun = AM.PersistentStorage.persist
      storageKey: "#{@id()}.state"
      storage: sessionStorage
      field: @ephemeralState.field()

    # On the client, do any custom initialization logic.
    @initialize()

  destroy: ->
    @_stateChangeAutorun.stop()

  id: ->
    @startNode.id

  initialize: -> # Override to setup the script on the client.

  # Sets things that have a shorthand name in the script (actors, thing variables in script context).
  setThings: (things = {}) ->
    _.extend @things, things

    # Set actors to thing instances, based on actor names.
    for node in @nodes
      if node.actorName
        node.actor = things[node.actorName] if things[node.actorName]

      if node.line
        # Store the original line text so we can later retrieve it.
        node.sourceLine ?= node.line

        # Start substitutions with the original line.
        node.line = node.sourceLine

        # Perform avatar substitutions.
        for shorthand, person of @things when person instanceof LOI.Character.Person
          node.line = LOI.Character.formatText node.line, shorthand, person, true

  setCurrentThings: (thingClasses) ->
    Tracker.autorun (computation) =>
      return unless LOI.adventureInitialized()

      things = {}
      for key, thingClass of thingClasses
        return unless things[key] = LOI.adventure.getCurrentThing thingClass
        return unless things[key].ready()

      computation.stop()

      @setThings things

  setCallbacks: (callbacks) ->
    # Set callbacks to callback nodes
    for name, callback of callbacks
      unless @startNode.callbacks[name]
        console.warn "Unknown callback", name
        continue

      for callbackNode in @startNode.callbacks[name]
        callbackNode.callback = callback

  startAtLatestCheckpoint: (checkpointLabels) ->
    for label, index in checkpointLabels
      # Start at this checkpoint if we haven't reached the next one yet.
      nextLabel = checkpointLabels[index + 1]

      unless nextLabel and @state nextLabel
        LOI.adventure.director.startScript @, {label}
        return

  _addNode: (node) ->
    # Add the node only if it hasn't already added.
    return if not node or node in @nodes

    @nodes.push node

    # Recursively add the next and node node.
    @_addNode node.next
    @_addNode node.node
