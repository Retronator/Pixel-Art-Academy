# Extra functionality for the quaternion class.

# Convert the quaternion to a plain object.
Ammo.btQuaternion::toObject = ->
  x: @x()
  y: @y()
  z: @z()
  w: @w()

Ammo.btQuaternion::toThreeQuaternion = ->
  new THREE.Quaternion @x(), @y(), @z(), @w()

Ammo.btQuaternion::setFromThreeQuaternion = (threeQuaternion) ->
  @copy threeQuaternion

Ammo.btQuaternion::copy = (source) ->
  @setX source.x
  @setY source.y
  @setZ source.z
  @setW source.w

# Create a new quaternion from a plain object.
Ammo.btQuaternion.fromObject = (object) ->
  return new Ammo.btQuaternion object.x, object.y, object.z, object.w

Ammo.btQuaternion.identity = -> new Ammo.btQuaternion 0, 0, 0, 1
