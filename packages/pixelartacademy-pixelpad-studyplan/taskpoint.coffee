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
    
    if @providedInterests.length
      @taskExitPoint = StudyPlan.ConnectionPoint.createLocal @goalNode
      @taskExitPoint.taskPoint = @
      new StudyPlan.Pathway @, @taskExitPoint, @goalNode
      new StudyPlan.Pathway @taskExitPoint, @exitPoint, @goalNode
    
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
    @taskExitPoint?.localPosition.x = x
    @exitPoint.localPosition.x = x + 1
    
  setPositionY: (y) ->
    @localPosition.y = y
    @entryPoint.localPosition.y = y + 1
    @taskExitPoint?.localPosition.y = y + 1
    @exitPoint.localPosition.y = y + 1
    
  clone: (newGoalNode, getConnectionPointClone) ->
    taskPoint = super arguments...
    taskPoint.task = @task
    taskPoint.endTask = @endTask
    taskPoint.tiles = @tiles
    
    taskPoint.entryPoint = getConnectionPointClone @entryPoint
    taskPoint.entryPoint.taskPoint = taskPoint
    
    if @taskExitPoint
      taskPoint.taskExitPoint = getConnectionPointClone @taskExitPoint
      taskPoint.taskExitPoint.taskPoint = taskPoint

    taskPoint.exitPoint = getConnectionPointClone @exitPoint
    taskPoint.exitPoint.taskPoint = taskPoint
    
    @entryPoint.outgoingPathways[0].clone taskPoint.entryPoint, taskPoint.exitPoint, newGoalNode
    
    if @outgoingPathways[0]
      @outgoingPathways[0].clone taskPoint, taskPoint.taskExitPoint, newGoalNode
      @taskExitPoint.outgoingPathways[0].clone taskPoint.taskExitPoint, taskPoint.exitPoint, newGoalNode

    taskPoint
  
  calculateGlobalPosition: (origin) ->
    super arguments...
    
    @entryPoint.calculateGlobalPosition origin
    @taskExitPoint?.calculateGlobalPosition origin
    @exitPoint.calculateGlobalPosition origin
