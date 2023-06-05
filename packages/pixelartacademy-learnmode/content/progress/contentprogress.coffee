AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ContentProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

    @_weights = (content.progress.weight() for content in @content.contents())

  completed: ->
    _.every (content.completed() for content in @content.contents())

  totalUnits: ->
    if @options.recursive
      _.sum (content.progress.totalUnits?() for content in @content.contents())

    else
      @content.contents().length

  requiredUnits: ->
    if @options.recursive
      _.sum (content.progress.requiredUnits?() for content in @content.contents())

    else
      @content.contents().length

  completedUnits: ->
    if @options.recursive
      _.sum (content.progress.completedUnits?() for content in @content.contents())

    else
      _.sum ((if content.completed() then 1 else 0) for content in @content.contents())

  completedRatio: ->
    @_weightedAverage (content.completedRatio() or 0 for content in @content.contents())

  requiredCompletedRatio: ->
    @_weightedAverage (content.requiredCompletedRatio() or 0 for content in @content.contents())

  _weightedAverage: (values) ->
    totalWeight = 0
    totalValue = 0

    for value, index in values when value?
      totalValue += value
      totalWeight += @_weights[index]

    totalValue / totalWeight
