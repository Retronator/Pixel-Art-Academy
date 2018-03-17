LOI = LandsOfIllusions

class LOI.Director
  constructor: (@options) ->
    @currentScriptNodes = new ReactiveField []
    
    # We queue scripts to be started here.
    @queuedScriptNodes = new ReactiveField []

    Tracker.autorun (computation) =>
      # We don't start new scripts until the previous one has stopped running.
      return if @currentScriptNodes().length
      
      queuedScriptNodes = @queuedScriptNodes()
      
      if queuedScriptNodes.length
        nextScriptNode = queuedScriptNodes.shift()
        @scriptTransition null, nextScriptNode

        @queuedScriptNodes queuedScriptNodes

  startScript: (script, options = {}) ->
    if options.label
      startNode = script.startNode.labels[options.label]

    else
      startNode = script.startNode

    @startNode startNode

  stopAllScripts: ->
    @queuedScriptNodes []
    @currentScriptNodes []

  startNode: (scriptNode) ->
    queuedScriptNodes = @queuedScriptNodes()
    queuedScriptNodes.push scriptNode
    @queuedScriptNodes queuedScriptNodes

  scriptTransition: (currentScriptNode, nextScriptNode) ->
    scriptNodes = @currentScriptNodes()

    # Give out warnings if nodes don't exist or are already present.
    console.warn "Node to be transitioned from is not active.", currentScriptNode if currentScriptNode and not (currentScriptNode in scriptNodes)
    console.warn "Node to be transitioned to is already active.", nextScriptNode if nextScriptNode in scriptNodes

    # Remove current script node.
    scriptNodes = _.without scriptNodes, currentScriptNode if currentScriptNode

    # Add new script node.
    scriptNodes = _.union scriptNodes, [nextScriptNode] if nextScriptNode

    # Mark the new node as not handled.
    nextScriptNode?.handled = false

    # Trigger update of running scripts.
    @currentScriptNodes scriptNodes
