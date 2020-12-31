LOI = LandsOfIllusions

class LOI.Director
  @debugDirector = false

  constructor: ->
    @foregroundScriptQueue = new @constructor.ScriptQueue
    @backgroundScriptQueue = new @constructor.ScriptQueue
    @realtimeScriptQueue = new @constructor.ScriptQueue autoPause: true

    @queues = [
      @foregroundScriptQueue
      @backgroundScriptQueue
      @realtimeScriptQueue
    ]

  startScript: (script, options = {}) ->
    if options.background
      queue = @backgroundScriptQueue

    else if options.realtime
      queue = @realtimeScriptQueue

    else
      queue = @foregroundScriptQueue

    queue.startScript script, options

  startBackgroundScript: (script, options = {}) ->
    options.background = true
    @startScript script, options

  startRealtimeScript: (script, options = {}) ->
    options.realtime = true
    @startScript script, options

  startNode: (scriptNode) ->
    @foregroundScriptQueue.startNode scriptNode
    
  startBackgroundNode: (scriptNode) ->
    @backgroundScriptQueue.startNode scriptNode

  startRealtimeNode: (scriptNode) ->
    @realtimeScriptQueue.startNode scriptNode

  scriptTransition: (endingScriptNode, nextScriptNode) ->
    isForeground = @foregroundScriptQueue.containsScriptNode endingScriptNode
    isBackground = @backgroundScriptQueue.containsScriptNode endingScriptNode
    isRealtime = @realtimeScriptQueue.containsScriptNode endingScriptNode

    console.log "Transitioning from", endingScriptNode, "to", nextScriptNode, isForeground, isBackground, isRealtime if LOI.debug or LOI.Director.debugDirector

    # Give out a warning if we couldn't determine which queue to use
    if endingScriptNode and not (isForeground or isBackground or isRealtime)
      console.warn "Node to be transitioned from is not active.", endingScriptNode
      return

    if isBackground
      queue = @backgroundScriptQueue

    else if isRealtime
      queue = @realtimeScriptQueue

    else
      queue = @foregroundScriptQueue

    queue.scriptTransition endingScriptNode, nextScriptNode

  pauseCurrentNode: ->
    @foregroundScriptQueue.pauseCurrentNode()

  stopAllScripts: (options = {}) ->
    console.log "Stopping all scripts." if LOI.debug or LOI.Director.debugDirector
    queue.stopAllScripts options for queue in @queues

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
      renderObject.facePosition position
