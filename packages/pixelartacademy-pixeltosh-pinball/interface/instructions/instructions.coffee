LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Instructions extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Instructions'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball
    
  ballsPerPlay: ->
    return unless playfield = @pinball.sceneManager()?.getPartOfType Pinball.Parts.Playfield
    playfield.data().ballsPerPlay
    
  hasPlunger: -> @_hasPart Pinball.Parts.Plunger
  hasFlipper: -> @_hasPart Pinball.Parts.Flipper
  
  _hasPart: (partClass) ->
    return unless sceneManager = @pinball.sceneManager()
    
    _.find sceneManager.parts(), (part) => part instanceof partClass
