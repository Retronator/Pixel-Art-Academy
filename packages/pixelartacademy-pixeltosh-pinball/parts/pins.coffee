LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Pins extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Pins'
  @fullName: -> "pins"
  @description: ->
    "
      The pins in pinball, small metal pins that change the ball's trajectory.
    "
  
  @assetId: -> Pinball.Assets.Playfield.id()
  
  @avatarClass: -> @Avatar
  
  @initialize()
  
  constants: ->
    height: 0.03
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    hidden: true
    
  class @Avatar extends Pinball.Part.Avatar
    _createShape: ->
      return unless pixelArtEvaluation = @part.pixelArtEvaluation()
      return unless pixelArtEvaluation.layers[0].points.length
      
      points = _.filter pixelArtEvaluation.layers[0].points, (point) => not point.neighbors.length
      
      new @constructor.Shape pixelArtEvaluation, @part.shapeProperties(), points
      
    class @Shape extends Pinball.Part.Avatar.Shape
      constructor: (@pixelArtEvaluation, @properties, points) ->
        super arguments...
        
        pixelSize = Pinball.CameraManager.orthographicPixelSize
        
        @pins = for point in points
          x: (point.x + 0.5 - @bitmapOrigin.x) * pixelSize
          z: (point.y + 0.5 - @bitmapOrigin.y) * pixelSize
          radius: point.radius * pixelSize * Pinball.Parts.Pin.radiusRatio
        
      createPhysicsDebugGeometry: ->
        return unless @pins.length
        
        cylinders = for pin in @pins
          cylinder = new THREE.CylinderGeometry pin.radius, pin.radius, @height
          
          positionAttribute = cylinder.getAttribute 'position'
          for index in [0...positionAttribute.array.length] by 3
            positionAttribute.array[index] += pin.x
            positionAttribute.array[index + 2] += pin.z
            
          cylinder
          
        THREE.BufferGeometryUtils.mergeBufferGeometries cylinders
      
      createCollisionShape: ->
        collisionShape = new Ammo.btCompoundShape

        for pin in @pins
          cylinder = new Ammo.btCylinderShape new Ammo.btVector3 pin.radius, @height / 2, pin.radius
          transform = new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3(pin.x, 0, pin.z)
          
          collisionShape.addChildShape transform, cylinder
        
        collisionShape
        
      positionY: -> @height / 2
