AM = Artificial.Mirage
AS = Artificial.Spectrum

class AS.Pages.PixelArt.Upscaling extends AM.Component
  @register 'Artificial.Spectrum.Pages.PixelArt.Upscaling'

  @sourcePreviewScaleMultiplier = 16
  @sourcePreviewMaximumViewportRatio = 0.48

  @Algorithms:
    Hqx: 'Hqx'

  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @sourceWidth = new ReactiveField 16
    @sourceHeight = new ReactiveField 16
    @algorithm = new ReactiveField @constructor.Algorithms.Hqx
    @upscaleFactor = new ReactiveField 4
    @sourceCanvas = new ReactiveField @_createSourceCanvas @sourceWidth(), @sourceHeight()
    @strokePixelValue = null

    # Always keep the HQX output ready so UI redraws stay simple.
    @upscaledCanvas = new ComputedField =>
      return unless sourceCanvas = @sourceCanvas()

      switch @algorithm()
        when @constructor.Algorithms.Hqx
          AS.Hqx.scale sourceCanvas, @upscaleFactor(), AS.Hqx.Modes.Default, false, true

  onRendered: ->
    super arguments...
  
    @sourcePreviewCanvas = @$('.source.preview-canvas')[0]
    @resultPreviewCanvas = @$('.result.preview-canvas')[0]
    
    @_sourcePreviewMagnification = new ComputedField =>
      return 1 unless sourceCanvas = @sourceCanvas()
      
      # Keep the editing surface much larger than the rendered result while still fitting roughly half the viewport.
      preferredMagnification = @constructor.sourcePreviewScaleMultiplier
      maximumCanvasWidth = Math.floor window.innerWidth * @constructor.sourcePreviewMaximumViewportRatio
      maximumMagnification = Math.floor maximumCanvasWidth / sourceCanvas.width
      
      Math.max 1, Math.min preferredMagnification, maximumMagnification
    
    @autorun (computation) =>
      return unless sourceCanvas = @sourceCanvas()
      @_drawScaledCanvas @sourcePreviewCanvas, sourceCanvas, @_sourcePreviewMagnification(), true

    @autorun (computation) =>
      return unless upscaledCanvas = @upscaledCanvas()
      @_drawScaledCanvas @resultPreviewCanvas, upscaledCanvas, 1
    
    # Stop drag painting even if the pointer is released outside the canvas.
    $(window).on 'mouseup.artificial-spectrum-pages-pixelart-upscaling', => @strokePixelValue = null

  onDestroyed: ->
    super arguments...
    
    $(window).off '.artificial-spectrum-pages-pixelart-upscaling'

  _createSourceCanvas: (sourceWidth, sourceHeight, sourceCanvas) ->
    targetCanvas = new AM.ReadableCanvas sourceWidth, sourceHeight
    targetImageData = targetCanvas.getFullImageData()

    # Start from a fully white image so manual editing begins in the requested state.
    for pixelOffset in [0...targetImageData.data.length] by 4
      targetImageData.data[pixelOffset + offset] = 255 for offset in [0..3]

    if sourceCanvas
      sourceImageData = sourceCanvas.getFullImageData()

      # Preserve the overlapping area when the user changes the source dimensions.
      for x in [0...Math.min sourceWidth, sourceCanvas.width]
        for y in [0...Math.min sourceHeight, sourceCanvas.height]
          sourcePixelOffset = (x + y * sourceCanvas.width) * 4
          targetPixelOffset = (x + y * sourceWidth) * 4

          targetImageData.data[targetPixelOffset + offset] = sourceImageData.data[sourcePixelOffset + offset] for offset in [0..3]

    targetCanvas.putFullImageData targetImageData
    targetCanvas

  setSourceSize: (width, height) ->
    width = Math.max 1, Math.round width
    height = Math.max 1, Math.round height

    return if width is @sourceWidth() and height is @sourceHeight()

    @sourceWidth width
    @sourceHeight height
    @sourceCanvas @_createSourceCanvas width, height, @sourceCanvas()

  _drawScaledCanvas: (targetCanvas, sourceCanvas, magnification, showPixelGrid = false) ->
    targetCanvas.width = sourceCanvas.width * magnification
    targetCanvas.height = sourceCanvas.height * magnification

    context = targetCanvas.getContext '2d'
    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, targetCanvas.width, targetCanvas.height
    context.imageSmoothingEnabled = false
    context.drawImage sourceCanvas, 0, 0, targetCanvas.width, targetCanvas.height
    @_drawPixelGrid context, targetCanvas, sourceCanvas, magnification if showPixelGrid

  _drawPixelGrid: (context, targetCanvas, sourceCanvas, magnification) ->
    # Use the same subtle grid approach as the sprite editor: only show it when the pixels are large enough.
    gridOpacity = (magnification - 2) / 100
    gridOpacity = _.clamp gridOpacity, 0, 0.3

    return unless gridOpacity > 0

    context.save()
    context.strokeStyle = "rgba(25,25,25,#{gridOpacity * 2})"
    context.lineWidth = 1
    context.beginPath()

    for y in [0..sourceCanvas.height]
      lineY = y * magnification - 0.5
      context.moveTo 0, lineY
      context.lineTo targetCanvas.width, lineY

    for x in [0..sourceCanvas.width]
      lineX = x * magnification - 0.5
      context.moveTo lineX, 0
      context.lineTo lineX, targetCanvas.height

    context.stroke()
    context.restore()

  events: ->
    super(arguments...).concat
      'mousedown .source': @onMouseDownSource
      'mousemove .source': @onMouseMoveSource
      'mouseleave .source': @onMouseLeaveSource
      'change .source-file-input': @onChangeSourceFileInput

  onMouseDownSource: (event) ->
    return unless event.which is 1

    pixel = @_getSourcePixelFromEvent event
    return unless pixel

    event.preventDefault()

    # Keep the whole stroke either turning pixels on or off based on the first pixel.
    @strokePixelValue = if @_isPixelBlack(pixel.pixelOffset) then 255 else 0
    @_paintSourcePixel pixel.pixelOffset, @strokePixelValue

  onMouseMoveSource: (event) ->
    return unless @strokePixelValue? and event.buttons & 1

    pixel = @_getSourcePixelFromEvent event
    return unless pixel

    @_paintSourcePixel pixel.pixelOffset, @strokePixelValue

  onMouseLeaveSource: (event) ->
    @strokePixelValue = null unless event.buttons & 1

  _getSourcePixelFromEvent: (event) ->
    return unless sourceCanvas = @sourceCanvas()

    bounds = event.currentTarget.getBoundingClientRect()
    sourceX = Math.floor (event.clientX - bounds.left) / bounds.width * sourceCanvas.width
    sourceY = Math.floor (event.clientY - bounds.top) / bounds.height * sourceCanvas.height

    return unless 0 <= sourceX < sourceCanvas.width
    return unless 0 <= sourceY < sourceCanvas.height

    pixelOffset: (sourceX + sourceY * sourceCanvas.width) * 4

  _isPixelBlack: (pixelOffset) ->
    return unless sourceCanvas = @sourceCanvas()

    sourceImageData = sourceCanvas.getFullImageData()
    isBlack = true

    for offset in [0..2]
      isBlack &&= sourceImageData.data[pixelOffset + offset] is 0

    isBlack

  _paintSourcePixel: (pixelOffset, value) ->
    return unless sourceCanvas = @sourceCanvas()

    updatedSourceCanvas = new AM.ReadableCanvas sourceCanvas
    updatedImageData = updatedSourceCanvas.getFullImageData()
    pixelAlreadyPainted = true

    for offset in [0..2]
      pixelAlreadyPainted &&= updatedImageData.data[pixelOffset + offset] is value

    return if pixelAlreadyPainted

    updatedImageData.data[pixelOffset + offset] = value for offset in [0..2]
    updatedImageData.data[pixelOffset + 3] = 255
    updatedSourceCanvas.putFullImageData updatedImageData
    @sourceCanvas updatedSourceCanvas

  onChangeSourceFileInput: (event) ->
    file = event.currentTarget.files?[0]
    return unless file

    imageUrl = URL.createObjectURL file
    image = new Image

    image.onload = =>
      @sourceWidth image.width
      @sourceHeight image.height
      @sourceCanvas new AM.ReadableCanvas image

      URL.revokeObjectURL imageUrl
      event.currentTarget.value = null

    image.onerror = =>
      URL.revokeObjectURL imageUrl

    image.src = imageUrl

  class @SourceWidth extends @DataInputComponent
    @register 'Artificial.Spectrum.Pages.PixelArt.Upscaling.SourceWidth'

    constructor: ->
      super arguments...

      @propertyName = 'sourceWidth'
      @type = AM.DataInputComponent.Types.Number
      @realtime = false
      @customAttributes =
        min: 1
        step: 1

    save: (value) ->
      return unless _.isFinite value
      @dataProviderComponent.setSourceSize value, @dataProviderComponent.sourceHeight()

  class @SourceHeight extends @DataInputComponent
    @register 'Artificial.Spectrum.Pages.PixelArt.Upscaling.SourceHeight'

    constructor: ->
      super arguments...

      @propertyName = 'sourceHeight'
      @type = AM.DataInputComponent.Types.Number
      @realtime = false
      @customAttributes =
        min: 1
        step: 1

    save: (value) ->
      return unless _.isFinite value
      @dataProviderComponent.setSourceSize @dataProviderComponent.sourceWidth(), value

  class @Algorithm extends @DataInputComponent
    @register 'Artificial.Spectrum.Pages.PixelArt.Upscaling.Algorithm'

    constructor: ->
      super arguments...

      @propertyName = 'algorithm'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      [
        value: AS.Pages.PixelArt.Upscaling.Algorithms.Hqx
        name: 'hqx'
      ]

  class @UpscaleFactor extends @DataInputComponent
    @register 'Artificial.Spectrum.Pages.PixelArt.Upscaling.UpscaleFactor'

    constructor: ->
      super arguments...

      @propertyName = 'upscaleFactor'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 2
        max: 4
        step: 1

    save: (value) ->
      return unless _.isFinite value
      super value
