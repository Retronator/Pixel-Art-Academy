AM = Artificial.Mummification
Persistence = AM.Document.Persistence
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Chapter extends LOI.Adventure.Chapter
  @goals: -> [] # Override to provide any learning goals that the chapter oversees.

  constructor: ->
    super arguments...

    # Handle learning goals for this chapter.
    goalClasses = _.filter PAA.Learning.Goal.getClasses(), (goalClass) => goalClass.chapter() is @constructor
    @goals = (new goalClass for goalClass in goalClasses)

    @tasks = _.flatten (goal.tasks() for goal in @goals)
    automaticTasks = _.filter @tasks, (task) => task instanceof PAA.Learning.Task.Automatic

    # We can count on the same profile ID since chapters get recreated when profile changes.
    profileId = LOI.adventure.profileId()

    # Listen to all active automatic tasks.
    @_automaticTasksAutorun = Tracker.autorun (computation) =>
      return unless Persistence.profileReady()

      for task in automaticTasks when task.active()
        if task.completedConditions()
          # Automatically create an entry for this task.
          PAA.Learning.Task.Entry.create profileId, LOI.adventure.currentSituationParameters(), task.id()

  destroy: ->
    super arguments...

    @_automaticTasksAutorun.stop()
    goal.destroy() for goal in @goals

  getGoal: (goalClass) ->
    _.find @goals, (goal) => goal instanceof goalClass

  getTask: (taskClass) ->
    _.find @tasks, (task) => task instanceof taskClass
