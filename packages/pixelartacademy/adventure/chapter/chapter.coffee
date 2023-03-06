LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure.Chapter extends LOI.Adventure.Chapter
  @goals: -> [] # Override to provide any learning goals that the chapter oversees.

  constructor: ->
    super arguments...

    # Handle learning goals for this chapter.
    goalClasses = _.filter PAA.Learning.Goal.getClasses(), (goalClass) => goalClass.chapter() is @constructor
    @goals = (new goalClass for goalClass in goalClasses)

    @tasks = _.flatten (goal.tasks() for goal in @goals)
    automaticTasks = _.filter @tasks, (task) => task instanceof PAA.Learning.Task.Automatic
    automaticTaskIds = (task.id() for task in automaticTasks)

    # We can count on the same character ID since chapters get recreated when characters change.
    characterId = LOI.characterId()

    @_automaticTaskEntriesSubscription = PAA.Learning.Task.Entry.forCharacterTaskIds.subscribe characterId, automaticTaskIds

    # Listen to all active automatic tasks.
    @_automaticTasksAutorun = Tracker.autorun (computation) =>
      return unless @_automaticTaskEntriesSubscription.ready()

      for task in automaticTasks when task.active()
        if task.completedConditions()
          # Automatically create an entry for this task.
          PAA.Learning.Task.Entry.insert characterId, LOI.adventure.currentSituationParameters(), task.id()

  destroy: ->
    super arguments...

    @_automaticTaskEntriesSubscription.stop()
    @_automaticTasksAutorun.stop()
    goal.destroy() for goal in @goals
