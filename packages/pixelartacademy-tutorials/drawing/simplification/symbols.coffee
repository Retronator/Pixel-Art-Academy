LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification.Symbols extends PAA.Tutorials.Drawing.Simplification.Asset
  @displayName: -> "Symbols"
  
  @description: -> """
    When we look at the world, our eyes see shapes, but our mind sees concepts.
  """

  @fixedDimensions: -> width: 157, height: 33
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/simplification/symbols.svg"
  @breakPathsIntoSteps: -> true
  @pathTolerance: -> 1
  
  @initialize()
  
  Asset = @
  
  class @House extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.House"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      As children, our drawings represent the objects and things that happen in our lives.
    """
    
    @initialize()
  
  class @Face extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Face"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      They are not realistic depictions of what we see, but simple marks that stand in for those things. They are symbols.
    """
    
    @initialize()
  
  class @Heart extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Heart"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      They capture the concepts our minds use to organize the complex world around us.
    """
    
    @initialize()
  
  class @Sun extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Sun"
    @assetClass: -> Asset
    
    @stepNumber: -> 4
    
    @message: -> """
      We create and learn such symbols as a conventional representation of things around us.
    """
    
    @initialize()
  
  class @Cloud extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Cloud"
    @assetClass: -> Asset
    
    @stepNumber: -> 5
    
    @message: -> """
      If asked to draw something, we will then reproduce these symbols instead of how things actually look.
    """
    
    @initialize()
  
  class @Person extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Person"
    @assetClass: -> Asset
    
    @stepNumber: -> 6
    
    @message: -> """
      Without developing our drawing skills to capture what the eye really sees, we get stuck at the symbolic drawing level.
    """
    
    @initialize()
