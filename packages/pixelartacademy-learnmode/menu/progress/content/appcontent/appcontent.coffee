AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Progress.Content.AppContent extends LM.Menu.Progress.Content.Component
  @id: -> 'PixelArtAcademy.LearnMode.Menu.Progress.Content.AppContent'
  @register @id()

  iconUrl: ->
    appContent = @data()
    appContent.constructor.appClass.iconUrl()
