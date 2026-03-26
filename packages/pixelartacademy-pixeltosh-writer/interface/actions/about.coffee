AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Writer = PAA.Pixeltosh.Programs.Writer

class Writer.Interface.Actions.About extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Writer.Interface.Actions.About"
  
  @displayName: -> "About Writer ..."
  
  @initialize()
  
  execute: ->
    @os.interface.displayDialog Writer.Interface.About.createInterfaceData()
