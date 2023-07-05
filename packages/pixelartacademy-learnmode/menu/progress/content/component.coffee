AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Progress.Content.Component extends AM.Component
  hasContentsClass: ->
    content = @data()
    'has-contents' if content.contents().length > 0

  showRequiredUnits: ->
    content = @data()
    content.progress.requiredUnits() and (not content.completed() or content.contents().length)

  showCompletedContentsCount: ->
    content = @data()
    content.contents().length and not @showRequiredUnits()

  completionistMode: ->
    LM.Menu.Progress.state('completionDisplayType') is LM.Menu.Progress.CompletionDisplayTypes.TotalPercentage

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
  
  completedContentsCountTitleAttribute: ->
    content = @data()
    return unless contents = content.contents()
  
    completedContentsCount = @completedContentsCount()
    completedRatio = completedContentsCount / contents.length
  
    title: "#{completedContentsCount}/#{contents.length} sections (#{@percentageString completedRatio})"

  percentageString: (ratio) ->
    "#{Math.floor ratio * 100}%"

  completedContentsCount: ->
    content = @data()
    return unless contents = content.contents()
  
    _.filter(contents, (content) => content.completed()).length
