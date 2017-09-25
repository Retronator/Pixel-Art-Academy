# Extra functionality for the vector classes.

# Convert the vector to a plain object.
THREE.Vector3::toObject = ->
  x: @x
  y: @y
  z: @z

# Create a new vector from a plain object.
THREE.Vector3.fromObject = (object) ->
  return new THREE.Vector3().copy object
