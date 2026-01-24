AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.GoalProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: ->
    # The goal can be completed (with optional tasks left) or all the
    # completable tasks are completed (when the goal can't be completed).
    @_goal()?.completed() or @completedRatio() is 1

  _goal: -> PAA.Learning.Goal.getAdventureInstanceForId @options.goalClass.id()

  # Total units

  unitsCount: -> @_goal()?.completableTasks().length

  completedUnitsCount: -> _.filter(@_goal()?.tasks(), (task) -> task.completed()).length

  completedRatio: -> @completedUnitsCount() / @unitsCount()
