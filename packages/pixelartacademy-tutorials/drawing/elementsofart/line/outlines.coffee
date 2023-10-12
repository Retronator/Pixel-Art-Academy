LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Outlines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Outlines"
  
  @description: -> """
    If you join lines together, you can draw outlines of objects.
  """
  
  @fixedDimensions: -> width: 25, height: 25
  
  @svgUrl: -> null
  @referenceSvgUrls: -> [
    '/pixelartacademy/tutorials/drawing/elementsofart/line/outlines-banana.svg'
    '/pixelartacademy/tutorials/drawing/elementsofart/line/outlines-orange.svg'
    '/pixelartacademy/tutorials/drawing/elementsofart/line/outlines-apple.svg'
  ]
  
  @references: -> [
    '/pixelartacademy/tutorials/drawing/elementsofart/line/outlines-banana.jpg'
    '/pixelartacademy/tutorials/drawing/elementsofart/line/outlines-orange.jpg'
    '/pixelartacademy/tutorials/drawing/elementsofart/line/outlines-apple.jpg'
  ]
  
  @progressivePathCompletion: -> false
  
  @initialize()
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
  
  Asset = @
  
  class @Tray extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tray"
    @assetClass: -> Asset
    
    @message: -> """
        Open the references tray and choose an object you wish to draw.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the image has a displayed reference.
      bitmap = asset.bitmap()
      displayedReferences = _.filter bitmap.references, (reference) => reference.displayed
      not displayedReferences.length
    
    @priority: -> 1
    
    @initialize()
    
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the object's outline by combining straight, curved, and broken lines.
    """
    
    @initialize()
