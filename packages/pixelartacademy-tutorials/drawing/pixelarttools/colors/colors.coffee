AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking
TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.PixelArtTools.Colors extends PAA.Tutorials.Drawing.PixelArtTools
  # colorHelpOpenedWhenIncorrect: boolean whether the color help was opened when the color was incorrect
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors'

  @fullName: -> "Pixel art tools: colors"

  @initialize()
  
  @pacManPaletteName: 'PAC-MAN'

  @assets: -> [
    @ColorSwatches
    @ColorPicking
    @QuickColorPicking
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Intro.Tutorial
    chapter.getContent PAA.LearnMode.Intro.Tutorial.Content.DrawingTutorials.Colors
  
  class @ColorHelpInstruction extends PAA.PixelPad.Systems.Instructions.Instruction
    @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors.ColorHelpInstruction"
    
    @message: -> """
      You have chosen an incorrect color. If you need help determining colors,
      press the help button on the palette to explore different assistance options.
    """
    
    @priority: -> 10
    
    @initialize()
    
    constructor: ->
      super arguments...
      
      @incorrectPixels = new ReactiveField false
      
      @_listenToColorChangesAutorun = Tracker.autorun =>
        if PAA.Tutorials.Drawing.PixelArtTools.Colors.state 'colorHelpOpenedWhenIncorrect'
          @_stopListening()
          
        else
          @_startListening()
      
    destroy: ->
      super arguments...
      
      @_listenToColorChangesAutorun.stop()

      @_stopListening()
      
    _startListening: ->
      @_listening = true
      
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, @onOperationExecuted
      
      # Complete this instruction when the color help is opened.
      @_colorHelpOpenedAutorun = Tracker.autorun =>
        return unless @incorrectPixels()
        
        return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
        return unless palette = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.Palette
        return unless palette.colorHelp.visible()
        
        PAA.Tutorials.Drawing.PixelArtTools.Colors.state 'colorHelpOpenedWhenIncorrect', true
    
    _stopListening: ->
      return unless @_listening
      
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandler @, @onOperationExecuted
      
      @_colorHelpOpenedAutorun.stop()
  
    activeConditions: ->
      # Show this until the color help was opened when the color was incorrect.
      return if PAA.Tutorials.Drawing.PixelArtTools.Colors.state 'colorHelpOpenedWhenIncorrect'
      
      # Wait until our constructor has created the incorrect pixels field.
      return unless @instructions.isRendered()
      
      @incorrectPixels()

    onOperationExecuted: (document, operation, changedFields) ->
      # Only react to change pixels operations.
      return unless operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels
      
      # Only show this when the color swatches are available.
      return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
      return unless editor.drawingActive()
      return unless asset = editor.activeAsset()
      return unless asset instanceof PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
      
      if availableKeys = asset.availableToolKeys?()
        return unless PAA.Practice.Software.Tools.ToolKeys.ColorSwatches in availableKeys
      
      # Go over each of the source pixels and set them in the destination area where the operation mask is set.
      pixelFormat = new LOI.Assets.Bitmap.PixelFormat LOI.Assets.Bitmap.Attribute.OperationMask.id, document.pixelFormat.attributeIds...
      changeArea = new LOI.Assets.Bitmap.Area operation.bounds.width, operation.bounds.height, pixelFormat, operation._pixelsData or operation.compressedPixelsData, not operation._pixelsData
      
      sourceAreaOperationMaskAttribute = changeArea.attributes[LOI.Assets.Bitmap.Attribute.OperationMask.id]
  
      for sourceY in [0...operation.bounds.height]
        absoluteY = operation.bounds.y + sourceY
  
        for sourceX in [0...operation.bounds.width]
          absoluteX = operation.bounds.x + sourceX
  
          # See if the pixel was changed at this location.
          continue if sourceAreaOperationMaskAttribute and not sourceAreaOperationMaskAttribute.pixelWasChanged sourceX, sourceY
          
          # See if the changed pixel created any incorrect colors.
          for stepArea in asset.stepAreas()
            activeStep = stepArea.activeStep()
            continue unless activeStep instanceof TutorialBitmap.PixelsStep

            # Note: we have to compare to false since the method can return
            # undefined if the actual and goal colors are not set for this pixel.
            if activeStep.hasCorrectPixelColor(absoluteX, absoluteY) is false
              @incorrectPixels true
              return
    
      @incorrectPixels false
      
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".color-help-button"
          delay: 1
          bounds:
            x: -50
            y: -35
            width: 100
            height: 55
          markings: [
            rectangle:
              strokeStyle: markupStyle
              x: 1
              y: 0
              width: 38
              height: 8
            line: _.extend {}, arrowBase,
              points: [
                x: -22, y: -9
              ,
                x: -5, y: 4, bezierControlPoints: [
                  x: -22, y: 3
                ,
                  x: -15, y: 4
                ]
              ]
            text: _.extend {}, textBase,
              position:
                x: -22, y: -11, origin: Markup.TextOriginPosition.BottomCenter
              value: "click\nhere"
          ]
      ]
