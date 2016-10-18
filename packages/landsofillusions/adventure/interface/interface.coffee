AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface extends AM.Component
  constructor: (@adventure) ->
    super

  onCreated: ->
    super

    # Listen to the script.
    @autorun (computation) =>
      # Find the location we're at.
      location = @adventure.currentLocation()
      return unless location

      scriptNodes = location.director.currentScripts()

      # We handle scripts once per change.
      Tracker.nonreactive =>
        for scriptNode in scriptNodes
           @_handleScriptNode scriptNode

  _handleScriptNode: (scriptNode) ->
    @_handleDialogLine scriptNode if scriptNode instanceof LOI.Adventure.Script.Nodes.DialogLine

  _handleDialogLine: (dialogLine) ->
    console.log "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""
