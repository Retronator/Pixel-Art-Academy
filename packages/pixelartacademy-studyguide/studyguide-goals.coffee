PAA = PixelArtAcademy

PAA.StudyGuide.initializeGoal = (goalId) ->
  # Nothing to do if the goal has already been initialized.
  return if PAA.Learning.Goal.getClassForId goalId

  class PAA.StudyGuide.Goals[goalId] extends PAA.Learning.Goal
    @id: -> goalId

    # Study Guide goal's name will be edited in the database.
    @displayName: -> null

    # Study Guide goals are not tied to a chapter.
    @chapter: -> null

    @activity: -> PAA.StudyGuide.Activity.documents.findOne {goalId}

    @tasks: ->
      return [] unless activityTasks = @activity()?.tasks

      for task in activityTasks
        PAA.Learning.Task.getClassForId task.id

    @finalTasks: ->
      return [] unless finalTasks = @activity()?.finalTasks

      for finalTaskId in finalTasks
        PAA.Learning.Task.getClassForId finalTaskId

    @finalGroupNumber: ->
      @activity()?.finalGroupNumber or super arguments...

    @requiredInterests: ->
      @activity()?.requiredInterests or super arguments...

    @initialize()

    slug: ->
      return unless translations = @displayNameTranslation()?.translations
      displayName = translations?.en?.us?.text or translations?.best?.text or null
      _.kebabCase displayName
