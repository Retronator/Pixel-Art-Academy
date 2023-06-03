AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.UnitProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  totalUnits: -> _.propertyValue @options, 'totalUnits'

  requiredUnits: -> _.propertyValue @options, 'requiredUnits'

  completedUnits: -> @options.completedUnits()

  completed: -> @completedUnits() >= @totalUnits()

  completedRatio: -> @completedUnits() / @totalUnits()

  requiredCompletedRatio: -> if @requiredUnits() then @completedUnits() / @requiredUnits() else null
