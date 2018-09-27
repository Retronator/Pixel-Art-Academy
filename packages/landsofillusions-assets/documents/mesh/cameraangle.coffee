AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.CameraAngle
  constructor: (data) ->
    _.extend @, data

    position = @_createVector @position
    target = @_createVector @target
    up = @_createVector @up

    @worldMatrix = new THREE.Matrix4().lookAt position, target, up
    @worldMatrix.setPosition position

    return unless @worldMatrix.determinant()

    @worldMatrixInverse = new THREE.Matrix4().getInverse @worldMatrix

  _createVector: (vectorData = {}) ->
    new THREE.Vector3 vectorData.x or 0, vectorData.y or 0, vectorData.z or 0

  projectPoints: (screenPoints, worldPlane, xOffset = 0, yOffset = 0) ->
    projectedWorldPoints = []

    position = new THREE.Vector3().copy @position

    for screenPoint in screenPoints
      worldPoint = new THREE.Vector3 screenPoint.x + xOffset, -(screenPoint.y + yOffset), -@picturePlaneDistance
      worldPoint.applyMatrix4 @worldMatrix

      rayNormal = new THREE.Vector3().subVectors(worldPoint, position).normalize()
      ray = new THREE.Ray position, rayNormal

      projectedWorldPoint = new THREE.Vector3
      intersection = ray.intersectPlane worldPlane, projectedWorldPoint

      projectedWorldPoints.push projectedWorldPoint if intersection

    projectedWorldPoints
