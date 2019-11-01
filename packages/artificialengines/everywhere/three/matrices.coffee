# Extra functionality for the vector classes.

THREE.Matrix4::lerp = (m, alpha) ->
  THREE.Matrix4.lerp @, m, @, alpha

THREE.Matrix4::lerpMatrices = (m1, m2, alpha) ->
  THREE.Matrix4.lerp m1, m2, @, alpha

THREE.Matrix4.lerp = (m1, m2, target, alpha) ->
  for index in [0...16]
    target.elements[index] = m1.elements[index] + (m2.elements[index] - m1.elements[index]) * alpha
