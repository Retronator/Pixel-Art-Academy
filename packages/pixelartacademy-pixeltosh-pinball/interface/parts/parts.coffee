LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Parts extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Parts'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball
    
    @partClasses = [
      Pinball.Parts.BallSpawner
      Pinball.Parts.Flipper
      Pinball.Parts.GobbleHole
      Pinball.Parts.Plunger
    ]
    
    @parts = for partClass in @partClasses
      new partClass @, => {}
  
  bitmapImageOptions: ->
    part = @currentData()
    
    bitmap: part.bitmap
