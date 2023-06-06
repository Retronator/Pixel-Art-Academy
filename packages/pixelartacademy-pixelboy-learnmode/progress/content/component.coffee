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

  contentDepth: ->
    content = @data()

    # Count how many steps it takes till we get to the course parent.
    depth = 1

    while content not instanceof LM.Content.Course
      content = content.parent
      depth++

    depth

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
    totalUnitsCount = content.progress.totalUnitsCount?()
    return unless completedUnitsCount? and totalUnitsCount?

    title: "#{completedUnitsCount}/#{totalUnitsCount} #{units}"

  percentageString: (ratio) ->
    "#{Math.round ratio * 100}%"
