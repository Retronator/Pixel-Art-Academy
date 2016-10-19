AM = Artificial.Mirage
LOI = LandsOfIllusions

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
    @_handleDialogLine scriptNode if scriptNode instanceof LOI.Adventure.Script.Nodes.DialogLine

  _handleDialogLine: (dialogLine) ->
    console.log "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""
