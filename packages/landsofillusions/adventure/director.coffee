LOI = LandsOfIllusions

class LOI.Adventure.Director
  constructor: (@location) ->
    @currentScripts = new ReactiveField []

  onCreated: ->
    super

    @autorun =>
      console.log "got new scrips", @currentScripts()

  startScript: (script) ->
    script.setDirector @

    @scriptTransition null, script.startNode

  endScript: (scriptNode) ->
    @scriptTransition scriptNode, null

  scriptTransition: (currentScriptNode, nextScriptNode) ->
    scriptNodes = @currentScripts()

    # Remove current script node.
    scriptNodes = _.without scriptNodes, currentScriptNode if currentScriptNode

    # Add new script node.
    scriptNodes.push nextScriptNode if nextScriptNode

    # Trigger update of running scripts.
    @currentScripts scriptNodes
