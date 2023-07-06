AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.TaskProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: -> @_task()?.completed()

  _task: -> PAA.Learning.Task.getAdventureInstanceForId @options.taskClass.id()

  # Total units

  completedRatio: -> if @completed() then 1 else 0
