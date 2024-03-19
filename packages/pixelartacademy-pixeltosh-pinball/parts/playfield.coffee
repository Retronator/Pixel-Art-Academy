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
    height: 0.1
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
        holes = []
        
        for part in @part.pinball.sceneManager().parts()
          holes.push hole if hole = part.playfieldHoleRectangle()
        
        Tracker.nonreactive =>
          @_renderObject()?.destroy()
          @_physicsObject()?.destroy()
          @_renderObject null
          @_physicsObject null
          
          shape = new @constructor.Shape pixelArtEvaluation, properties, holes
          @_createObjectsWithShape properties, shape, bitmap
      
    class @Shape extends Pinball.Part.Avatar.TriangleMesh
      constructor: (@pixelArtEvaluation, @properties, @holes) ->
        super arguments...
        
        vertices = new Float32Array 4 * 3
        indices = new Uint32Array 2 * 3
        
        pixelSize = Pinball.CameraManager.orthographicPixelSize
        
        vertices[0] = -90 * pixelSize
        vertices[2] = -100 * pixelSize
        vertices[3] = 90 * pixelSize
        vertices[5] = -100 * pixelSize
        vertices[6] = -90 * pixelSize
        vertices[8] = 100 * pixelSize
        vertices[9] = 90 * pixelSize
        vertices[11] = 100 * pixelSize
        
        indices[0] = 0
        indices[1] = 1
        indices[2] = 2
        indices[3] = 2
        indices[4] = 1
        indices[5] = 3
        
        @geometryData = {vertices, indices}
        
      yPosition: -> 0
