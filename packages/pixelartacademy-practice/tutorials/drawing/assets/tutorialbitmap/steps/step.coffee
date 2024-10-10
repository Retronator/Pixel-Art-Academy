AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

_topLeftCorner = x: 0, y: 0
_bottomRightCorner = x: 0, y: 0

_darkRed = "rgb(178, 60, 60)"
_lightRed = "rgb(210, 112, 112)"

_darkRedSemiTransparent = "rgba(178, 60, 60, 0.5)"
_lightRedSemiTransparent = "rgba(210, 112, 112, 0.5)"
_darkRedTransparent = "rgba(178, 60, 60, 0)"
_lightRedTransparent = "rgba(210, 112, 112, 0)"

class TutorialBitmap.Step
  # Override to true (or provide through options) if the step area should
  # remember the completed state of this step instead of asking to reconfirm it.
  @preserveCompleted: -> false

  # Override to true (or provide through options) if the hint drawing should be called after the step is completed.
  @drawHintsAfterCompleted: -> false

  # Override to true (or provide through options) if the step can be completed even if extra pixels are present.
  @canCompleteWithExtraPixels: -> false
  
  @getEditor: -> PAA.PixelPad.Apps.Drawing.Editor.getEditor()
  
  constructor: (@tutorialBitmap, @stepArea, @options = {}) ->
    @stepArea.addStep @, @options.stepIndex
  
  # Override to specify when the step's conditions are satisfied.
  completed: ->
    # Don't allow to continue if drawing outside of bounds.
    return if @stepArea.hasExtraPixels() and @isActiveStepInArea() and not @canCompleteWithExtraPixels()
    
    true
  
  # Override if the step requires pixels for its completion (so other steps don't consider them to be invalid).
  hasPixel: (absoluteX, absoluteY) -> false
  
  solve: -> throw new AE.NotImplementedException "A step has to provide a method to solve itself to a completed state."
  
  # Override if the step needs to reset any internal state when the asset is reset.
  reset: ->

  preserveCompleted: -> if @options.preserveCompleted? then @options.preserveCompleted else @constructor.preserveCompleted()
  drawHintsAfterCompleted: -> if @options.drawHintsAfterCompleted? then @options.drawHintsAfterCompleted else @constructor.drawHintsAfterCompleted()
  canCompleteWithExtraPixels: -> if @options.canCompleteWithExtraPixels? then @options.canCompleteWithExtraPixels else @constructor.canCompleteWithExtraPixels()
  getEditor: -> @constructor.getEditor()
  
  getIndexInArea: ->
    @stepArea.steps().indexOf @
    
  isActiveStepInArea: ->
    @stepArea.activeStepIndex() is @getIndexInArea()
  
  activate: ->
    return unless @options.startPixels
    
    # Add start pixels.
    bitmap = @tutorialBitmap.bitmap()
    
    if @options.startPixels instanceof TutorialBitmap.Resource.Pixels
      layers = [
        @options.startPixels
      ]
      
    else
      layers = @options.startPixels
    
    action = new AM.Document.Versioning.Action @tutorialBitmap.id()
    
    for layer, layerIndex in layers
      # Add layer if necessary.
      unless bitmap.getLayer layerIndex
        addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer @tutorialBitmap.id(), bitmap
        AM.Document.Versioning.executePartialAction bitmap, addLayerAction
        action.append addLayerAction
      
      # Add the pixels.
      strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [layerIndex], layer.pixels()
      AM.Document.Versioning.executePartialAction bitmap, strokeAction
      action.append strokeAction
      
    # If this activation happened as part of a user action, append the new pixels to that action.
    appendToLastAction = bitmap.historyPosition > 0
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, action, new Date, appendToLastAction

    # If this was the initial step, make it appear as if the bitmap started with these pixels.
    AM.Document.Versioning.clearHistory bitmap unless appendToLastAction

  drawUnderlyingHints: (context, renderOptions = {}) -> # Override to draw hints under the bitmap.
  drawOverlaidHints: (context, renderOptions = {}) -> # Override to draw hints over the bitmap.
  
  _prepareColorHelp: (context, renderOptions) ->
    # Hints are ideally 5x smaller dots in the middle of a pixel.
    pixelSize = renderOptions.camera.effectiveScale()
    dotHintSizeWindow = Math.ceil pixelSize / 5
    dotHintOffsetWindow = Math.floor (pixelSize - dotHintSizeWindow) / 2
    
    # We need to store sizes relative to the pixel.
    @_dotHintSize = dotHintSizeWindow / pixelSize
    @_dotHintOffset = dotHintOffsetWindow / pixelSize
    
    @_pixelOutlineErrorOffset = 1.5 / pixelSize
    @_pixelOutlineErrorWidth = 4 / pixelSize
    
    @_ColorHelp = PAA.PixelPad.Apps.Drawing.Editor.ColorHelp
    
    @_hintStyle = @_ColorHelp.hintStyle()
    @_errorStyle = @_ColorHelp.errorStyle()
    @_displayAllColorErrors = @tutorialBitmap.hintsEngineComponents.overlaid.displayAllColorErrors()
    
    @_dotHintOutlineErrorSize = (dotHintSizeWindow + 4) / pixelSize
    @_dotHintOutlineErrorOffset = (dotHintOffsetWindow - 2) / pixelSize
    
    # If pixel is less than 2 big, we should lower the opacity of the hint to mimic less coverage.
    @_hintOpacity = if pixelSize < 2 then pixelSize / 5 else 1
    
    context.font = '0.5px Adventure Retronator'
    context.textAlign = 'left'
    context.textBaseline = 'top'
  
  _drawColorHelpForPixel: (context, x, y, assetColor, palette, error, renderOptions) ->
    absoluteX = x + @stepArea.bounds.x
    absoluteY = y + @stepArea.bounds.y
    
    _topLeftCorner.x = absoluteX
    _topLeftCorner.y = absoluteY
    renderOptions.camera.roundCanvasToWindowPixel _topLeftCorner, _topLeftCorner
      
    _bottomRightCorner.x = absoluteX + 1
    _bottomRightCorner.y = absoluteY + 1
    renderOptions.camera.roundCanvasToWindowPixel _bottomRightCorner, _bottomRightCorner
    
    color = LOI.Assets.ColorHelper.resolveAssetColor assetColor, palette if assetColor
    errorColor = if color?.r < 0.75 then _lightRed else _darkRed
    
    if error or @_displayAllColorErrors
      # Draw the error.
      if @_errorStyle is @_ColorHelp.ErrorStyle.PixelOutline
        # Draw a pixel outline.
        context.strokeStyle = errorColor
        context.lineWidth = @_pixelOutlineErrorWidth
        width = _bottomRightCorner.x - _topLeftCorner.x - @_pixelOutlineErrorOffset * 2
        height = _bottomRightCorner.y - _topLeftCorner.y - @_pixelOutlineErrorOffset * 2
        context.strokeRect _topLeftCorner.x + @_pixelOutlineErrorOffset, _topLeftCorner.y + @_pixelOutlineErrorOffset, width, height if width > 0 and height > 0
  
      else if @_errorStyle is @_ColorHelp.ErrorStyle.HintOutline
        context.fillStyle = errorColor

        switch @_hintStyle
          when @_ColorHelp.HintStyle.Dots
            # Draw a slightly bigger dot.
            context.fillRect _topLeftCorner.x + @_dotHintOutlineErrorOffset, _topLeftCorner.y + @_dotHintOutlineErrorOffset, @_dotHintOutlineErrorSize, @_dotHintOutlineErrorSize
            
          when @_ColorHelp.HintStyle.Symbols
            # Draw the symbol offset to create an outline.
            index = if assetColor then LOI.Assets.ColorHelper.getPaletteColorIndex assetColor, palette else 0
            symbol = PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.symbols[index]

            symbolSize = context.measureText symbol
            width = symbolSize.actualBoundingBoxRight - symbolSize.actualBoundingBoxLeft
            height = symbolSize.actualBoundingBoxDescent - symbolSize.actualBoundingBoxAscent
            
            for offset in [-0.08, 0.08]
              context.fillText symbol, absoluteX + 0.5 - width * 0.5 + offset, absoluteY + 0.5 - height * 0.5
              context.fillText symbol, absoluteX + 0.5 - width * 0.5, absoluteY + 0.5 - height * 0.5 + offset
              context.fillText symbol, absoluteX + 0.5 - width * 0.5 + offset, absoluteY + 0.5 - height * 0.5 + offset
              context.fillText symbol, absoluteX + 0.5 - width * 0.5 - offset, absoluteY + 0.5 - height * 0.5 + offset
      
      else if @_errorStyle is @_ColorHelp.ErrorStyle.HintGlow or @_displayAllColorErrors and not @_errorStyle
        # Draw a radial gradient from the center of the pixel.
        hintGlowErrorGradient = context.createRadialGradient absoluteX + 0.5, absoluteY + 0.5, 0, absoluteX + 0.5, absoluteY + 0.5, 0.7
        hintGlowErrorGradient.addColorStop 0, if color?.r < 0.75 then _lightRedSemiTransparent else _darkRedSemiTransparent
        hintGlowErrorGradient.addColorStop 1, if color?.r < 0.75 then _lightRedTransparent else _darkRedTransparent
        context.fillStyle = hintGlowErrorGradient
        context.fillRect absoluteX, absoluteY, 1, 1

    if color
      context.fillStyle = "rgba(#{color.r * 255}, #{color.g * 255}, #{color.b * 255}, #{@_hintOpacity})"

    if @_hintStyle is @_ColorHelp.HintStyle.Dots
      # Draw the dot hint.
      if color
        context.fillRect _topLeftCorner.x + @_dotHintOffset, _topLeftCorner.y + @_dotHintOffset, @_dotHintSize, @_dotHintSize
      
      else unless @_hintOpacity < 1
        context.clearRect _topLeftCorner.x + @_dotHintOffset, _topLeftCorner.y + @_dotHintOffset, @_dotHintSize, @_dotHintSize
        
    else
      # Draw the symbol hint.
      index = if assetColor then LOI.Assets.ColorHelper.getPaletteColorIndex assetColor, palette else 0
      symbol = PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.symbols[index]
      
      symbolSize = context.measureText symbol
      width = symbolSize.actualBoundingBoxRight - symbolSize.actualBoundingBoxLeft
      height = symbolSize.actualBoundingBoxDescent - symbolSize.actualBoundingBoxAscent
      
      if color
        # Write the symbol in the center of the pixel.
        context.fillText symbol, absoluteX + 0.5 - width * 0.5, absoluteY + 0.5 - height * 0.5
        
      else
        # Clear the symbol.
        context.clearRect absoluteX + 0.5 - width * 0.5, absoluteY + 0.5 - width * 0.5, width, width
