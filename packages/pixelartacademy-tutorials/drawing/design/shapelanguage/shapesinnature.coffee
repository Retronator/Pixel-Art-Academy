AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapesInNature extends PAA.Tutorials.Drawing.Design.ShapeLanguage.Asset
  @displayName: -> "Shapes in nature"

  @description: -> """
    The shapes we see in the world give us emotions.
  """

  @fixedDimensions: -> width: 131, height: 63
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
  @backgroundColor: ->
    paletteColor:
      ramp: 7
      shade: 0
  
  @resources: ->
    paths: new @Resource.SvgPaths @createResourceUrl "#{@lessonFileName()}.svg"
    circles: new @Resource.ImagePixels @createLessonResourceUrl "1.png"
    squares: new @Resource.ImagePixels @createLessonResourceUrl "2.png"
    triangles: new @Resource.ImagePixels @createLessonResourceUrl "3.png"
    
  @markup: -> true
    
  @initialize()
  
  initializeSteps: ->
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    stepArea = new @constructor.StepArea @, stepAreaBounds
    
    svgPaths = Array.from @resources.paths.svgPaths()
    
    # Circle
    
    new @constructor.PathStep @, stepArea,
      svgPaths: [svgPaths[0]]
    
    new @constructor.PathStep @, stepArea,
      svgPaths: svgPaths[1..2]
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.circles
      
    # Square
    
    new @constructor.PathStep @, stepArea,
      svgPaths: [svgPaths[3]]
    
    new @constructor.PathStep @, stepArea,
      svgPaths: svgPaths[4..5]
      preserveCompleted: true
      hasPixelsWhenInactive: false
    
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.squares
    
    # Triangle
    
    new @constructor.PathStep @, stepArea,
      svgPaths: [svgPaths[6]]
    
    new @constructor.PathStep @, stepArea,
      svgPaths: svgPaths[7..8]
      preserveCompleted: true
      hasPixelsWhenInactive: false
    
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.triangles
  
  Asset = @

  class @Circle extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Circle"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      A circle is the friendliest basic shape. Without any corners, it's soft, squishy, and approachable.
    """
    
    @initialize()
  
  class @Circle2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Circle2"
    @assetClass: -> Asset
    @stepNumbers: -> [2, 3]
    
    @message: -> """
      Nutritious fruit or baby animals often have round shapes, evoking happiness and innocence.
    """
    
    @initialize()
  
  class @Square extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Square"
    @assetClass: -> Asset
    @stepNumber: -> 4
    
    @message: -> """
      A square appears sturdy and grounded, offering both stability and support.
    """
    
    @initialize()
  
  class @Square2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Square2"
    @assetClass: -> Asset
    @stepNumbers: -> [5, 6]
    
    @message: -> """
      Rock formations such as cliffs and mesas give a sense of permanence and safety.
    """
    
    @initialize()
  
  class @Triangle extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Triangle"
    @assetClass: -> Asset
    @stepNumber: -> 7
    
    @message: -> """
      A triangle is sharp and tense.
    """
    
    @initialize()
    
  class @Triangle2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Triangle2"
    @assetClass: -> Asset
    @stepNumbers: -> [8, 9]
    
    @message: -> """
      Fangs, horns, spikes, and thorns are used to attack and defend, signaling power and danger.
    """
    
    @initialize()
  
  class @Completed extends PAA.Tutorials.Drawing.Instructions.CompletedInstruction
    @id: -> "#{Asset.id()}.Completed"
    @assetClass: -> Asset
    
    @message: -> """
      This is how shapes intuitively communicate meaning and emotions.
    """
    
    @initialize()

    markup: ->
      textBase = Markup.textBase()
      textBase.size *= 2
      textBase.lineHeight *= 2
      textBase.position = y: 43, origin: Markup.TextOriginPosition.TopCenter
      textBase.outline = style: "#fff1e8"
      
      [
        text: _.merge {}, textBase,
          position: x: 20
          value: """
            friendly
            playful
            soft
            light
            squishy
          """
      ,
        text: _.merge {}, textBase,
          position: x: 65
          value: """
            strong
            stable
            reliable
            supportive
            rigid
          """
      ,
        text: _.merge {}, textBase,
          position: x: 110
          value: """
            sharp
            dangerous
            dynamic
            unpredictable
            tense
          """
      ]
