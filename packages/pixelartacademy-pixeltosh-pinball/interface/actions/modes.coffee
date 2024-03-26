AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Mode extends Pinball.Interface.Actions.Action
  @mode: -> throw new AE.NotImplementedException "The mode action has to provide the mode it activates."
  @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.#{@mode()}"
  
  @displayName: -> @mode()
  
  enabled: -> true
  
  active: -> @pinball.gameManager()?.mode() is @constructor.mode()
  
  execute: ->
    @pinball.gameManager()[_.toLower @constructor.mode()]()
    
class Pinball.Interface.Actions.Edit extends Pinball.Interface.Actions.Mode
  @mode: -> Pinball.GameManager.Modes.Edit
  @initialize()
  
class Pinball.Interface.Actions.Test extends Pinball.Interface.Actions.Mode
  @mode: -> Pinball.GameManager.Modes.Test
  @initialize()
  
class Pinball.Interface.Actions.Play extends Pinball.Interface.Actions.Mode
  @mode: -> Pinball.GameManager.Modes.Play
  @initialize()
