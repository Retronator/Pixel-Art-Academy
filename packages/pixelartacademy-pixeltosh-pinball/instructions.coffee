AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Instructions
  class @InvalidPlayfield extends PAA.PixelPad.Systems.Instructions.Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPlayfield"
    
    @message: -> """
        Oh no, the playfield seems to be invalid! Do you have any overlapping holes, perhaps?
      """
    
    @getPinball: ->
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof PAA.Pixeltosh.Programs.Pinball
      program
      
    @activeConditions: ->
      return unless pinball = @getPinball()
      
      # Show when the playfield doesn't have a valid shape.
      return unless playfield = pinball.sceneManager()?.getPartOfType Pinball.Parts.Playfield
      return unless shape = playfield.shape()
      not shape.geometryData.indexBufferArray.length
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
