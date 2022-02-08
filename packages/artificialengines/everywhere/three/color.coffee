# Extra functionality for the color class.

# Convert the color to a plain object.
THREE.Color::toObject = ->
  r: @r
  g: @g
  b: @b
  
# Convert the color to an array of byte values.
THREE.Color::toByteArray = ->
  Math.floor value * 255 for value in [@r, @g, @b]

# Normalizes the color to have unit green component.
THREE.Color::normalize = ->
  if @g
    @r /= @g
    @b /= @g
    @g = 1

  else
    @r = 1
    @g = 1
    @b = 1

  return @
  
# Create a new color from a plain object.
THREE.Color.fromObject = (object) ->
  return new THREE.Color().copy object
