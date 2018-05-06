LOI = LandsOfIllusions

class LOI.Director.ScriptQueue
  constructor: ->
    # Currently handled script node.
    @currentScriptNode = new ReactiveField null

    # We queue scripts to be started here.
    @queuedScriptNodes = new ReactiveField []

    # Scripts can be paused and will transition back into the queue when completed.
    @pausedScriptNodes = new ReactiveField []

    # Continuously pick scripts from the queue.
    Tracker.autorun (computation) =>
      # We don't start a new script until the previous one has stopped running.
      return if @currentScriptNode()

      queuedScriptNodes = @queuedScriptNodes()
      return unless queuedScriptNodes.length

      # Take the first node out of the queue and transition to it.
      nextScriptNode = queuedScriptNodes.shift()
      nextScriptNode.handled = false
      @currentScriptNode nextScriptNode

      # Update queued nodes.
      @queuedScriptNodes queuedScriptNodes

  containsScriptNode: (scriptNode) ->
    _.some [
      scriptNode is @currentScriptNode()
      scriptNode in @queuedScriptNodes()
      scriptNode in @pausedScriptNodes()
    ]

  startScript: (script, options = {}) ->
    if options.label
      startNode = script.startNode.labels[options.label]

    else
      startNode = script.startNode

    @startNode startNode

  startNode: (scriptNode) ->
    queuedScriptNodes = @queuedScriptNodes()
    queuedScriptNodes.push scriptNode
    @queuedScriptNodes queuedScriptNodes

  scriptTransition: (endingScriptNode, nextScriptNode) ->
    currentScriptNode = @currentScriptNode()
    pausedScriptNodes = @pausedScriptNodes()

    isActive = endingScriptNode is currentScriptNode
    isPaused = endingScriptNode in pausedScriptNodes

    console.log "Transitioning from", endingScriptNode, "to", nextScriptNode, "in queue", @, isActive, isPaused if LOI.debug

    # Give out warnings if nodes don't exist or are already present.
    console.warn "Node to be transitioned from is not active.", endingScriptNode if endingScriptNode and not (isActive or isPaused)
    console.warn "Node to be transitioned to is already active.", nextScriptNode if nextScriptNode and nextScriptNode is isActive or nextScriptNode in pausedScriptNodes

    # Mark the new node as not handled.
    nextScriptNode?.handled = false

    if isActive
      # Trigger update of current script.
      @currentScriptNode nextScriptNode

    else if isPaused
      # Remove ending script node.
      _.pull pausedScriptNodes, endingScriptNode

      @startNode nextScriptNode if nextScriptNode

      # Trigger update of paused scripts.
      @pausedScriptNodes pausedScriptNodes

  pauseCurrentNode: ->
    currentScriptNode = @currentScriptNode()

    # End current node to continue executing foreground scripts.
    @scriptTransition currentScriptNode, null

    # Put the node in paused nodes, so when transition comes, it will continue into queued nodes.
    pausedScriptNodes = @pausedScriptNodes()
    pausedScriptNodes.push currentScriptNode
    @pausedScriptNodes pausedScriptNodes

  stopAllScripts: (options = {}) ->
    @pausedScriptNodes [] unless options.paused is false
    @queuedScriptNodes []
    @currentScriptNode null
