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
  
  class @InvalidPartInstruction extends @Instruction
    @invalidPart: -> throw new AE.NotImplementedException "Invalid part instruction must determine the invalid part."
    
    @activeConditions: -> @invalidPart()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
    message: ->
      templateMessage = super arguments...
      
      return unless invalidPart = @constructor.invalidPart()
      
      templateMessage.replace "%%partName%%", invalidPart.fullName()
  
  class @InvalidPartRequiringACore extends @InvalidPartInstruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPartRequiringACore"

    @message: -> """
      Oh no, the %%partName%% seems to be invalid! Does it have at least a 3x3 area colored in?
    """
    
    @invalidPart: ->
      return unless pinball = @getPinball()
      
      partClassesRequiringACore = [
        Pinball.Parts.BallSpawner
        Pinball.Parts.BallTrough
        Pinball.Parts.Bumper
        Pinball.Parts.Flipper
        Pinball.Parts.Gate
        Pinball.Parts.GobbleHole
        Pinball.Parts.Plunger
        Pinball.Parts.SpinningTarget
      ]
      
      parts = []
      
      # If the parts view is open, we can determine if the part is OK before it is placed on the playfield.
      if partsView = pinball.os.interface.getView Pinball.Interface.Parts
        parts.push part for part in partsView.parts when part.constructor in partClassesRequiringACore
      
      # Even if the parts view is not open, make sure all parts
      # have their shape (parts view might not even be unlocked yet).
      for partClass in partClassesRequiringACore
        continue unless part = pinball.sceneManager()?.getPartOfType partClass
        parts.push part
        
      for part in parts
        continue unless shape = part.shape()
        return part if shape instanceof Pinball.Part.Avatar.Box
        
      null
      
    @initialize()
  
  class @InvalidPart extends @InvalidPartInstruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPart"
    
    @message: -> """
      Oh no, the %%partName%% seems to be invalid! Did you draw anything for it?
    """
    
    @invalidPart: ->
      return unless pinball = @getPinball()
     
      parts = _.clone pinball.sceneManager().parts()
      
      # If the parts view is open, we can determine if the part is OK before it is placed on the playfield.
      if partsView = pinball.os.interface.getView Pinball.Interface.Parts
        parts.push partsView.parts...

      for part in parts
        continue unless part.pixelArtEvaluation()
        return part unless part.shape()
      
      null
    
    @initialize()
