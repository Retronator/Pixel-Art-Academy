AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Adventure.Interface extends AM.Component
  constructor: (@adventure) ->
    super

  onCreated: ->
    super

    # React to location changes.
    @location = ComputedField =>
      # Find the location we're at.
      location = @adventure.currentLocation()
      return unless location

      # Mark stored current location as visited (in this user session).
      @_currentLocationClass?.visited = true
      @_currentLocationClass = location.constructor

      @onLocationChanged location

      location

    # Listen to the script.
    @autorun (computation) =>
      location = @location()
      return unless location

      scriptNodes = location.director.currentScripts()

      # We handle scripts once per change.
      Tracker.nonreactive =>
        for scriptNode in scriptNodes
           @_handleScriptNode scriptNode

  onLocationChanged: (location) ->
    # Override to handle location changes.

  _handleScriptNode: (scriptNode) ->
    @_handleEmptyNode scriptNode if scriptNode instanceof Nodes.Script
    @_handleLabelNode scriptNode if scriptNode instanceof Nodes.Label
    @_handleDialogLine scriptNode if scriptNode instanceof Nodes.DialogLine
    @_handleConditional scriptNode if scriptNode instanceof Nodes.Conditional

  _handleEmptyNode: (scriptNode) ->
    # Simply end the node.
    scriptNode.end()

  _handleLabelNode: (scriptNode) ->
    # Every node we visit gets set to true on the state, so we can reference it later.
    state = @location().state()
    state[scriptNode.name] = true
    @location().state state

    # Automatically continue.
    scriptNode.end()

  _handleDialogLine: (dialogLine) ->
    console.log "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""

  _handleConditional: (conditional) ->
    # Give the state to the conditional so that it can evaluate which branch (true or false) to continue to.
    state = @location().state()
    conditional.end state

    # Trigger state change. Even though the conditional expressions are usually thought of as
    # read-only, one can still change state variables in them, for example [readCount++ > 10].
    @location().state state
