LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size.DisplayResolution extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Size.DisplayResolution"
  
  @displayName: -> "Display resolution"
  
  @description: -> """
    The size of pixel art images originates from the display resolutions of old computers and consoles.
  """
  
  @bitmapInfo: -> "Artwork from Frogger (Dragon 32/64, ColecoVision), Konami, 1983"
  
  @fixedDimensions: -> width: 350, height: 200
  @backgroundColorStyle: -> '#1c209e'
  @backgroundColor: -> new THREE.Color @backgroundColorStyle()
  @markupColorStyle: -> "#7d76fc"
  
  @steps: -> for step in [1..8]
    goalImageUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/displayresolution-#{step}.png"
    imageUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/displayresolution.png" if step is 1
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/displayresolution-palette.png"
  
  @markup: -> true
  
  @initialize()

  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    markup: ->
      textScale = 6
      textBase = Markup.textBase()
      textBase.size *= textScale
      textBase.lineHeight *= textScale
      textBase.style = Asset.markupColorStyle()
      textBase.outline = style: Asset.backgroundColorStyle(), width: textScale
      textBase.position = y: 20, origin: Markup.TextOriginPosition.BottomCenter
      
      asset = @getActiveAsset()
      bitmap = asset.bitmap()
      
      dragon32FroggerSource =
        position: x: 68, y: 170
        width: 6
        height: 6
      
      dragon32EndFroggerSource =
        position: x: 77, y: 171
        width: 6
        height: 5
      
      dragon32TurtleSource =
        position: x: 86, y: 171
        width: 7
        height: 5
      
      dragon32LogSource =
        position: x: 96, y: 171
        width: 24
        height: 5
      
      colecoVisionFroggerSource =
        position: x: 206, y: 168
        width: 12
        height: 12
      
      colecoVisionEndFroggerSource =
        position: x: 222, y: 168
        width: 16
        height: 12
      
      colecoVisionTurtleSource =
        position: x: 242, y: 166
        width: 16
        height: 15
      
      colecoVisionLogSource =
        position: x: 262, y: 168
        width: 48
        height: 11
        
      markup = [
        text: _.merge {}, textBase,
          position: x: 93
          value: """
            Dragon 32
          """
      ,
        text: _.merge {}, textBase,
          position: x: 257
          value: """
          ColecoVision
        """
      ,
        image:
          bitmap: bitmap
          position: x: 91, y: 130
          source: dragon32FroggerSource
      ,
        image:
          bitmap: bitmap
          position: x: 29, y: 70
          source: dragon32TurtleSource
      ,
        image:
          bitmap: bitmap
          position: x: 45, y: 82
          source: dragon32LogSource
        ,
          image:
            bitmap: bitmap
            position: x: 86, y: 82
            source: dragon32LogSource
        ,
          image:
            bitmap: bitmap
            position: x: 131, y: 82
            source: dragon32LogSource
        ,
          image:
            bitmap: bitmap
            position: x: 500 / 2, y: 243 / 2
            width: colecoVisionFroggerSource.width / 2
            height: colecoVisionFroggerSource.height / 2
            source: colecoVisionFroggerSource
      ]
      
      for froggerIndex in [0...3]
        markup.push
          image:
            bitmap: bitmap
            position: x: 33 + 12 * froggerIndex, y: 137
            source: dragon32FroggerSource
      
      for froggerIndex in [0...2]
        markup.push
          image:
            bitmap: bitmap
            position: x: 62 + 28 * froggerIndex, y: 59
            source: dragon32EndFroggerSource
      
      for turtleIndex in [0...2]
        markup.push
          image:
            bitmap: bitmap
            position: x: 124 + 9 * turtleIndex, y: 70
            source: dragon32TurtleSource
      
      for turtleIndex in [0...3]
        markup.push
          image:
            bitmap: bitmap
            position: x: 33 + 9 * turtleIndex, y: 88
            source: dragon32TurtleSource
            
      for turtleIndex in [0...3]
        markup.push
          image:
            bitmap: bitmap
            position: x: 121 + 9 * turtleIndex, y: 88
            source: dragon32TurtleSource
      
      for froggerIndex in [0...2]
        markup.push
          image:
            bitmap: bitmap
            position: x: (510 + 96 * froggerIndex) / 2, y: 102 / 2
            width: colecoVisionEndFroggerSource.width / 2
            height: colecoVisionEndFroggerSource.height / 2
            source: colecoVisionEndFroggerSource
         
      for turtleGroupIndex in [0...3]
        for turtleIndex in [0...2]
          markup.push
            image:
              bitmap: bitmap
              position: x: (416 + 64 * turtleGroupIndex + 24 * turtleIndex) / 2, y: 130 / 2
              width: colecoVisionTurtleSource.width / 2
              height: colecoVisionTurtleSource.height / 2
              source: colecoVisionTurtleSource
        
      for turtleIndex in [0...3]
        markup.push
          image:
            bitmap: bitmap
            position: x: (418 + 24 * turtleIndex) / 2, y: 178 / 2
            width: colecoVisionTurtleSource.width / 2
            height: colecoVisionTurtleSource.height / 2
            source: colecoVisionTurtleSource
      
      for turtleIndex in [0...2]
        markup.push
          image:
            bitmap: bitmap
            position: x: (514 + 24 * turtleIndex) / 2, y: 178 / 2
            width: colecoVisionTurtleSource.width / 2
            height: colecoVisionTurtleSource.height / 2
            source: colecoVisionTurtleSource
      
      for logIndex in [0...2]
        markup.push
          image:
            bitmap: bitmap
            position: x: (414 + 72 * logIndex) / 2, y: 164 / 2
            width: colecoVisionLogSource.width / 2
            height: colecoVisionLogSource.height / 2
            source: colecoVisionLogSource
            
      markup
    
  class @LimitedMemory extends @Instruction
    @id: -> "#{Asset.id()}.LimitedMemory"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      Older computers, like the Dragon 32 with the Motorola MC6847 video chip, had very limited memory.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      markupScale = 4
      textBase = Markup.textBase()
      textBase.size *= markupScale
      textBase.lineHeight *= markupScale
      textBase.style = Asset.markupColorStyle()
      textBase.outline = style: Asset.backgroundColorStyle(), width: markupScale
      textBase.position = y: 20, origin: Markup.TextOriginPosition.BottomCenter
      
      arrowBase =
        width: markupScale
        arrow:
          end: true
          width: markupScale
          length: markupScale / 2
        style: Asset.markupColorStyle()
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 40, y: 190
          ,
            bezierControlPoints: [
              x: 40, y: 180
            ,
              x: 50, y: 173
            ]
            x: 63, y: 173
          ]
        text: _.extend {}, textBase,
          position:
            x: 40, y: 195, origin: Markup.TextOriginPosition.TopCenter
          value: "draw here"
         
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 145, y: 190
          ,
            bezierControlPoints: [
              x: 145, y: 170
            ,
              x: 122, y: 133
            ]
            x: 102, y: 133
          ]
        text: _.extend {}, textBase,
          position:
            x: 145, y: 195, origin: Markup.TextOriginPosition.TopCenter
          value: "preview here"
          
      markup
  
  class @Tradeoff extends @Instruction
    @id: -> "#{Asset.id()}.Tradeoff"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      There was often a tradeoff between display resolution (how many pixels the screen displayed) and the number of colors you could use.
    """
    
    @initialize()
    
  class @FroggerDragon extends @Instruction
    @id: -> "#{Asset.id()}.FroggerDragon"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      The game Frogger opted for more colors (4) at a lower display resolution (128×96 pixels).
    """
    
    @initialize()
  
  class @BigPixels extends @Instruction
    @id: -> "#{Asset.id()}.BigPixels"
    @assetClass: -> Asset
    @stepNumber: -> 4
    
    @message: -> """
      This led to big pixels, a defining characteristic of early pixel art styles.
    """
    
    @initialize()
  
  class @ColecoVision extends @Instruction
    @id: -> "#{Asset.id()}.ColecoVision"
    @assetClass: -> Asset
    @stepNumber: -> 5
    
    @message: -> """
      Consoles, like the ColecoVision with the Texas Instruments TMS9918 video chip,
      started having dedicated video memory to come closer to the graphics of arcade machines.
    """
    
    @initialize()
    
  class @HigherResolution extends @Instruction
    @id: -> "#{Asset.id()}.HigherResolution"
    @assetClass: -> Asset
    @stepNumber: -> 6
    
    @message: -> """
      Consoles could produce higher resolution with more colors than competing home computers.
    """
    
    @initialize()
    
  class @FroggerColecoVision extends @Instruction
    @id: -> "#{Asset.id()}.FroggerColecoVision"
    @assetClass: -> Asset
    @stepNumber: -> 7
    
    @message: -> """
      Frogger on ColecoVision used 9 out of 15 available colors at a display resolution of 256×192 pixels.
    """
    
    @initialize()
  
  class @SmallerPixels extends @Instruction
    @id: -> "#{Asset.id()}.SmallerPixels"
    @assetClass: -> Asset
    @stepNumber: -> 8
    
    @message: -> """
      Higher resolution meant smaller displayed pixels, defining ever more modern styles of pixel art.
    """
    
    @initialize()
  
  class @Completed extends PAA.Tutorials.Drawing.Instructions.CompletedInstruction
    @id: -> "#{Asset.id()}.Completed"
    @assetClass: -> Asset
    
    @message: -> """
      Today, we are not limited by hardware anymore.
      The choice of pixel art size depends on the aesthetic we want to convey.
      Bigger pixels command more simplification, smaller pixels allow for more details and expressiveness.
    """
  
    @initialize()
    
    markup: ->
      textScale = 6
      textBase = Markup.textBase()
      textBase.size *= textScale
      textBase.lineHeight *= textScale
      textBase.style = Asset.markupColorStyle()
      textBase.outline = style: Asset.backgroundColorStyle(), width: textScale
      
      topTextBase = _.merge {}, textBase,
        position: y: 20, origin: Markup.TextOriginPosition.BottomCenter
        
      bottomTextBase = _.merge {}, textBase,
        position: y: 190, origin: Markup.TextOriginPosition.TopCenter
      
      [
        text: _.merge {}, topTextBase,
          position: x: 93
          value: """
            lower resolution (128×96)
            bigger pixels
            more simplification
          """
      ,
        text: _.merge {}, topTextBase,
          position: x: 257
          value: """
            higher resolution (256×192)
            smaller pixels
            more details
          """
      ,
        text: _.merge {}, bottomTextBase,
          position: x: 93
          value: """
            smaller sprites
            (5–6 px tall)
          """
      ,
        text: _.merge {}, bottomTextBase,
          position: x: 257
          value: """
            bigger sprites
            (11–15 px tall)
          """
      ,
        image:
          url: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/displayresolution-dragon32.png"
          position: x: 25, y: 45
      ,
        image:
          url: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/displayresolution-colecovision.png"
          position: x: 189, y: 45
          width: 136
          height: 104
      ]
