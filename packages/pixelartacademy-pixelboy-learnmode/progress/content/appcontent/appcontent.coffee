AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelBoy.Apps.LearnMode.Progress.Content.AppContent extends PAA.PixelBoy.Apps.LearnMode.Progress.Content.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress.Content.AppContent'
  @register @id()

  onCreated: ->
    super arguments...

    @learnMode = @ancestorComponentOfType PAA.PixelBoy.Apps.LearnMode

  showPercentage: ->
    content = @data()
    return false unless content.unlocked()

    return true if @learnMode.completionDisplayType() is PAA.PixelBoy.Apps.LearnMode.CompletionDisplayTypes.HundredPercent

    content.progress.requiredCompletedRatio?

  percentageString: (ratio) ->
    "#{Math.round ratio * 100}%"

  iconUrl: ->
    appContent = @data()
    appContent.constructor.appClass.iconUrl()

  showUnlockArea: ->
    appContent = @data()
    appContent.available() and not appContent.unlocked()

  events: ->
    super(arguments...).concat
      'click .app-unlock-button': @onClickAppUnlockButton

  onClickAppUnlockButton: (event) ->
    appContent = @data()
    @learnMode.unlockApp appContent.constructor.appClass.id()
