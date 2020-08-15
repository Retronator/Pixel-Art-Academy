PAA = PixelArtAcademy

PAA.StudyGuide.initializeTask = (goalId, taskId, taskType) ->
  # Nothing to do if the task has already been initialized and has a matching type.
  existingTask = PAA.Learning.Task.getClassForId taskId
  return if existingTask?.type() is taskType

  TaskClass = PAA.Learning.Task[taskType]

  class PAA.StudyGuide.Tasks[taskId] extends TaskClass
    @id: -> taskId
    @goal: -> PAA.Learning.Goal.getClassForId goalId

    # Study Guide task strings will be edited in the database.
    @directive: -> null
    @instructions: -> null

    @activity: -> PAA.StudyGuide.Activity.documents.findOne {goalId}
    @taskDescription: ->
      return unless activity = @activity()

      _.find activity.tasks, (task) => task.id is taskId

    @icon: ->
      @taskDescription()?.interests or super arguments...

    @interests: ->
      @taskDescription()?.interests or super arguments...

    @requiredInterests: ->
      @taskDescription()?.requiredInterests or super arguments...

    @predecessors: ->
      return [] unless predecessors = @taskDescription()?.predecessors

      for predecessorTaskId in predecessors
        PAA.Learning.Task.getClassForId predecessorTaskId

    @predecessorsCompleteType: ->
      @taskDescription()?.predecessorsCompleteType or super arguments...

    @groupNumber: ->
      @taskDescription()?.groupNumber or super arguments...

    @initialize()
