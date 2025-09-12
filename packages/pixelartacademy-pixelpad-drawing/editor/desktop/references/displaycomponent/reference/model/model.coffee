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
  
  onCreated: ->
    super arguments...
    
    @viewportSize = new ComputedField =>
      scale = @currentScale()
      resizingScale = @resizingScale()
      scale = resizingScale if resizingScale?
      
      # We calculate the display size using the potentially resizing scale.
      return unless displaySize = @displaySize scale
      return unless displaySize.width and displaySize.height
      
      displayScale = @display.scale()
      
      width: displaySize.width * displayScale
      height: displaySize.height * displayScale
    
    # Initialize components.
    @sceneManager new @constructor.SceneManager @
    @cameraManager new @constructor.CameraManager @
    @rendererManager new @constructor.RendererManager @
    
    # Update image size from the reference.
    @autorun =>
      @imageSize @data().displayOptions?.imageSize or width: 1000, height: 1000
      
  onRendered: ->
    super arguments...
    
    @$('.viewport').append @rendererManager().renderer.domElement
    
    # Start rendering after the canvas has been flushed to the DOM.
    Tracker.afterFlush =>
      # Make sure the component didn't get destroyed in the mean time.
      return if @isDestroyed()

      @rendererManager().startRendering()
  
  onDestroyed: ->
    super arguments...
    
    @rendererManager().destroy()
    @sceneManager().destroy()
    
  hasInput: ->
    @data().displayOptions?.input

  events: ->
    super(arguments...).concat
      'wheel .input-area': @onPointerWheelInputArea

  onPointerDown: (event) ->
    return unless event.which is 1

    # Handle input.
    if @data().displayOptions?.input.rotate
      if $(event.target).closest('.input-area').length
        @cameraManager().startRotateCamera event
        return
    
    super arguments...
    
  onPointerWheelInputArea: (event) ->
    if @data().displayOptions?.input.zoom
      @cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY
