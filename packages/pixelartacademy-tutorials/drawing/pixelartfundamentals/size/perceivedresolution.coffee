LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size.PerceivedResolution extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Size.PerceivedResolution"
  
  @displayName: -> "Perceived resolution"
  
  @description: -> """
    Pixel art size depends on more than just the canvas size.
  """
  
  @fixedDimensions: -> width: 232, height: 163
  @backgroundColorStyle: -> '#1c209e'
  @backgroundColor: -> new THREE.Color @backgroundColorStyle()
  @markupColorStyle: -> "#407bec"
  
  @steps: -> for step in [1..26]
    goalImageUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/perceivedresolution-#{step}.png"
    imageUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/perceivedresolution-#{step}-start.png" if step is 3
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/perceivedresolution-palette.png"
  
  @markup: -> true
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    stepArea = @stepAreas()[0]
    steps = stepArea._steps

    for step in steps
      # Pixels from previous steps get repainted, so they have to be preserved.
      step.options.preserveCompleted = true
    
      # Allow extra pixels since markup images cover the canvas and you can accidentally paint in that area.
      step.options.canCompleteWithExtraPixels = true
    
    new @constructor.FinalStep @, stepArea,
      goalPixels: _.last(steps).options.goalPixels

  _initialize: ->
    super arguments...
    
    enabledColorsByStep = [
      [{ramp: 0, shade: 0}]
      []
      []
      []
      [{ramp: 1, shade: 0}, {ramp: 2, shade: 0}]
      [{ramp: 0, shade: 1}]
      [{ramp: 0, shade: 2}]
      [{ramp: 0, shade: 3}]
      [{ramp: 0, shade: 4}]
      [{ramp: 1, shade: 1}]
      [{ramp: 1, shade: 2}]
      [{ramp: 1, shade: 3}]
      [{ramp: 1, shade: 4}]
      [{ramp: 1, shade: 5}]
      [{ramp: 1, shade: 6}]
      [{ramp: 1, shade: 7}]
      [{ramp: 3, shade: 0}]
      [{ramp: 3, shade: 1}]
      [{ramp: 3, shade: 2}]
      [{ramp: 3, shade: 3}]
      [{ramp: 2, shade: 1}]
      [{ramp: 2, shade: 2}]
      [{ramp: 2, shade: 3}]
      [{ramp: 4, shade: 0}]
      [{ramp: 4, shade: 1}]
      [{ramp: 4, shade: 2}]
    ]
    
    # Enable ramp shades as the steps progress.
    @_setPaletteColorsAutorun = Tracker.autorun (computation) =>
      return unless @initialized() and @resourcesReady()
      return unless bitmapId = @bitmapId()
      return unless bitmapData = LOI.Assets.Bitmap.documents.findOne bitmapId, fields: customPalette: 1
      return unless stepAreas = @stepAreas()
      return unless stepAreas.length
      activeStepIndex = stepAreas[0].activeStepIndex()
      
      Tracker.nonreactive =>
        customPalette =
          allRamps: bitmapData.customPalette.allRamps or _.clone bitmapData.customPalette.ramps
          ramps: []
        
        for enabledColors in enabledColorsByStep[..activeStepIndex]
          for color in enabledColors
            customPalette.ramps[color.ramp] ?= shades: []
            customPalette.ramps[color.ramp].shades[color.shade] = customPalette.allRamps[color.ramp].shades[color.shade]
        
        return if EJSON.equals customPalette, bitmapData.customPalette

        # Wait for stroke to be saved fully.
        Tracker.autorun (computation) =>
          bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
          return if bitmap.partialAction
          computation.stop()
          
          # Update persistent document.
          LOI.Assets.Bitmap.documents.update bitmapId, $set: {customPalette, lastEditTime: new Date()}
          
          # Trigger reactivity.
          LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapId

  destroy: ->
    super arguments...
    
    @_setPaletteColorsAutorun?.stop()
    
  Asset = @
  
  class @FinalStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PixelsStep
    hasPixel: (x, y) ->
      return true if super arguments...

      # Allow extra pixels since markup images cover the canvas and you can accidentally paint in that area.
      return true if 9 <= x < 9 + 32 and 52 <= y < 52 + 18
      return true if 61 <= x < 61 + 160 and 11 <= y < 11 + 90
      false
  
  class @Context extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Context"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      When creating an artwork, it can be useful to account for the context in which it will be displayed.

      Draw a mobile device on the left and a computer display on the right.
    """
    
    @initialize()
    
  class @SocialMedia extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.SocialMedia"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      A big artwork displayed in a social media feed can have the pixels so small that it loses the feeling of being pixel art.
    """
    
    @initialize()
    
    markup: -> [
      image:
        url: '/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/perceivedresolution-hapunui.png'
        position: x: 9, y: 52
        width: 32
        height: 18
    ]
    
  class @Wallpaper extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Wallpaper"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      A small artwork displayed as a desktop wallpaper can have the pixels so big that it's hard to read the scene.
    """
    
    @initialize()
    
    markup: -> [
      image:
        url: '/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/perceivedresolution-hapunui.png'
        position: x: 9, y: 52
        width: 32
        height: 18
    ,
      image:
        url: '/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/perceivedresolution-minilandscape.png'
        position: x: 61, y: 11
        width: 160
        height: 90
    ]
    
  class @InstructionsWithBitmaps extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    markup: ->
      return [] unless asset = @getActiveAsset()
      return [] unless bitmap = asset.bitmap()
        
      landscapeSource =
        position: x: 84, y: 122
        width: 64
        height: 36
      
      [
        image:
          bitmap: bitmap
          position: x: 9, y: 52
          width: 32
          height: 18
          source: landscapeSource
      ,
        image:
          bitmap: bitmap
          position: x: 61, y: 11
          width: 160
          height: 90
          source: landscapeSource
      ]
  
  class @PerceivedPixelSize extends @InstructionsWithBitmaps
    @id: -> "#{Asset.id()}.PerceivedPixelSize"
    @assetClass: -> Asset
    @stepNumbers: -> [4..28]
    
    @message: -> """
      This means that the same image can be perceived as more detailed (higher resolution) when displayed small,
      and appear more blocky (lower resolution) when displayed large.
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
            x: 45, y: 150
          ,
            bezierControlPoints: [
              x: 45, y: 130
            ,
              x: 25, y: 120
            ]
            x: 25, y: 100
          ]
        text: _.extend {}, textBase,
          position:
            x: 47, y: 152, origin: Markup.TextOriginPosition.TopCenter
          value: "preview here"
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 45, y: 150
          ,
            bezierControlPoints: [
              x: 45, y: 130
            ,
              x: 55, y: 133
            ]
            x: 60, y: 123
          ]
          
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 185, y: 150
          ,
            bezierControlPoints: [
              x: 185, y: 140
            ,
              x: 170, y: 140
            ]
            x: 160, y: 140
          ]
        text: _.extend {}, textBase,
          position:
            x: 185, y: 152, origin: Markup.TextOriginPosition.TopCenter
          value: "draw here"
          
      markup
  
  class @Completed extends @InstructionsWithBitmaps
    @id: -> "#{Asset.id()}.Completed"
    @assetClass: -> Asset
    
    @message: -> """
      Note that we often want to post the same artwork in multiple places and can't control how big the pixels will appear.
      People will see it on different devices and can zoom in to see it larger.
      In that case, other factors, like which details we have space to represent, can become more important for choosing the canvas size.
    """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @initialize()
