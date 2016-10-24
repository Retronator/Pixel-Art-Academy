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
        @_handleNode node for node in scriptNodes

  onLocationChanged: (location) ->
    # Override to handle location changes.

  _handleNode: (scriptNode) ->
    @_handleEmpty scriptNode if scriptNode instanceof Nodes.Script
    @_handleLabel scriptNode if scriptNode instanceof Nodes.Label
    @_handleDialogLine scriptNode if scriptNode instanceof Nodes.DialogLine

    # Handle Code nodes, which includes Conditional nodes since they inherit from Code.
    @_handleCode scriptNode if scriptNode instanceof Nodes.Code

  _handleEmpty: (scriptNode) ->
    # Simply end the node.
    scriptNode.end()

  _handleLabel: (scriptNode) ->
    # Every node we visit gets set to true on the state, so we can reference it later.
    state = @location().state()
    state[scriptNode.name] = true
    @location().state state

    # Automatically continue.
    scriptNode.end()

  _handleDialogLine: (dialogLine) ->
    console.log "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""

  _handleCode: (code) ->
    # Give the location state to the code to use as context for the variables.
    state = @location().state()
    code.end state

    # Trigger reactive state change.
    @location().state state
