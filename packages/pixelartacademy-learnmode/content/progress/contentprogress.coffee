AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ContentProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

    @_weights = (content.progress.weight() for content in @content.contents())

  completed: ->
    return unless @content.unlocked()
    _.every (content.progress.completed() for content in @content.contents())

  totalUnits: -> _.sum (content.progress.totalUnits?() for content in @content.contents())

  requiredUnits: -> _.sum (content.progress.requiredUnits?() for content in @content.contents())

  completedUnits: -> _.sum (content.progress.completedUnits?() for content in @content.contents())

  completedRatio: ->
    return 0 unless @content.unlocked()
    @_weightedAverage (content.progress.completedRatio() for content in @content.contents())

  requiredCompletedRatio: ->
    return 0 unless @content.unlocked()
    @_weightedAverage (content.progress.requiredCompletedRatio?() for content in @content.contents())

  _weightedAverage: (values) ->
    totalWeight = 0
    totalValue = 0

    for value, index in values when value?
      totalValue += value
      totalWeight += @_weights[index]

    totalValue / totalWeight
