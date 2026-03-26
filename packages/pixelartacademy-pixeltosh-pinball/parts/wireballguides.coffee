LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

_up = new THREE.Vector3 0, 1, 0
_down = new THREE.Vector3 0, -1, 0

class Pinball.Parts.WireBallGuides extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.WireBallGuides'
  @fullName: -> "wire ball guides"
  @description: ->
    "
      Thin wires that guide the ball along lanes.
    "
  
  @assetId: -> Pinball.Assets.Playfield.id()
  
  @avatarClass: -> @Avatar
  
  @initialize()
  
  constants: ->
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    hidden: true
    
  extraShapeProperties: ->
    return unless sceneManager = @pinball.sceneManager()
    
    height: sceneManager.ballPositionY() + @constructor.Avatar.Shape.joinDistance
    
  class @Avatar extends Pinball.Part.Avatar
    _createShape: ->
      return unless pixelArtEvaluation = @part.pixelArtEvaluation()
      return unless pixelArtEvaluation.layers[0].points.length
      
      lines = _.filter pixelArtEvaluation.layers[0].lines, (line) => not line.core
      
      new @constructor.Shape pixelArtEvaluation, @part.shapeProperties(), lines
      
    class @Shape extends Pinball.Part.Avatar.TriangleMesh
      @wireRadius = 0.001
      @joinDistance = 0.0015
      
      constructor: (@pixelArtEvaluation, @properties, lines) ->
        super arguments...
        
        pixelSize = Pinball.CameraManager.orthographicPixelSize
        individualGeometryData = []
        
        for line in lines
          points = @_getLinePoints line, false
          
          linePoints = for point in points
            position: new THREE.Vector3 point.x * pixelSize, 0, point.y * pixelSize
            radius: @constructor.wireRadius
            tangent: new THREE.Vector3 point.tangent.x, 0, point.tangent.y
            outgoingTangent: if point.outgoingTangent then new THREE.Vector3 point.outgoingTangent.x, 0, point.outgoingTangent.y else null
            normal: _up
          
          firstLinePoint = linePoints[0]
          firstLinePoint.outgoingNormal =  firstLinePoint.normal
          firstLinePoint.normal = firstLinePoint.tangent.clone().negate()
          firstLinePoint.outgoingTangent = firstLinePoint.tangent
          firstLinePoint.tangent = _up
          
          linePoints.unshift
            position: new THREE.Vector3 firstLinePoint.position.x, -@height, firstLinePoint.position.z
            radius: @constructor.wireRadius
            tangent: firstLinePoint.tangent
            normal: firstLinePoint.normal
            
          lastLinePoint = _.last linePoints
          lastLinePoint.outgoingNormal = lastLinePoint.tangent
          lastLinePoint.outgoingTangent = _down
          
          linePoints.push
            position: new THREE.Vector3 lastLinePoint.position.x, -@height, lastLinePoint.position.z
            radius: @constructor.wireRadius
            tangent: lastLinePoint.outgoingTangent
            normal: lastLinePoint.outgoingNormal
            
          individualGeometryData.push @constructor._createLineVerticesAndIndices linePoints, 8, @constructor.joinDistance
        
        @geometryData = @constructor._mergeGeometryData individualGeometryData
        
      positionY: -> @height
