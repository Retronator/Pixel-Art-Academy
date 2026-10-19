PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Open extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Open'
  @displayName: -> "Open"
  @initialize()

  execute: ->
    @os.interface.displayDialog Pinball.Interface.OpenDialog.createInterfaceData()
