AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Interface extends AM.Component
  constructor: (@options) ->
    super

    @interfaceReady = new ReactiveField false

  onCreated: ->
    super

    # React to location changes.
    @autorun (computation) =>
      # Find the location we're at.
      location = @location()
      return unless location

      # We only want to react to change of location.
      Tracker.nonreactive =>
        # Reset interface to not ready.
        @interfaceReady false

        # Mark stored current (previous) location as visited when location changes (in this user session).
        unless location.constructor is @_previousLocationClass
          @_previousLocationClass?.visited true

          # Now store the new location as the
          @_previousLocationClass = location.constructor

        # Do any initialization needed after location change.
        @onLocationChanged()

    # Listen to the script.
    @autorun (computation) =>
      # We want to wait until the interface is ready after the location change has been initiated.
      return unless @interfaceReady()

      scriptNodes = LOI.adventure.director.currentScriptNodes()

      console.log "Interface has detected new script nodes:", scriptNodes if LOI.debug

      # We handle scripts once per change.
      Tracker.nonreactive =>
        @_handleNode node for node in scriptNodes

  location: ->
    LOI.adventure.currentLocation()

  onLocationChanged: (location) ->
    # Override to handle location changes. Call "@interfaceReady true" when ready to start handling nodes.

  _handleNode: (node) ->
    @_handleEmpty node if node instanceof Nodes.Script
    @_handleEmpty node if node instanceof Nodes.Label
    @_handleDialogLine node if node instanceof Nodes.DialogLine
    @_handleNarrativeLine node if node instanceof Nodes.NarrativeLine
    @_handleInterfaceLine node if node instanceof Nodes.InterfaceLine
    @_handleCommandLine node if node instanceof Nodes.CommandLine

    # Handle Code nodes, which includes Conditional nodes since they inherit from Code.
    @_handleEmpty node if node instanceof Nodes.Code

    @_handleCallback node if node instanceof Nodes.Callback
    @_handleTimeout node if node instanceof Nodes.Timeout

  _handleEmpty: (scriptNode) ->
    # Simply end the node.
    scriptNode.end()

  _handleDialogLine: (dialogLine) ->
    console.log "#{dialogLine.actor.name} says: \"#{dialogLine.line}\""

  _handleNarrativeLine: (narrativeLine) ->
    console.log narrativeLine.line

  _handleCallback: (callback) ->
    unless callback.callback
      # No callback was set for this node. Give a warning and just skip it.
      console.warn "No callback is set for", callback.name
      callback.end()
      return

    # Call the callback and pass it the completion function.
    callback.callback =>
      callback.end()

  _handleTimeout: (timeout) ->
    Meteor.setTimeout =>
      timeout.end()
    ,
      timeout.milliseconds
