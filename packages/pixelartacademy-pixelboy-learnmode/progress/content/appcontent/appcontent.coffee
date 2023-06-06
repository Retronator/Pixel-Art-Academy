AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelBoy.Apps.LearnMode.Progress.Content.AppContent extends PAA.PixelBoy.Apps.LearnMode.Progress.Content.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress.Content.AppContent'
  @register @id()

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
