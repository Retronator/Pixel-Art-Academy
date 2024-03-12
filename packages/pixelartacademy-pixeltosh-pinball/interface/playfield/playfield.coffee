LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Pinball.Interface.Playfield extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Playfield'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram PAA.Pixeltosh.Programs.Pinball

  onRendered: ->
    super arguments...
    
    @$('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').append @pinball.rendererManager().renderer.domElement
