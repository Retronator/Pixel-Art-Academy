LOI = LandsOfIllusions

Delaunator = require 'delaunator'

PointTypes = LOI.Assets.Engine.Mesh.Object.Cluster.PointTypes

LOI.Assets.Engine.Mesh.Object.computeClusterMeshes = (clusters) ->
  console.log "Computing cluster meshes", clusters if LOI.Assets.Engine.Mesh.debug

  getX = (point) => point.vertexPlane.x
  getY = (point) => point.vertexPlane.y

  for cluster in clusters
    cluster.indices = []
    extraPoints = {}

    delaunay = Delaunator.from cluster.points, getX, getY

    for triangle in [0...delaunay.triangles.length / 3]
      # Only add triangles that include at least one pixel.
      voidCount = 0
      edgeCount = 0
      pixelCount = 0
      
      for pointOffset in [0..2]
        pointIndex = delaunay.triangles[triangle * 3 + pointOffset]
        switch cluster.points[pointIndex].type
          when PointTypes.Void then voidCount++
          when PointTypes.Edge then edgeCount++
          when PointTypes.Pixel then pixelCount++

      continue unless pixelCount or edgeCount is 3
      
      indices = (delaunay.triangles[triangle * 3 + offset] for offset in [0..2])

      if voidCount is 1
        if pixelCount is 1
          # We have one of each point type. Replace the void with an extra.
          voidTriangleVertexIndex = findTriangleVertexIndexOfType PointTypes.Void, indices, cluster
          pixelTriangleVertexIndex = findTriangleVertexIndexOfType PointTypes.Pixel, indices, cluster

          voidPointIndex = indices[voidTriangleVertexIndex]
          pixelPointIndex = indices[pixelTriangleVertexIndex]
          extraPointIndex = getExtraPointIndex voidPointIndex, pixelPointIndex, extraPoints, cluster

          indices[voidTriangleVertexIndex] = extraPointIndex

        else
          # We have two pixels and one void. First shift the indices so that the middle point is the void.
          voidTriangleVertexIndex = findTriangleVertexIndexOfType PointTypes.Void, indices, cluster
          requiredShifts = (voidTriangleVertexIndex + 2) % 3

          while requiredShifts
            indices.push indices.shift()
            requiredShifts--

          # Now replace the void with extra towards the second pixel.
          voidPointIndex = indices[1]
          pixelPointIndex = indices[2]
          indices[1] = getExtraPointIndex voidPointIndex, pixelPointIndex, extraPoints, cluster

          # Add an extra triangle between the first pixel and both possible extras.
          indices[3] = indices[0]
          pixelPointIndex = indices[0]
          indices[4] = getExtraPointIndex voidPointIndex, pixelPointIndex, extraPoints, cluster
          indices[5] = indices[1]

      else if voidCount is 2
        # We have a pixel and two voids. Replace void pixels with extra pixels.
        pixelTriangleVertexIndex = findTriangleVertexIndexOfType PointTypes.Pixel, indices, cluster
        pixelPointIndex = indices[pixelTriangleVertexIndex]

        for voidTriangleVertexIndex in [0..2] when voidTriangleVertexIndex isnt pixelTriangleVertexIndex
          voidPointIndex = indices[voidTriangleVertexIndex]
          extraPointIndex = getExtraPointIndex voidPointIndex, pixelPointIndex, extraPoints, cluster
          indices[voidTriangleVertexIndex] = extraPointIndex

      else if edgeCount is 3
        # We have a triangle between just edge vertices. Check if it is inside or outside the cluster.
        edgeCombinations = [
          fromIndex: indices[0], toIndex: indices[1]
        ,
          fromIndex: indices[1], toIndex: indices[2]
        ,
          fromIndex: indices[2], toIndex: indices[0]
        ]

        triangleIsOutside = false

        for edgeCombination in edgeCombinations
          startPoint = cluster.points[edgeCombination.fromIndex]
          endPoint = cluster.points[edgeCombination.toIndex]
          continue unless startPoint.edge is endPoint.edge

          # Find segment from start point that also includes the end point.
          endSegmentInfo = null

          for startSegmentInfo in startPoint.segments
            endSegmentInfo = _.find endPoint.segments, (segment) => segment.edge is startSegmentInfo.edge and segment.index is startSegmentInfo.index
            break

          # If we haven't found a segment between these two points, go on to other edge combinations.
          continue unless endSegmentInfo

          # We found the segment spanning these points. See which direction they're going.
          direction = endSegmentInfo.positionInSegment - startSegmentInfo.positionInSegment

          # Edge segments are defined so that cluster A is on the inside of a clockwise circle.
          # First we need to switch direction in case we are not cluster A of the edge.
          direction *= -1 unless startSegmentInfo.edge.clusterA is cluster

          # Delaunay gives us counter-clockwise triangles, so if direction is positive,
          # we're on the outside of the cluster and the triangle should be discarded.
          triangleIsOutside = direction > 0

        continue if triangleIsOutside

      # We created required indices so add them to the cluster.
      cluster.indices.push indices...

  console.log "Computed cluster meshes", clusters if LOI.Assets.Engine.Mesh.debug

findTriangleVertexIndexOfType = (type, indices, cluster) ->
  for index, triangleVertexIndex in indices
    return triangleVertexIndex if cluster.points[index].type is type

getExtraPointIndex = (voidPointIndex, pixelPointIndex, extraPoints, cluster) ->
  # We have extra points indexed from smaller to bigger
  if voidPointIndex < pixelPointIndex
    smallerIndex = voidPointIndex
    biggerIndex = pixelPointIndex

  else
    smallerIndex = pixelPointIndex
    biggerIndex = voidPointIndex

  extraPoints[smallerIndex] ?= {}

  unless extraPoints[smallerIndex][biggerIndex]
    # We need to create the extra point in between the two points.
    voidPoint = cluster.points[voidPointIndex]
    pixelPoint = cluster.points[pixelPointIndex]

    extraPoints[smallerIndex][biggerIndex] = cluster.points.length

    cluster.points.push
      type: PointTypes.Extra
      vertex: new THREE.Vector3().subVectors(pixelPoint.vertex, voidPoint.vertex).multiplyScalar(0.5).add voidPoint.vertex

  extraPoints[smallerIndex][biggerIndex]
