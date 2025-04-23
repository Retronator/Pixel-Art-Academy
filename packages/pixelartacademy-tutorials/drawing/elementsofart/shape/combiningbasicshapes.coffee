LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.CombiningBasicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @displayName: -> "Combining basic shapes"
  
  @description: -> """
    Many objects can be created from basic shapes.
  """
  
  @fixedDimensions: -> width: 274, height: 90
  
  @imageUrl: -> "/pixelartacademy/tutorials/drawing/elementsofart/shape/combiningbasicshapes.png"
  
  @markup: -> true
  
  @initialize()
  
  Asset = @
  
  class @Objects extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Objects"
    @assetClass: -> Asset
  
    @activeConditions: ->
      @getActiveAsset()

    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
      
    @priority: -> -1
   
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      activeStepIndex = asset.stepAreas()[0].activeStepIndex()

      markup = []
      
      textBase = Markup.textBase()
      textBase.size *= 2
      textBase.lineHeight *= 2
      
      textTop = 73
      
      if activeStepIndex > 5
        markup.push
          text: _.extend {}, textBase,
            value: "tree"
            position:
              x: 43, y: textTop, origin: Markup.TextOriginPosition.TopCenter
      
      if activeStepIndex > 7
        markup.push
          text: _.extend {}, textBase,
            value: "pine\ntree"
            position:
              x: 81.5, y: textTop, origin: Markup.TextOriginPosition.TopCenter
      
      if activeStepIndex > 9
        markup.push
          text: _.extend {}, textBase,
            value: "palm\ntree"
            position:
              x: 118, y: textTop, origin: Markup.TextOriginPosition.TopCenter
            
      if activeStepIndex > 11
        markup.push
          text: _.extend {}, textBase,
            value: "house"
            position:
              x: 155.5, y: textTop, origin: Markup.TextOriginPosition.TopCenter
      
      if activeStepIndex > 17
        markup.push
          text: _.extend {}, textBase,
            value: "temple"
            position:
              x: 205.5, y: textTop, origin: Markup.TextOriginPosition.TopCenter
      
      if asset.completed()
        markup.push
          text: _.extend {}, textBase,
            value: "lookout\ntower"
            position:
              x: 242.5, y: textTop, origin: Markup.TextOriginPosition.TopCenter
      
      markup
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the indicated lines to construct simple objects.
    """
    
    @initialize()
