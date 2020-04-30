# Extra functionality for the vector classes.

_position = new THREE.Vector3
_quaternion = new THREE.Quaternion

THREE.Matrix4::lerp = (m, alpha) ->
  THREE.Matrix4.lerp @, m, @, alpha

THREE.Matrix4::lerpMatrices = (m1, m2, alpha) ->
  THREE.Matrix4.lerp m1, m2, @, alpha

THREE.Matrix4::setFromBulletTransform = (bulletTransform) ->
  _position.setFromBulletVector3 bulletTransform.getOrigin()
  _quaternion.setFromBulletQuaternion bulletTransform.getRotation()

  @makeRotationFromQuaternion(_quaternion).setPosition _position

THREE.Matrix4.lerp = (m1, m2, target, alpha) ->
  for index in [0...16]
    target.elements[index] = m1.elements[index] + (m2.elements[index] - m1.elements[index]) * alpha
