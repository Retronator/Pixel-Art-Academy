AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ManualProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: -> @options.completed()

  completedRatio: -> @options.completedRatio?() or if @options.completed?() then 1 else 0

  completedUnits: -> @options.completedUnits?() ? null

  requiredCompletedRatio: -> @options.requiredCompletedRatio?() ? null
