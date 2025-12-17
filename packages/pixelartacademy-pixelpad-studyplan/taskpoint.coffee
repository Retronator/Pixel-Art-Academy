AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.TaskPoint extends StudyPlan.ConnectionPoint
  constructor: ->
    super arguments...
    
    @level = null
    @groupNumber = null
    @predecessors = []
    @tiles = []
    
  initializeTask: (@task, @goalNode) ->
    @_createConnectionPoints()
    @entryPoint.requiredInterests.push @task.requiredInterests()...

    @providedInterests.push @task.interests()...
    new StudyPlan.Pathway @, @exitPoint, @goalNode if @providedInterests.length
    
    @groupNumber = @task.groupNumber()
    @level = @task.level()

  initializeEndTask: (@goalNode) ->
    @_createConnectionPoints()
    @endTask = true
    
  initializeDummyTask: (@goalNode) ->
    @_createConnectionPoints()
    
  _createConnectionPoints: ->
    @entryPoint = StudyPlan.ConnectionPoint.createLocal @goalNode
    @entryPoint.taskPoint = @
    
    @exitPoint = StudyPlan.ConnectionPoint.createLocal @goalNode
    @exitPoint.taskPoint = @
    
    new StudyPlan.Pathway @entryPoint, @exitPoint, @goalNode
  
  setPositionX: (x) ->
    @localPosition.x = x
    @entryPoint.localPosition.x = x - 1
    @exitPoint.localPosition.x = x + 1
    
  setPositionY: (y) ->
    @localPosition.y = y
    @entryPoint.localPosition.y = y + 1
    @exitPoint.localPosition.y = y + 1
    
  clone: (newGoalNode, getConnectionPointClone) ->
    taskPoint = super arguments...
    taskPoint.task = @task
    taskPoint.endTask = @endTask
    taskPoint.tiles = @tiles
    
    taskPoint.entryPoint = getConnectionPointClone @entryPoint
    taskPoint.entryPoint.taskPoint = taskPoint

    taskPoint.exitPoint = getConnectionPointClone @exitPoint
    taskPoint.exitPoint.taskPoint = taskPoint
    
    @entryPoint.outgoingPathways[0].clone taskPoint.entryPoint, taskPoint.exitPoint, newGoalNode
    @outgoingPathways[0]?.clone taskPoint, taskPoint.exitPoint, newGoalNode

    taskPoint
  
  calculateGlobalPosition: (origin) ->
    super arguments...
    
    @entryPoint.calculateGlobalPosition origin
    @exitPoint.calculateGlobalPosition origin
