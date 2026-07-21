AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
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
    @pixelArtEvaluationInstance?.stop()
    @pixelArtEvaluation?.stop()
    @splines?.stop()

    @_texture?.dispose()
    @_renderObject?.destroy()
    @_physicsObject?.destroy()
    @_pixelArtEvaluation?.destroy()
  
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
      scaledCanvas = AS.PixelArt.Upscaling.Hqx.scale expandedCanvas, @constructor.hqxScale, AS.PixelArt.Upscaling.Hqx.Modes.NoBlending, false, true
      
      @_texture?.dispose()
      @_texture = new THREE.CanvasTexture scaledCanvas
      @_texture.minFilter = THREE.NearestFilter
      @_texture.magFilter = THREE.NearestFilter
      @_texture
    
    @initializeShape()
    
  # Note: We separate shape initialization so we can call it when we only want to perform the shape analysis.
  initializeShape: ->
    # Analyze pixel art.
    @pixelArtEvaluationInstance = new AE.LiveComputedField =>
      return unless bitmap = @part.bitmap()
      @_pixelArtEvaluation?.destroy()
      @_pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation bitmap
    
    @pixelArtEvaluation = new AE.LiveComputedField =>
      return unless pixelArtEvaluationInstance = @pixelArtEvaluationInstance()
      pixelArtEvaluationInstance.depend()
      pixelArtEvaluationInstance
    
    splinesRequired = false

    for shapeClass in @part.constructor.avatarShapes()
      if shapeClass.requiresSplines()
        splinesRequired = true
        break

    if splinesRequired
      @pixelImage = new LOI.Assets.Engine.PixelImage.Bitmap
        asset: => @part.bitmap()

      @splines = new AE.LiveComputedField =>
        return [] unless imageData = @pixelImage.getImageData()

        # Add transparent padding and color pixels black so we only depixelize silhouettes.
        silhouetteImageDataWidth = imageData.width + 2
        silhouetteImageDataHeight = imageData.height + 2
        silhouetteImageData = new ImageData new Uint8ClampedArray(silhouetteImageDataWidth * silhouetteImageDataHeight * 4), silhouetteImageDataWidth, silhouetteImageDataHeight

        for sourceY in [0...imageData.height]
          for sourceX in [0...imageData.width]
            sourceDataIndex = (sourceX + sourceY * imageData.width) * 4
            continue unless alpha = imageData.data[sourceDataIndex + 3]

            targetDataIndex = (sourceX + 1 + (sourceY + 1) * silhouetteImageDataWidth) * 4
            silhouetteImageData.data[targetDataIndex + 3] = alpha

        componentImageDatas = AS.ImageDataHelpers.splitComponents silhouetteImageData
        componentSplines = []

        for componentImageData in componentImageDatas
          rawSplines = AS.PixelArt.Upscaling.Depixelizer.getBSplines componentImageData
          
          # Subtract the transparent padding.
          for rawSpline in rawSplines
            for point in rawSpline.points
              point.x--
              point.y--

          componentSplines.push AP.BSpline.joinSplines rawSplines
          
        componentSplines

    @part.autorun =>
      shape = @_createShape()
      @shape shape
      
      if shape
        Tracker.afterFlush => @reset()
  
  _createShape: ->
    # Analyze the bitmap to determine the shape of the part.
    return unless pixelArtEvaluation = @pixelArtEvaluation()
    shapeProperties = @part.shapeProperties()
    splines = @splines?()
    
    for shapeClass in @part.constructor.avatarShapes()
      return shape if shape = shapeClass.detectShape pixelArtEvaluation, shapeProperties, splines
      
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
