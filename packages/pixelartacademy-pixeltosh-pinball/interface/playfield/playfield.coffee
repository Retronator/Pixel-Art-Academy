LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Playfield extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Playfield'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball

  onRendered: ->
    super arguments...
    
    @$('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').append @pinball.rendererManager().renderer.domElement
