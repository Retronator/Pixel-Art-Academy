LOI = LandsOfIllusions

class LOI.Director
  constructor: (@options) ->
    # Current foreground script.
    @currentScriptNode = new ReactiveField null

    # We queue foreground scripts to be started here.
    @queuedScriptNodes = new ReactiveField []

    # Foreground scripts can be paused and will transition into the queue when completed.
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

    # Current background scripts. These are handled continuously regardless of the foreground script.
    @backgroundScriptNodes = new ReactiveField []

  startScript: (script, options = {}) ->
    if options.label
      startNode = script.startNode.labels[options.label]

    else
      startNode = script.startNode

    if options.background
      @startBackgroundNode startNode

    else
      @startNode startNode

  startBackgroundScript: (script, options = {}) ->
    options.background = true
    @startScript script, options

  startNode: (scriptNode) ->
    queuedScriptNodes = @queuedScriptNodes()
    queuedScriptNodes.push scriptNode
    @queuedScriptNodes queuedScriptNodes

  startBackgroundNode: (scriptNode) ->
    scriptNode.handled = false
    backgroundScriptNodes = @backgroundScriptNodes()
    backgroundScriptNodes.push scriptNode

    @backgroundScriptNodes backgroundScriptNodes

  scriptTransition: (endingScriptNode, nextScriptNode) ->
    currentScriptNode = @currentScriptNode()
    pausedScriptNodes = @pausedScriptNodes()
    backgroundScriptNodes = @backgroundScriptNodes()

    isForeground = endingScriptNode is currentScriptNode
    isPaused = endingScriptNode in pausedScriptNodes
    isBackground = endingScriptNode in backgroundScriptNodes

    console.log "Transitioning from", endingScriptNode, "to", nextScriptNode, isForeground, isPaused, isBackground if LOI.debug

    # Give out warnings if nodes don't exist or are already present.
    console.warn "Node to be transitioned from is not active.", endingScriptNode if endingScriptNode and not (isForeground or isPaused or isBackground)
    console.warn "Node to be transitioned to is already active.", nextScriptNode if nextScriptNode and nextScriptNode is currentScriptNode or nextScriptNode in pausedScriptNodes or nextScriptNode in backgroundScriptNodes

    # Mark the new node as not handled.
    nextScriptNode?.handled = false

    if isForeground
      # Trigger update of current script.
      @currentScriptNode nextScriptNode

    else if isPaused
      # Remove ending script node.
      _.pull pausedScriptNodes, endingScriptNode

      @startNode nextScriptNode if nextScriptNode

      # Trigger update of paused scripts.
      @pausedScriptNodes pausedScriptNodes

    else if isBackground
      # Remove ending script node.
      _.pull backgroundScriptNodes, endingScriptNode

      # Add new script node.
      backgroundScriptNodes = _.union backgroundScriptNodes, [nextScriptNode] if nextScriptNode

      # Trigger update of running scripts.
      @backgroundScriptNodes backgroundScriptNodes

  pauseCurrentNode: ->
    currentScriptNode = @currentScriptNode()

    # End current node to continue executing foreground scripts.
    @scriptTransition currentScriptNode, null

    # Put the node in paused nodes, so when transition comes, it will continue into queued nodes.
    pausedScriptNodes = @pausedScriptNodes()
    pausedScriptNodes.push currentScriptNode
    @pausedScriptNodes pausedScriptNodes

  stopAllScripts: ->
    @backgroundScriptNodes []
    @pausedScriptNodes []
    @queuedScriptNodes []
    @currentScriptNode null
