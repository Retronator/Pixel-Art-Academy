AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.About extends Pinball.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.About"
  
  @displayName: -> "About Pinball Creation Kit..."
  
  @initialize()
  
  execute: ->
    @os.interface.displayDialog Pinball.Interface.About.createInterfaceData()
