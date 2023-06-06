AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.GoalProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: -> @_goal()?.completed()

  _goal: -> PAA.Learning.Goal.getAdventureInstanceForId @options.goalClass.id()

  # Total units

  unitsCount: -> @_goal()?.tasks().length

  completedUnitsCount: -> _.filter(@_goal()?.tasks(), (task) -> task.completed()).length

  completedRatio: -> @completedUnitsCount() / @unitsCount()
