AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Delete extends Pinball.Interface.Actions.Action
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Delete"
  
  @displayName: -> "Delete"
  
  @initialize()
  
  enabled: -> @pinball.editorManager()?.selectedPart()?.constructor.editable()
  
  execute: ->
    @pinball.editorManager().removeSelectedPart()
