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
    
  initializeTask: (@task) ->
    @_createConnectionPoints()
    @entryPoint.requiredInterests.push @task.requiredInterests()

    @providedInterests.push @task.interests()
    new StudyPlan.Pathway @, @exitPoint if @providedInterests.length
    
    @groupNumber = @task.groupNumber()
    @level = @task.level()

  initializeEndTask: ->
    @_createConnectionPoints()
    @endTask = true
    
  initializeDummyTask: ->
    @_createConnectionPoints()
    
  _createConnectionPoints: ->
    @entryPoint = new StudyPlan.ConnectionPoint
    @exitPoint = new StudyPlan.ConnectionPoint
    new StudyPlan.Pathway @entryPoint, @exitPoint
  
  setPositionX: (x) ->
    @localPosition.x = x
    @entryPoint.localPosition.x = x - 1
    @exitPoint.localPosition.x = x + 1
    
  setPositionY: (y) ->
    @localPosition.y = y
    @entryPoint.localPosition.y = y + 1
    @exitPoint.localPosition.y = y + 1
    
  clone: ->
    taskPoint = super arguments...
    
    taskPoint.entryPoint = @entryPoint.clone()
    taskPoint.exitPoint = @exitPoint.clone()
    
    @entryPoint.outgoingPathways[0].clone taskPoint.entryPoint, taskPoint.exitPoint
    @outgoingPathways[0]?.clone taskPoint, taskPoint.exitPoint

    taskPoint.endTask = @endTask

    taskPoint
