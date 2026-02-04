LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size.SmallestDetails extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Size.SmallestDetails"
  
  @displayName: -> "Smallest details"
  
  @description: -> """
    When the desired pixel size doesn't matter as much, we can choose the pixel art size to fit the subject's details.
  """
  
  @fixedDimensions: -> width: 81, height: 80
  @backgroundColor: -> new THREE.Color '#1c209e'
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 1, g: 1, b: 1]
      ]
  
  @referenceNames: -> ['genesis', 'snes', 'nes']
  
  @references: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/smallestdetails-#{name}.jpg" for name in @referenceNames()
  
  @stepsCount: ->
    nes: 16
    snes: 25
    genesis: 22
    
  @resources: ->
    goalChoices:
      for name in @referenceNames()
        referenceUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/smallestdetails-#{name}.jpg"
        steps: for number in [1..@stepsCount()[name]]
          goalPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/smallestdetails-#{name}-#{number}.png"
  
  @initialize()
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.Line
      PAA.Practice.Software.Tools.ToolKeys.Rectangle
      PAA.Practice.Software.Tools.ToolKeys.Ellipse
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
  
  Asset = @
  
  class @ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction
    @id: -> "#{Asset.id()}.ReferencesTrayInstruction"
    
    @assetClass: -> Asset
    @firstAssetClass: -> Asset
    
    @message: -> """
      Open the references tray and choose a controller you want to draw.
    """
    
    @initialize()
    
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @referenceUrlForName: (referenceName) ->
      "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/smallestdetails-#{referenceName}.jpg"
  
  class @FirstDetailChoice extends @StepInstruction
    @id: -> "#{Asset.id()}.FirstDetailChoice"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      When drawing from reference, we can decide on the smallest detail we want to convey.
      Let's choose the circle inside the directional pad and use a few pixels to represent its shape.
    """
    
    @initialize()
  
  class @Outline extends @StepInstruction
    @id: -> "#{Asset.id()}.Outline"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      Outline the directional pad around it.
    """
    
    @initialize()
    
  class @TheRest extends @StepInstruction
    @id: -> "#{Asset.id()}.TheRest"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      The rest of the drawing follows from this choice to achieve the desired proportions.
    """
    
    @initialize()
  
  class @SecondDetailChoice extends @StepInstruction
    @id: -> "#{Asset.id()}.SecondDetailChoice"
    @assetClass: -> Asset
    @stepNumber: (referenceUrl) ->
      switch referenceUrl
        when @referenceUrlForName('nes') then 9
        when @referenceUrlForName('snes') then 17
        when @referenceUrlForName('genesis') then 14
    
    @message: -> """
      If we make a different choice, we can achieve a smaller size with more simplification.
      Let's represent the directional pad with a simple cross.
    """
  
    @initialize()
  
  class @LessImportant extends @StepInstruction
    @id: -> "#{Asset.id()}.LessImportant"
    @assetClass: -> Asset
    @stepNumbers: (referenceUrl) ->
      switch referenceUrl
        when @referenceUrlForName('nes') then [11]
        when @referenceUrlForName('snes') then [21]
        when @referenceUrlForName('genesis') then [17, 18]
    
    @message: -> """
      We have to start skipping or simplifying less important details.
    """
    
    @initialize()
  
  class @Context extends @StepInstruction
    @id: -> "#{Asset.id()}.Context"
    @assetClass: -> Asset
    @stepNumber: (referenceUrl) ->
      switch referenceUrl
        when @referenceUrlForName('nes') then 12
        when @referenceUrlForName('snes') then 22
        when @referenceUrlForName('genesis') then 19
    
    @message: -> """
      Details that reduce to a single or double pixel can still be discernible if we can recognize them from context.
    """
    
    @initialize()
  
  class @ThirdDetailChoice extends @StepInstruction
    @id: -> "#{Asset.id()}.ThirdDetailChoice"
    @assetClass: -> Asset
    @stepNumber: (referenceUrl) ->
      switch referenceUrl
        when @referenceUrlForName('nes') then 14
        when @referenceUrlForName('snes') then 23
        when @referenceUrlForName('genesis') then 20
    
    @message: -> """
      This process can continue to achieve lower levels of detail.
      Let's make the directional pad a single pixel, the smallest it can be.
    """
    
    @initialize()
