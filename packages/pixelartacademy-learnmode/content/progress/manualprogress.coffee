AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ManualProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: -> @options.completed()

  # Total units

  unitsCount: -> _.propertyValue @options, 'unitsCount'

  completedUnitsCount: -> @options.completedUnitsCount?()

  completedRatio: ->
    return @options.completedRatio() if @options.completedRatio

    if @options.completed() then 1 else 0

  # Required units

  requiredUnitsCount: -> _.propertyValue @options, 'requiredUnitsCount'

  requiredCompletedUnitsCount: -> @options.requiredCompletedUnitsCount?() ? @options.completedUnitsCount()

  requiredCompletedRatio: ->
    return @options.requiredCompletedRatio() if @options.requiredCompletedRatio

    completedUnitsCount = @completedUnitsCount()
    requiredUnitsCount = @requiredUnitsCount()

    return unless completedUnitsCount? and requiredUnitsCount?

    completedUnitsCount / requiredUnitsCount
