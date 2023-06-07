AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelBoy.Apps.LearnMode.Progress.Content.Component extends AM.Component
  onCreated: ->
    super arguments...

    @learnMode = @ancestorComponentOfType PAA.PixelBoy.Apps.LearnMode

  hasContentsClass: ->
    content = @data()
    'has-contents' if content.contents().length > 0

  hasRequiredUnits: ->
    content = @data()
    content.progress.requiredUnits()

  hasTotalUnits: ->
    content = @data()
    content.progress.totalUnits()

  completionistMode: ->
    @learnMode.completionDisplayType() is PAA.PixelBoy.Apps.LearnMode.CompletionDisplayTypes.TotalPercentage

  totalPercentageTitleAttribute: ->
    content = @data()
    return unless units = content.progress.totalUnits()

    completedUnitsCount = content.progress.completedUnitsCount?()
    unitsCount = content.progress.unitsCount?()
    return unless completedUnitsCount? and unitsCount?

    title: "#{completedUnitsCount}/#{unitsCount} #{units}"

  requiredUnitsTitleAttribute: ->
    content = @data()
    return unless units = content.progress.requiredUnits()

    requiredCompletedUnitsCount = content.progress.requiredCompletedUnitsCount?()
    requiredUnitsCount = content.progress.requiredUnitsCount?()
    return unless requiredCompletedUnitsCount? and requiredUnitsCount?

    requiredCompletedRatio = content.progress.requiredCompletedRatio()
    title: "#{requiredCompletedUnitsCount}/#{requiredUnitsCount} #{units} (#{@percentageString requiredCompletedRatio})"

  percentageString: (ratio) ->
    "#{Math.round ratio * 100}%"
