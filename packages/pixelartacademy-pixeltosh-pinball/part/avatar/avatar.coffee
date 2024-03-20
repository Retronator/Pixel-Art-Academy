AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar extends LOI.Adventure.Thing.Avatar
  constructor: (part) ->
    super part.constructor

    @part = part
    
    @shape = new ReactiveField null
    
    @_renderObject = new ReactiveField null
    @_physicsObject = new ReactiveField null
    
  destroy: ->
    super arguments...

    @_renderObject()?.destroy()
    @_physicsObject()?.destroy()
  
  # Note: We initialize the avatar separately since the construction happens
  # already in the thing's constructor and we don't have any extra fields available.
  initialize: ->
    @part.autorun =>
      return unless properties = @part.avatarProperties()
      
      # Analyze the bitmap to determine the shape of the part.
      return unless bitmap = @part.bitmap()
      pixelArtEvaluation = new PAE bitmap
  
      Tracker.nonreactive =>
        @_renderObject()?.destroy()
        @_physicsObject()?.destroy()
        @_renderObject null
        @_physicsObject null
        
        for shapeClass in @part.constructor.avatarShapes()
          continue unless shape = shapeClass.detectShape pixelArtEvaluation, properties
          @shape shape
          
          @_createObjectsWithShape properties, shape, bitmap
          break
          
  _createObjectsWithShape: (properties, shape, bitmap) ->
    @_renderObject new @constructor.RenderObject @, properties, shape, bitmap
    @_physicsObject new @constructor.PhysicsObject @, properties, shape
    
    @reset()
  
  getRenderObject: -> @_renderObject()
  getPhysicsObject: -> @_physicsObject()
  
  reset: ->
    physicsObject = @_physicsObject()
    physicsObject.reset()
    @_renderObject().updateFromPhysicsObject physicsObject
    
  getBoundingRectangle: ->
    return unless shape = @shape()
    return unless properties = @part.avatarProperties()
    
    shape.getBoundingRectangle().getOffsetBoundingRectangle properties.position.x, properties.position.y
  
  getHoleBoundaries: ->
    return unless holeBoundaries = @shape()?.getHoleBoundaries()
    return unless properties = @part.avatarProperties()
    
    for holeBoundary in holeBoundaries
      for vertex in holeBoundary.vertices
        vertex.add properties.position
        
    holeBoundaries
