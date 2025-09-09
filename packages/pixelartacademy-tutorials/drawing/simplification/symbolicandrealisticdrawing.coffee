LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.Simplification.SymbolicAndRealisticDrawing extends PAA.Tutorials.Drawing.Simplification.Asset
  @displayName: -> "Symbolic and realistic drawing"
  
  @description: -> """
    There are benefits to both realistic and simplified drawing.
  """

  @fixedDimensions: -> width: 107, height: 40
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/simplification/symbolicandrealisticdrawing.svg"
  @breakPathsIntoSteps: -> true
  
  @references: -> [
    '/pixelartacademy/tutorials/drawing/simplification/tutankhamun.jpg'
  ]
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    stepArea = @stepAreas()[0]
    
    new @constructor.GetReference @, stepArea, stepIndex: 4
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
    
  Asset = @
  
  class @GetReference extends TutorialBitmap.EphemeralStep
    completed: ->
      # Wait until the image has a displayed reference.
      bitmap = @tutorialBitmap.bitmap()
      bitmap.references[0].displayed
      
  class @Hieroglyph extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Hieroglyph"
    @assetClass: -> Asset
    
    @stepNumbers: -> [1, 2, 3, 4]
    
    @message: -> """
      The ancient Egyptian hieroglyph for "face" uses simplified shapes—symbols—to represent facial features.
    """
    
    @initialize()
  
  class @Reference extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Reference"
    @assetClass: -> Asset
    
    @stepNumber: -> 5
    
    @message: -> """
      Open the reference tray and get the image of how the pharaoh Tutankhamun might have actually looked.
    """
    
    @initialize()
    
  class @Real extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Real"
    @assetClass: -> Asset
    
    @stepNumbers: -> [6, 7, 8, 9]
    
    @message: -> """
      To draw accurately, we need to see and capture the shapes and lines as they actually are.
    """
    
    @initialize()
  
  class @Smiley extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Smiley"
    @assetClass: -> Asset
    
    @stepNumbers: -> [10, 11, 12]
    
    @message: -> """
      On the other hand, a simplified face has the power to represent anyone.
    """
    
    @initialize()
