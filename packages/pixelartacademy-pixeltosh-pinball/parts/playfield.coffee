AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Playfield extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Playfield'
  @fullName: -> "playfield"
  @description: ->
    "
      The surface of the pinball table on which different parts are placed.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/playfield.png'
  
  @avatarClass: -> @Avatar
  
  @initialize()
  
  createAvatarProperties: ->
    mass: 0
    height: 0.05
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    
  class @Avatar extends Pinball.Part.Avatar
    initialize: ->
      @part.autorun =>
        return unless properties = @part.avatarProperties()
        return unless bitmap = @part.bitmap()
        pixelArtEvaluation = new PAE bitmap
        
        # See which parts require holes in the playfield.
        holeBoundaries = []
        boundingRectangles = []
        
        for part in @part.pinball.sceneManager().parts()
          holeBoundaries.push partHoleBoundaries... if partHoleBoundaries = part.playfieldHoleBoundaries()
          boundingRectangles.push boundingRectangle if boundingRectangle = part.avatar.getBoundingRectangle()
          
        # Playfield should be slightly larger than all the parts so that it contains all parts as holes.
        playfieldBoundingRectangle = AP.BoundingRectangle.union boundingRectangles
        extrusion = 0.01
        playfieldBoundingRectangle = playfieldBoundingRectangle.getExtrudedBoundingRectangle extrusion, extrusion, extrusion, extrusion
        playfieldBoundary = playfieldBoundingRectangle.getBoundary()
        
        Tracker.nonreactive =>
          @_renderObject()?.destroy()
          @_physicsObject()?.destroy()
          @_renderObject null
          @_physicsObject null
          
          shape = new @constructor.Shape pixelArtEvaluation, properties, playfieldBoundary, holeBoundaries
          @_createObjectsWithShape properties, shape, bitmap
      
    class @Shape extends Pinball.Part.Avatar.TriangleMesh
      constructor: (@pixelArtEvaluation, @properties, playfieldBoundary, holeBoundaries) ->
        super arguments...
        
        playfieldPolygon = new AP.PolygonWithHoles playfieldBoundary, holeBoundaries
        playfieldPolygon = playfieldPolygon.getPolygonWithoutHoles()
        
        vertexBufferArray = new Float32Array playfieldPolygon.vertices.length * 3
        
        for vertex, vertexIndex in playfieldPolygon.vertices
          offset = vertexIndex * 3
          vertexBufferArray[offset] = vertex.x - @properties.position.x
          vertexBufferArray[offset + 1] = @properties.height
          vertexBufferArray[offset + 2] = vertex.y - @properties.position.y
    
        indexBufferArray = playfieldPolygon.triangulate()
        
        @geometryData = {vertexBufferArray, indexBufferArray}
        
      yPosition: -> -@properties.height
