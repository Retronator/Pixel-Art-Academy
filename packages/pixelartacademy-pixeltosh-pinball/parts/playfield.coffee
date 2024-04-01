AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Playfield extends Pinball.Part
  # angleDegrees: the tilt of the playfield affecting the direction of gravity
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Playfield'
  @fullName: -> "playfield"
  @description: ->
    "
      The surface of the pinball table on which different parts are placed.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/playfield.png'
  
  @avatarClass: -> @Avatar
  
  @editable: -> false
  
  @initialize()
  
  @physicsDebugMaterial = new THREE.MeshStandardMaterial color: 0xffffff
  
  settings: ->
    angleDegrees:
      name: "Angle"
      unit: "°"
      type: Pinball.Interface.Settings.Number.id()
      min: 0
      max: 90
      step: 0.5
      default: 6.5
      
  constants: ->
    height: 0.05
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    physicsDebugMaterial: @constructor.physicsDebugMaterial
    
  class @Avatar extends Pinball.Part.Avatar
    initialize: ->
      @playfieldPosition = new ComputedField =>
        @part.data()?.position
      ,
        EJSON.equals
      
      # Playfield should be slightly larger than all the parts so that it contains all parts as holes.
      @playfieldBoundingRectangle = new ComputedField =>
        return unless sceneManager = @part.pinball.sceneManager()
        
        boundingRectangles = []
      
        for part in sceneManager.parts() when part isnt @part
          boundingRectangles.push boundingRectangle if boundingRectangle = part.avatar.getBoundingRectangle()
          
        return unless boundingRectangles.length
        
        playfieldBoundingRectangle = AP.BoundingRectangle.union boundingRectangles
        extrusion = 0.01
        playfieldBoundingRectangle.getExtrudedBoundingRectangle extrusion, extrusion, extrusion, extrusion
      ,
        EJSON.equals
        
      super arguments...
    
    _createShape: ->
      return unless pixelArtEvaluation = @part.pixelArtEvaluation()
      return unless playfieldPosition = @playfieldPosition()
      return unless playfieldBoundary = @playfieldBoundingRectangle()?.getBoundary()
      
      # See which parts require holes in the playfield.
      holeBoundaries = []
      
      for part in @part.pinball.sceneManager().parts()
        holeBoundaries.push partHoleBoundaries... if partHoleBoundaries = part.playfieldHoleBoundaries()
      
      new @constructor.Shape pixelArtEvaluation, @part.shapeProperties(), playfieldPosition, playfieldBoundary, holeBoundaries
      
    class @Shape extends Pinball.Part.Avatar.TriangleMesh
      constructor: (@pixelArtEvaluation, @properties, playfieldPosition, playfieldBoundary, holeBoundaries) ->
        super arguments...
        
        playfieldPolygon = new AP.PolygonWithHoles playfieldBoundary, holeBoundaries
        playfieldPolygon = playfieldPolygon.getPolygonWithoutHoles()
        
        vertexBufferArray = new Float32Array playfieldPolygon.vertices.length * 3
        normalArray = new Float32Array playfieldPolygon.vertices.length * 3
        
        for vertex, vertexIndex in playfieldPolygon.vertices
          offset = vertexIndex * 3
          vertexBufferArray[offset] = vertex.x - playfieldPosition.x
          vertexBufferArray[offset + 1] = @height
          vertexBufferArray[offset + 2] = vertex.y - playfieldPosition.z
          normalArray[offset + 1] = 1
    
        indexBufferArray = playfieldPolygon.triangulate()
        _.reverse indexBufferArray
        
        @geometryData = {vertexBufferArray, normalArray, indexBufferArray}
        
      positionY: -> -@height
