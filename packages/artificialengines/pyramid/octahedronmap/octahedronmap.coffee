AP = Artificial.Pyramid

class AP.OctahedronMap
  # Converts a direction to a position on the octahedron map. The resolution of the octahedron map can be specified in
  # which case the position on the hemisphere will be clamped to the centers of the pixels. This is to prevent bleed
  # across hemispheres when sampling with linear interpolation.
  @directionToPosition: (direction, resolution) ->
    pointOnOctahedron = new THREE.Vector3().copy direction
    pointOnOctahedron.divideScalar Math.abs(direction.x) + Math.abs(direction.y) + Math.abs(direction.z)

    hemispherePosition = new THREE.Vector2(
      (pointOnOctahedron.x + pointOnOctahedron.y + 1) * 0.5,
      (pointOnOctahedron.x - pointOnOctahedron.y + 1) * 0.5
    )

    if resolution
      # Clamp positions outside outmost pixel centers.
      border = 0.5 / resolution
      hemispherePosition.clampScalar border, 1 - border

    # Position hemisphere in top or bottom half.
    new THREE.Vector2(
      hemispherePosition.x,
      hemispherePosition.y * 0.5 + (if direction.z < 0 then 0.5 else 0)
    )

  # Converts a position on an octahedron map to a point on the octahedron.
  @positionToPointOnOctahedron: (octahedronMapPosition) ->
    hemispherePosition =
      x: octahedronMapPosition.x,
      y: (octahedronMapPosition.y % 0.5) * 2

    pointOnOctahedron = new THREE.Vector3(
      hemispherePosition.x + hemispherePosition.y - 1,
      hemispherePosition.x - hemispherePosition.y,
      0
    )

    pointOnOctahedron.z = 1 - Math.abs(pointOnOctahedron.x) - Math.abs(pointOnOctahedron.y)
    pointOnOctahedron.z *= -1 if octahedronMapPosition.y >= 0.5

    pointOnOctahedron

  # Converts a position on an octahedron map to a direction.
  @positionToDirection: (octahedronMapPosition) ->
    @positionToPointOnOctahedron(octahedronMapPosition).normalize()
