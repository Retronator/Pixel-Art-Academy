AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Actions.Close extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.Actions.Close'
  @displayName: -> "Close"

  @initialize()
  
  execute: ->
    @os.removeWindow @os.activeWindowId()
