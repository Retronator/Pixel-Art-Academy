AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Pages.Pixeltosh extends AM.Component
  @register 'PixelArtAcademy.Pixeltosh.Pages.Pixeltosh'

  @title: -> "Pixeltosh"
  @webApp: -> true
  @viewport: -> 'user-scalable=no, width=640'

  onCreated: ->
    super arguments...

    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 241
      minScale: 2
      
    @adventure = new PAA.Pixeltosh.Adventure

    @os = new PAA.Pixeltosh.OS

  onDestroyed: ->
    super arguments...
    
    @adventure.destroy()