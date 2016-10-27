AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Adventure.Interface extends AM.Component
  constructor: (@options) ->
    super

    @adventure = @options.adventure

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

  _handleNode: (node) ->
    @_handleEmpty node if node instanceof Nodes.Script
    @_handleEmpty node if node instanceof Nodes.Label
    @_handleDialogLine node if node instanceof Nodes.DialogLine
    @_handleNarrativeLine node if node instanceof Nodes.NarrativeLine

    # Handle Code nodes, which includes Conditional nodes since they inherit from Code.
    @_handleEmpty node if node instanceof Nodes.Code

    @_handleCallback node if node instanceof Nodes.Callback

  _handleEmpty: (scriptNode) ->
    # Simply end the node.
    scriptNode.end()

  _handleDialogLine: (dialogLine) ->
    console.log "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""

  _handleNarrativeLine: (narrativeLine) ->
    console.log narrativeLine.line

  _handleCallback: (callback) ->
    # Call the callback and pass it the completion function.
    callback.callback =>
      callback.end()
