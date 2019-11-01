# Extra functionality for the quaternion class.

# Convert the quaternion to a plain object.
THREE.Quaternion::toObject = ->
  x: @x
  y: @y
  z: @z
  w: @w

THREE.Quaternion::toBulletQuaternion = ->
  new Ammo.btQuaternion @x, @y, @z, @w

THREE.Quaternion::setFromBulletQuaternion = (bulletQuaternion) ->
  @x = bulletQuaternion.x()
  @y = bulletQuaternion.y()
  @z = bulletQuaternion.z()
  @w = bulletQuaternion.w()

# Create a new quaternion from a plain object.
THREE.Quaternion.fromObject = (object) ->
  return new THREE.Quaternion object.x, object.y, object.z, object.w
