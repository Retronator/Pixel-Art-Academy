AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.Step
  # Override to true (or provide through options) if the step area should
  # remember the completed state of this step instead of asking to reconfirm it.
  @preserveCompleted: -> false

  # Override to false (or provide through options) if the hint drawing should not be called after the step is completed.
  @drawHintsAfterCompleted: -> true

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
  hasPixel: -> false
  
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
  
  _preparePixelHintSize: (renderOptions) ->
    # Hints are ideally 5x smaller dots in the middle of a pixel.
    pixelSize = renderOptions.camera.effectiveScale()
    hintSize = Math.ceil pixelSize / 5
    offset = Math.floor (pixelSize - hintSize) / 2
    
    # We need to store sizes relative to the pixel.
    @_pixelHintSize = hintSize / pixelSize
    @_pixelHintOffset = offset / pixelSize
    
    # If pixel is less than 2 big, we should lower the opacity of the hint to mimic less coverage.
    @_pixelHintOpacity = if pixelSize < 2 then pixelSize / 5 else 1
  
  _drawPixelHint: (context, x, y, color) ->
    absoluteX = x + @stepArea.bounds.x + @_pixelHintOffset
    absoluteY = y + @stepArea.bounds.y + @_pixelHintOffset
    
    if color
      context.fillStyle = "rgba(#{color.r * 255}, #{color.g * 255}, #{color.b * 255}, #{@_pixelHintOpacity})"
      context.fillRect absoluteX, absoluteY, @_pixelHintSize, @_pixelHintSize
    
    else unless @_pixelHintOpacity < 1
      context.clearRect absoluteX, absoluteY, @_pixelHintSize, @_pixelHintSize
