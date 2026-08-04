AE = Artificial.Everywhere
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
    
    # Notify tasks when they activate.
    @_activeTasks = new AE.ReactiveArray =>
      return [] unless LOI.adventure.gameState()
      _.filter @tasks, (task) => task.active()
    ,
      added: (task) =>
        Tracker.nonreactive => task.onActive()

    # Listen to all available automatic tasks.
    # Note: We shouldn't listen to active tasks, because we want to track completeness
    # whenever we can (even if the task is not active due to the goal not being active).
    @_automaticTasksAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventure.gameStateAvailable()

      for task in automaticTasks when task.available()
        if task.completedConditions()
          # Automatically create an entry for this task.
          PAA.Learning.Task.Entry.create profileId, LOI.adventure.currentSituationParameters(), task.id()

  destroy: ->
    super arguments...
    
    @_activeTasks.stop()
    @_automaticTasksAutorun.stop()
    goal.destroy() for goal in @goals

  getGoal: (goalClass) ->
    _.find @goals, (goal) => goal instanceof goalClass

  getTask: (taskClass) ->
    _.find @tasks, (task) => task instanceof taskClass
