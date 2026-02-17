LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size.SmallestRecognizableSize extends PAA.Tutorials.Drawing.PixelArtFundamentals.Size.AssetWithReferences
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Size.SmallestRecognizableSize"
  
  @displayName: -> "Smallest recognizable size"
  
  @description: -> """
    To have recognizable subjects, their size needs to allow for representing their characteristic look.
  """
  
  @fixedDimensions: -> width: 78, height: 51
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
  @backgroundColor: ->
    paletteColor:
      ramp: 3
      shade: 0
    
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/smallestrecognizablesize-#{step}.png" for step in [1..10]
  
  @references: -> [
    image:
      url: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/smallestrecognizablesize-jungle.png"
    displayOptions:
      imageOnly: true
  ]
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    stepArea = @stepAreas()[0]
    
    new @constructor.GetReference @, stepArea, stepIndex: 0

  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
    ]
  
  Asset = @
  
  class @GetReference extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.EphemeralStep
    completed: ->
      # Wait until the image has a displayed reference.
      bitmap = @tutorialBitmap.bitmap()
      bitmap.references[0].displayed
    
  class @Reference extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Reference"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      Imagine you're drawing the chinese board game Jungle.
      Get the game board from the references tray to see the 8 animals you need to represent.
    """
    
    @initialize()
    
  class @Rat extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Rat"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      When deciding how big to make our sprites, we need the smallest of them to still be discernible.
      We start with the rat and apply simplification to arrive at the minimal amount of details that can convey it: the characteristic curved body and tail.
    """
    
    @initialize()

  class @Cat extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Cat"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      Cats have a characteristic head shape with relatively big ears.
      To make the ears distinct, we need the head to be (at least) 3 pixels wide.
    """
    
    @initialize()

  class @Cat2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Cat2"
    @assetClass: -> Asset
    @stepNumber: -> 4
    
    @message: -> """
      We give the cat a striped body with a lighter belly, a recognizable pattern for domestic cats.
    """
    
    @initialize()
  
  class @Dog extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Dog"
    @assetClass: -> Asset
    @stepNumber: -> 5
    
    @message: -> """
      The dog can be 1 pixel taller to distinguish it from the cat.
      The floppy ears and a longer snout serve as characteristic details.
    """
    
    @initialize()
  
  class @Wolf extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Wolf"
    @assetClass: -> Asset
    @stepNumber: -> 6
    
    @message: -> """
      The wolf has an even longer body and a typical gray-brown coat.
      We draw the ears like the cat, but we put the snout to the side to convey a bigger, fuller head.
    """
    
    @initialize()
  
  class @Leopard extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Leopard"
    @assetClass: -> Asset
    @stepNumber: -> 7
    
    @message: -> """
      For the leopard, we combine the shape language of the cat with the size of the wolf.
      We use an alternating (dithering) pattern to represent the dots on its coat.
    """
    
    @initialize()
  
  class @Tigers extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Tigers"
    @assetClass: -> Asset
    @stepNumber: -> 8
    
    @message: -> """
      The tiger is an even bigger cat, which gives us enough space to depict its characteristic black stripes.
    """
    
    @initialize()
  
  class @Lion extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Lion"
    @assetClass: -> Asset
    @stepNumber: -> 9
    
    @message: -> """
      Lions are known for their mane, so we give it a prominent place.
      The majestic sitting pose conveys its seat as the king of the animals.
    """
    
    @initialize()
  
  class @Elephant extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Elephant"
    @assetClass: -> Asset
    @stepNumber: -> 10
    
    @message: -> """
      Finally, the elephant needs a distinguished trunk and tusks to go with its big ears and the largest size.
    """
    
    @initialize()
  
  class @Smaller extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Smaller"
    @assetClass: -> Asset
    @stepNumber: -> 11
    
    @message: -> """
      If we try to go smaller than this, we have to start relying on context for the viewer to still recognize them.
    """
    
    @initialize()
  
  class @Completed extends PAA.Tutorials.Drawing.Instructions.CompletedInstruction
    @id: -> "#{Asset.id()}.Completed"
    @assetClass: -> Asset
    
    @message: -> """
      Since we've seen the bigger sprites first, we can connect the smaller ones with their bigger counterparts.
      But the two pixels of the rat, for example, are not readable on their own.
    """
    
    @initialize()
