AB = Artificial.Babel
AM = Artificial.Mirage
AP = Artificial.Program
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model extends PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model'
  @register @id()
  
  constructor: ->
    super arguments...
    
    @rendererManager = new ReactiveField null
    @sceneManager = new ReactiveField null
    @cameraManager = new ReactiveField null
    
    @previewImageUrl = new ReactiveField null
    @previewMeshes = new ReactiveField null
  
  onCreated: ->
    super arguments...

    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    @viewportSize = new ComputedField =>
      if @currentDisplayed()
        scale = @currentScale()
  
        resizingScale = @resizingScale()
        scale = resizingScale if resizingScale?

      else
        return unless hiddenScale = @hiddenScale()
        scale = hiddenScale
      
      # We calculate the display size using the potentially resizing scale.
      return unless displaySize = @displaySize scale
      return unless displaySize.width and displaySize.imageHeight
      
      displayScale = @display.scale()
      
      width: displaySize.width * displayScale
      height: displaySize.imageHeight * displayScale
    ,
      EJSON.equals
    
    @displayOptions = new ComputedField =>
      @data().displayOptions or {}
    ,
      EJSON.equals
    
    @imageUrl = new ComputedField => @data().image?.url
    
    # Provide dummy image size to allow calculating the hidden size.
    @imageSize width: 1, height: 1

    # Request a preview. It is used by stored references and by displayed references until the live rendering starts.
    # We request this reactively so the preview updates if viewport size changes (e.g. due to display scale change).
    @_previewRequestAutorun = @autorun (computation) =>
      unless viewportSize = @viewportSize()
        @_releasePreviewRequest()
        return

      unless imageUrl = @imageUrl()
        @_releasePreviewRequest()
        return

      configuration =
        imageUrl: imageUrl
        width: Math.max 1, Math.round viewportSize.width
        height: Math.max 1, Math.round viewportSize.height
        displayOptions: EJSON.clone @displayOptions()

      # Prevent duplicate requests.
      requestKey = @constructor.PreviewRenderer.getConfigurationKey configuration
      return if @_previewRequestKey is requestKey
      
      # Release the previous preview without clearing the image URL so that we keep it until the new preview is ready.
      @_releasePreviewRequest()
      @_previewRequestKey = requestKey
      
      @constructor.PreviewRenderer.render configuration, (imageDataUrl, meshes) =>
        return if @isDestroyed()
        return if computation.stopped
        return unless @_previewRequestKey is requestKey

        @previewImageUrl imageDataUrl
        @previewMeshes meshes
      
  onRendered: ->
    super arguments...
    
    # Start live rendering if the reference is displayed.
    return unless @currentDisplayed()
    
    # If drawing is not active, delay initialization so it doesn't happen during clipboard transitions.
    # We also stagger it with randomness to distribute multiple references initializing at the same time.
    initializationDelay = if @desktop.drawingActive() then 0 else 1000 + Math.random() * 500
    
    @_liveRenderingDelayTimeout = Meteor.setTimeout =>
      return if @isDestroyed()

      @sceneManager new @constructor.SceneManager @
      @cameraManager new @constructor.CameraManager @
      @rendererManager new @constructor.RendererManager @

      @$('.viewport').append @rendererManager().renderer.domElement
      
      await @rendererManager().startRendering()
      return if @isDestroyed()

      @_previewRequestAutorun.stop()
      @previewImageUrl null
    ,
      initializationDelay
  
  onDestroyed: ->
    super arguments...
    
    @_previewRequestAutorun.stop()
    @_releasePreviewRequest()

    Meteor.clearTimeout @_liveRenderingDelayTimeout

    @rendererManager()?.destroy()
    @sceneManager()?.destroy()

  _releasePreviewRequest: ->
    return unless @_previewRequestKey

    @constructor.PreviewRenderer.release @_previewRequestKey
    @_previewRequestKey = null
    
  hasInput: ->
    @displayOptions().input
    
  horizontalInputAreaClass: ->
    return unless input = @displayOptions().input
    return unless input.rotate or input.meshVisibility or input.meshMorphing.horizontal
    'horizontal'
    
  verticalInputAreaClass: ->
    return unless input = @displayOptions().input
    return unless input.rotate or input.meshVisibility or input.meshMorphing.vertical
    'vertical'

  events: ->
    super(arguments...).concat
      'wheel .input-area': @onPointerWheelInputArea

  onPointerDown: (event) ->
    return unless event.which is 1

    # Handle input.
    if input = @displayOptions().input
      if $(event.target).closest('.input-area').length
        if input.rotate
          @cameraManager().startRotateCamera event
          return
          
        else if input.meshVisibility
          @sceneManager().startAdjustMeshVisibility event
          return
          
        else if input.meshMorphing
          @sceneManager().startAdjustMeshMorphing event, input.meshMorphing
          return
    
    super arguments...
    
  onPointerWheelInputArea: (event) ->
    if @data().displayOptions?.input.zoom
      @cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY
