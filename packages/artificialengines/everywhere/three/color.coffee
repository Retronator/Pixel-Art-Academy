# Extra functionality for the color class.

# Convert the color to a plain object.
THREE.Color::toObject = ->
  r: @r
  g: @g
  b: @b

# Create a new color from a plain object.
THREE.Color.fromObject = (object) ->
  return new THREE.Color().copy object
