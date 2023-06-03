AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.GoalProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: -> @_goal()?.completed()

  completedRatio: -> @completedUnits() / @_goal()?.tasks().length

  completedUnits: -> _.filter(@_goal()?.tasks(), (task) -> task.completed()).length

  _goal: -> PAA.Learning.Goal.getAdventureInstanceForId @options.goalClass.id()
