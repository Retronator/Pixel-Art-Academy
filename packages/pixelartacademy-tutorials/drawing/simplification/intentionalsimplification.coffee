LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.Simplification.IntentionalSimplification extends PAA.Tutorials.Drawing.Simplification.Asset
  @displayName: -> "Intentional simplification"
  
  @description: -> """
    When we know how to draw realistically, we can control how and how far to simplify our drawings.
  """

  @fixedDimensions: -> width: 168, height: 88
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.ZXSpectrum
  @backgroundColor: ->
    paletteColor:
      ramp: 0
      shade: 0
      
  @steps: -> "/pixelartacademy/tutorials/drawing/simplification/intentionalsimplification-#{step}.png" for step in [1..5]
  
  @markup: -> true
  
  @bitmapInfo: ->
    """
      Artwork from games published by Code Masters, Firebird, Grandslam, Imagine, Made in Spain, Microsphere,
      Mirrorsoft, Ocean, Sinclair Research, and Ultimate Play The Game.
    """
    
  @bitmapInfoClass: -> 'small-print'
  
  @initialize()
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
    ]
  
  Asset = @
  
  class @Spectrum extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Spectrum"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Art exists on a spectrum between realistic and symbolic representation.
    """
    
    @initialize()
  
  class @Stylization extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Stylization"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      The amount of simplification leads to distinct art styles—stylization—each with its own set of feelings it's best at conveying.
    """
    
    @initialize()
  
  class @Details extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Details"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Artists choose to include or omit details to get their message across clearly.
    """
    
    @initialize()
  
  class @Shapes extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Shapes"
    @assetClass: -> Asset
    
    @stepNumber: -> 4
    
    @message: -> """
      They distort or smooth the shapes to evoke the emotions they desire.
    """
    
    @initialize()
  
  class @Simple extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Simple"
    @assetClass: -> Asset
    
    @stepNumber: -> 5
    
    @message: -> """
      Simple art styles are then not due to lack of skill, but often an intentional choice, which sometimes requires even more skill to achieve.
    """
    
    @initialize()

  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompletedInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
      
    @initialize()

    @gameNames =
      texts: [
        "Green\nBeret"
        "Peter\nBeardsley's\nInternational\nFootball"
        "Dizzy"
        "I Ball II"
        "Dynamite\nDan"
        "Skool\nDaze"
        "Sir\nFred"
        "Underwurlde"
        "Rick\nDangerous"
        "Head\nover\nHeels"
        "Stop\nthe\nExpress"
        "Atic\nAtac"
        "Cookie"
      ]
      colors: [
        5
        7
        7
        7
        5
        6
        6
        7
        4
        6
        4
        7
        7
      ]
      xs: [
        17
        29
        151
        140
        39
        49
        59
        70
        81
        93
        105
        118
        127
      ]
      ys: [
        76,
        12
      ]
      textOriginPositions: [
        Markup.TextOriginPosition.TopCenter
        Markup.TextOriginPosition.BottomCenter
      ]
    
    markup: ->
      return unless asset = @getActiveAsset()

      markup = []
      
      textBase = _.extend Markup.textBase(),
        size: 10,
        lineHeight: 12,
        outline: null
      
      palette = asset.palette()
      
      for gameIndex in [0..12]
        textColor = palette.color @constructor.gameNames.colors[gameIndex], 1
        
        markup.push
          text: _.extend {}, textBase,
            value: @constructor.gameNames.texts[gameIndex]
            style: "##{textColor.getHexString()}"
            position:
              x: @constructor.gameNames.xs[gameIndex]
              y: @constructor.gameNames.ys[gameIndex % 2]
              origin: @constructor.gameNames.textOriginPositions[gameIndex % 2]
      
      markup    
