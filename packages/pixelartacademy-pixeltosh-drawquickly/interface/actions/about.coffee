AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Actions.About extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Actions.About"
  
  @displayName: -> "About Draw Quickly ..."
  
  @initialize()
  
  execute: ->
    @os.interface.displayDialog DrawQuickly.Interface.About.createInterfaceData()
