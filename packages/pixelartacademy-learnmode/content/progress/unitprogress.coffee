AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.UnitProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: ->
    return @requiredCompletedUnitsCount() >= @requiredUnitsCount() if @requiredUnitsCount()

    @completedUnitsCount() > @unitsCount()

  # Total units

  unitsCount: -> _.propertyValue @options, 'unitsCount'

  completedUnitsCount: -> @options.completedUnitsCount()

  completedRatio: -> @completedUnitsCount() / @unitsCount()

  # Required units

  requiredUnitsCount: -> _.propertyValue @options, 'requiredUnitsCount'

  requiredCompletedUnitsCount: -> @options.requiredCompletedUnitsCount?() ? @options.completedUnitsCount()

  requiredCompletedRatio: -> if @requiredUnitsCount() then @requiredCompletedUnitsCount() / @requiredUnitsCount() else null
