AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Actions.About extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Actions.About'
  @displayName: -> "About the Finder..."

  @initialize()
  
  execute: ->
    @os.interface.displayDialog PAA.Pixeltosh.Programs.Finder.About.createInterfaceData()
