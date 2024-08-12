AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar extends LOI.Adventure.Thing.Avatar
  @hqxScale = 4
  
  constructor: (part) ->
    super part.constructor

    @part = part
    
    @shape = new ReactiveField null
    
  destroy: ->
    super arguments...
    
    @texture?.stop()
    @pixelArtEvaluation?.stop()

    @_texture?.dispose()
    @_renderObject?.destroy()
    @_physicsObject?.destroy()
  
  # Note: We initialize the avatar separately since the construction happens
  # already in the thing's constructor and we don't have any extra fields available.
  initialize: ->
    @_renderObject = new @constructor.RenderObject @part
    @_physicsObject = new @constructor.PhysicsObject @part
    
    # Create the upscaled texture.
    @pixelImage = new LOI.Assets.Engine.PixelImage.Bitmap asset: => @part.bitmap()
    
    @texture = new AE.LiveComputedField =>
      return unless originalCanvas = @pixelImage.getCanvas()
      
      expandedCanvas = new AM.Canvas originalCanvas.width + 2, originalCanvas.height + 2
      expandedCanvas.context.drawImage originalCanvas, 1, 1
      scaledCanvas = AS.Hqx.scale expandedCanvas, @constructor.hqxScale, AS.Hqx.Modes.NoBlending, false, true
      
      @_texture?.dispose()
      @_texture = new THREE.CanvasTexture scaledCanvas
      @_texture.minFilter = THREE.NearestFilter
      @_texture.magFilter = THREE.NearestFilter
      @_texture
    
    @initializeShape()
    
  # Note: We separate shape initialization so we can call it when we only want to perform the shape analysis.
  initializeShape: ->
    # Analyze pixel art.
    @pixelArtEvaluationInstance = new ComputedField =>
      return unless bitmap = @part.bitmap()
      @_pixelArtEvaluation?.destroy()
      @_pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation bitmap
    
    @pixelArtEvaluation = new ComputedField =>
      return unless pixelArtEvaluationInstance = @pixelArtEvaluationInstance()
      pixelArtEvaluationInstance.depend()
      pixelArtEvaluationInstance
    
    @part.autorun =>
      shape = @_createShape()
      @shape shape
      
      if shape
        Tracker.afterFlush => @reset()
  
  _createShape: ->
    # Analyze the bitmap to determine the shape of the part.
    return unless pixelArtEvaluation = @pixelArtEvaluation()
    shapeProperties = @part.shapeProperties()
    
    for shapeClass in @part.constructor.avatarShapes()
      return shape if shape = shapeClass.detectShape pixelArtEvaluation, shapeProperties
      
    # No requested shape was able to be detected. Default to a box so that it has a physics presence and can be moved.
    return shape if shape = Pinball.Part.Avatar.Box.detectShape pixelArtEvaluation, shapeProperties
    
    # Looks like the image is empty and no shape could have been created.
    null
    
  getRenderObject: ->
    return unless @_renderObject?.ready()
    @_renderObject
  
  getPhysicsObject: ->
    return unless @_physicsObject?.ready()
    @_physicsObject
  
  reset: ->
    return unless @_physicsObject?.ready()
    @_physicsObject.reset()
    @_renderObject.updateFromPhysicsObject @_physicsObject
    
  getBoundingRectangle: ->
    return unless shape = @shape()
    # We want to rely only on the project position (to avoid recomputation during dragging).
    return unless position = @part.data()?.position
    
    shape.getBoundingRectangle().getOffsetBoundingRectangle position.x, position.z
  
  getHoleBoundaries: ->
    return unless holeBoundaries = @shape()?.getHoleBoundaries()
    return unless position = @part.data()?.position
    # We want to rely only on the project rotation (to avoid recomputation during rotating).
    rotationAngle = @part.data()?.rotationAngle or 0
    zero = new THREE.Vector2
    
    for holeBoundary in holeBoundaries
      for vertex in holeBoundary.vertices
        vertex.rotateAround zero, -rotationAngle
        vertex.x += position.x
        vertex.y += position.z
        
    holeBoundaries
