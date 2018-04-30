AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Interface extends AM.Component
  constructor: (@options) ->
    super

    @locationChangeReady = new ReactiveField false

  onCreated: ->
    super

    # React to location changes.
    @autorun (computation) =>
      # Wait to run until interface is fully operational.
      return unless @isRendered()

      # Find the location we're at.
      location = @location()
      return unless location

      # We only want to react to change of location.
      Tracker.nonreactive =>
        # Reset interface to not ready.
        @locationChangeReady false

        # Mark stored current (previous) location as visited when location changes (in this user session).
        unless location.constructor is @_previousLocationClass
          @_previousLocationClass?.visited true

          # Now store the new location as the
          @_previousLocationClass = location.constructor

        # Clear the current contexts.
        LOI.adventure.exitContext()
        LOI.adventure.clearAdvertisedContext()

        # Do any initialization needed after location change.
        @onLocationChanged()

    # Listen to the foreground script.
    @autorun (computation) =>
      return unless @_readyToProcessScriptNodes()
      return unless scriptNode = LOI.adventure.director.currentScriptNode()

      console.log "Interface has detected a new foreground script node:", scriptNode if LOI.debug

      Tracker.nonreactive => @_handleNode scriptNode

    # Listen to the background scripts.
    @autorun (computation) =>
      return unless @_readyToProcessScriptNodes()
      scriptNodes = LOI.adventure.director.backgroundScriptNodes()

      console.log "Interface has detected new background script nodes:", scriptNodes if LOI.debug

      Tracker.nonreactive =>
        @_handleNode node, background: true for node in scriptNodes

  _readyToProcessScriptNodes: ->
    # We want to wait until the interface is ready after the location change has been initiated.
    return unless @locationChangeReady()

    # We also don't want to process new nodes while UI isn't active or it is waiting for user interaction.
    return unless @active()
    return if @waitingKeypress()

    true

  location: ->
    LOI.adventure.currentLocation()

  context: ->
    LOI.adventure.currentContext()

  onLocationChanged: (location) ->
    # Override to handle location changes. Call "@locationChangeReady true" when ready to start handling nodes.
    
  ready: -> true

  _handleNode: (node, options = {}) ->
    return if node.handled unless options.force

    # Mark node as handled to avoid double handling.
    node.handled = true

    @_handleEmpty node, options if node instanceof Nodes.Script
    @_handleEmpty node, options if node instanceof Nodes.Label
    @_handleDialogueLine node, options if node instanceof Nodes.DialogueLine
    @_handleNarrativeLine node, options if node instanceof Nodes.NarrativeLine
    @_handleInterfaceLine node, options if node instanceof Nodes.InterfaceLine
    @_handleCommandLine node, options if node instanceof Nodes.CommandLine
    @_handleEmpty node, options if node instanceof Nodes.ChoicePlaceholder

    # Handle Code nodes, which includes Conditional nodes since they inherit from Code.
    @_handleEmpty node, options if node instanceof Nodes.Code

    @_handleCallback node, options if node instanceof Nodes.Callback
    @_handleTimeout node, options if node instanceof Nodes.Timeout

  _handleEmpty: (scriptNode) ->
    # Simply end the node.
    scriptNode.end()

  _handleDialogueLine: (dialogueLine) ->
    console.log "#{dialogueLine.actor.name} says: \"#{dialogueLine.line}\""

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
