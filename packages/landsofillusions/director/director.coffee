LOI = LandsOfIllusions

class LOI.Director
  constructor: ->
    @foregroundScriptQueue = new @constructor.ScriptQueue null
    @backgroundScriptQueue = new @constructor.ScriptQueue null

  startScript: (script, options = {}) ->
    queue = if options.background then @backgroundScriptQueue else @foregroundScriptQueue
    queue.startScript script, options

  startBackgroundScript: (script, options = {}) ->
    options.background = true
    @startScript script, options

  startNode: (scriptNode) ->
    @foregroundScriptQueue.startNode scriptNode
    
  startBackgroundNode: (scriptNode) ->
    @backgroundScriptQueue.startNode scriptNode

  scriptTransition: (endingScriptNode, nextScriptNode) ->
    isForeground = @foregroundScriptQueue.containsScriptNode endingScriptNode
    isBackground = @backgroundScriptQueue.containsScriptNode endingScriptNode

    console.log "Transitioning from", endingScriptNode, "to", nextScriptNode, isForeground, isBackground if LOI.debug

    # Give out a warning if we couldn't determine which queue to use
    if endingScriptNode and not (isForeground or isBackground)
      console.warn "Node to be transitioned from is not active.", endingScriptNode
      return

    queue = if isBackground then @backgroundScriptQueue else @foregroundScriptQueue
    queue.scriptTransition endingScriptNode, nextScriptNode

  pauseCurrentNode: ->
    @foregroundScriptQueue.pauseCurrentNode()

  stopAllScripts: (options = {}) ->
    console.log "Stopping all scripts." if LOI.debug
    @foregroundScriptQueue.stopAllScripts options
    @backgroundScriptQueue.stopAllScripts options

  setPosition: (positions) ->
    for thingId, position of positions
      continue unless position = LOI.adventure.world.getPositionVector position

      thing = LOI.adventure.getCurrentThing thingId
      position = LOI.adventure.world.findEmptySpace thing.avatar, position

      renderObject = thing.avatar.getRenderObject()
      renderObject.position.copy position

      physicsObject = thing.avatar.getPhysicsObject()
      physicsObject.setPosition position

  facePosition: (positions) ->
    for thingId, position of positions
      continue unless position = LOI.adventure.world.getPositionVector position

      thing = LOI.adventure.getCurrentThing thingId
      renderObject = thing.avatar.getRenderObject()

      direction = new THREE.Vector3().subVectors position, renderObject.position
      direction.normalize()
      renderObject.faceDirection direction
