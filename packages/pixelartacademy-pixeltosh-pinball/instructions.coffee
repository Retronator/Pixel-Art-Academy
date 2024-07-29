AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Instructions
  class @Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
    @getPinball: ->
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof PAA.Pixeltosh.Programs.Pinball
      program
    
  class @InvalidPlayfield extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPlayfield"
    
    @message: -> """
      Oh no, the playfield seems to be invalid! Do you have any overlapping holes, perhaps?
    """
      
    @activeConditions: ->
      return unless pinball = @getPinball()
      
      # Show when the playfield doesn't have a valid shape.
      return unless playfield = pinball.sceneManager()?.getPartOfType Pinball.Parts.Playfield
      return unless shape = playfield.shape()
      not shape.geometryData.indexBufferArray.length
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
  
  class @InvalidGate extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidGate"
    
    @message: -> """
      Oh no, the gate seems to be invalid! Does it have at least a 3x3 area colored in?
    """
    
    @activeConditions: ->
      return unless pinball = @getPinball()
      
      # Show when the playfield doesn't have a valid shape.
      return unless gate = pinball.sceneManager()?.getPartOfType Pinball.Parts.Gate
      return unless shape = gate.shape()
      shape not instanceof Pinball.Parts.Gate.Shape
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
  class @InvalidSpinningTarget extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidSpinningTarget"
    
    @message: -> """
      Oh no, the spinner seems to be invalid! Does it have at least a 3x3 area colored in?
    """
    
    @activeConditions: ->
      return unless pinball = @getPinball()
      
      # Show when the playfield doesn't have a valid shape.
      return unless spinningTarget = pinball.sceneManager()?.getPartOfType Pinball.Parts.SpinningTarget
      return unless shape = spinningTarget.shape()
      shape not instanceof Pinball.Parts.SpinningTarget.Shape
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
