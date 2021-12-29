LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Polyhedron.Cluster
  @PointTypes:
    Pixel: 0
    Edge: 1
    Void: 2
    Extra: 3

  @PointTypeColors: [
    [176 / 255, 60 / 255, 60 / 255]
    [188 / 255, 140 / 255, 76 / 255]
    [108 / 255, 108 / 255, 108 / 255]
    [160 / 255, 160 / 255, 52 / 255]
  ]

  constructor: (@layerCluster) ->
    @id = @layerCluster.id
    @pictureCluster = @layerCluster.layer.getPictureCluster @id
    @picture = @pictureCluster.picture

    @edges = {}

    @plane =
      point: null
      normal: null
      matrix: null
      matrixInverse: null
      
    @points = []
    @indices = []

    @recomputePixels = true
    @recomputeEdges = true

    @startRecomputation()

  startRecomputation: ->
    @pixelsChanged = false
    @edgesChanged = false
    @planeChanged = false
    @previousPlane = _.clone @plane

    # Reset assignment to a cluster plane.
    @_clusterPlane = null

  changed: ->
    @pixelsChanged or @edgesChanged or @planeChanged

  setPlaneNormal: (normal) ->
    @plane.normal = THREE.Vector3.fromObject normal
    @planeChanged = true unless @previousPlane.normal?.equals normal

  setPlanePoint: (point) ->
    @plane.point = THREE.Vector3.fromObject point
    @planeChanged = true unless @previousPlane.point?.equals point

  getPlane: ->
    return unless @plane.point and @plane.normal

    new THREE.Plane().setFromNormalAndCoplanarPoint @plane.normal, @plane.point

  getLongestEdgeLengthBetweenNonParallelClusters: ->
    longestEdgeLength = 0

    for otherClusterId, edge of @edges when not edge.parallelClusters
      longestEdgeLength = Math.max longestEdgeLength, edge.segments.length

    longestEdgeLength

  updatePixels: ->
    @material = @layerCluster.material()
    @properties = @layerCluster.properties()
    @setPlaneNormal @material.normal
    
    # Create map for fast retrieval.
    @pixels = []
    @pixelMap = {}

    bounds = @picture.bounds()

    clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    # Prepare to determine size of the cluster in picture pixels.
    @minPixel = null
    @maxPixel = null

    for x in [0...bounds.width]
      for y in [0...bounds.height]
        continue unless @id is clusterIdMap.getPixel x, y

        absoluteX = x + bounds.x
        absoluteY = y + bounds.y

        pixel = _.extend
          x: absoluteX
          y: absoluteY
        ,
          @picture.getMapValuesForPixelRelative x, y

        @pixels.push pixel

        @pixelMap[absoluteX] ?= {}
        @pixelMap[absoluteX][absoluteY] = pixel

        @minPixel ?= x: pixel.x, y: pixel.y
        @maxPixel ?= x: pixel.x, y: pixel.y

        @minPixel.x = Math.min pixel.x, @minPixel.x
        @minPixel.y = Math.min pixel.y, @minPixel.y
        @maxPixel.x = Math.max pixel.x, @maxPixel.x
        @maxPixel.y = Math.max pixel.y, @maxPixel.y

    @boundsInPicture =
      x: @minPixel.x - bounds.x
      y: @minPixel.y - bounds.y
      width: @maxPixel.x - @minPixel.x + 1
      height: @maxPixel.y - @minPixel.y + 1

    # Mark edges.
    @_markPixelEdges @pixelMap

    @recomputePixels = false
    @pixelsChanged = true

  _markPixelEdges: (pixelMap) ->
    for x, column of pixelMap
      for y, pixel of column
        pixel.clusterNeighbors =
          left: pixelMap[pixel.x - 1]?[pixel.y]
          right: pixelMap[pixel.x + 1]?[pixel.y]
          up: pixelMap[pixel.x]?[pixel.y - 1]
          down: pixelMap[pixel.x]?[pixel.y + 1]
          leftUp: pixelMap[pixel.x - 1]?[pixel.y - 1]
          rightUp: pixelMap[pixel.x + 1]?[pixel.y - 1]
          leftDown: pixelMap[pixel.x - 1]?[pixel.y + 1]
          rightDown: pixelMap[pixel.x + 1]?[pixel.y + 1]

        pixel.clusterEdges = {}

        # Edge is on each side that doesn't have a neighbor.
        for side in ['left', 'right', 'up', 'down', 'leftUp', 'rightUp', 'leftDown', 'rightDown']
          pixel.clusterEdges[side] = not pixel.clusterNeighbors[side]
    
  addEdge: (edge) ->
    otherCluster = edge.getOtherCluster @
    @edges[otherCluster.id] = edge
    @edgesChanged = true
    
  removeEdge: (edge) ->
    otherCluster = edge.getOtherCluster @
    delete @edges[otherCluster.id]
    @edgesChanged = true

  findPixelAtCoordinates: (x, y) ->
    @pixelMap[x]?[y]

  prepareGeometryPixels: (cleanEdgePixels, cameraAngle) ->
    # Geometry pixels are the potentially changed pixels that are used for generation of 3D geometry points.
    unless cleanEdgePixels
      # By default geometry pixels match source pixels.
      @geometryPixels = @pixels
      @geometryPixelMap = @pixelMap
      return

    # We have to create a clone of pixels so that we can add/remove new ones.
    @geometryPixels = (_.clone pixel for pixel in @pixels)
    @geometryPixelMap = {}

    for pixel in @geometryPixels
      @geometryPixelMap[pixel.x] ?= {}
      @geometryPixelMap[pixel.x][pixel.y] = pixel

    # Reconsider every pixel on both sides of an edge segment, whether it belongs to this cluster or not.
    @cleanupPixels = []
    @cleanedPixels = []

    linePoint2D = new THREE.Vector2
    otherLinePoint = new THREE.Vector3
    otherLinePoint2D = new THREE.Vector2
    lineDirection2D = new THREE.Vector2
    lineNormal2D = new THREE.Vector2
    firstPixel = new THREE.Vector2
    secondPixel = new THREE.Vector2
    firstPixelCenter = new THREE.Vector2
    secondPixelCenter = new THREE.Vector2
    centerOffset = new THREE.Vector2 0.5, 0.5

    for otherClusterId, edge of @edges
      # Project 3D edge onto canvas.
      linePoint2D.copy cameraAngle.unprojectPoint edge.line.point, 0.5, 0.5

      otherLinePoint.copy(edge.line.point).add edge.line.direction
      otherLinePoint2D.copy cameraAngle.unprojectPoint otherLinePoint, 0.5, 0.5

      lineDirection2D.copy(otherLinePoint2D).sub linePoint2D
      lineDirection2D.z = 0
      lineDirection2D.normalize()

      # Create projection normal (perpendicular to the line direction)
      lineNormal2D.set -lineDirection2D.y, lineDirection2D.x

      for segment in edge.segments
        if segment[0].x is segment[1].x
          # This is a vertical segment.
          topVertexIndex = if segment[1].y is segment[0].y + 1 then 0 else 1
          firstPixel.set segment[topVertexIndex].x - 1, segment[topVertexIndex].y
          secondPixel.set segment[topVertexIndex].x, segment[topVertexIndex].y
          lineNormalIsPositive = lineNormal2D.x > 0

        else
          # This is a horizontal segment
          leftVertexIndex = if segment[1].x is segment[0].x + 1 then 0 else 1
          firstPixel.set segment[leftVertexIndex].x, segment[leftVertexIndex].y - 1
          secondPixel.set segment[leftVertexIndex].x, segment[leftVertexIndex].y
          lineNormalIsPositive = lineNormal2D.y > 0

        # Flip normal if necessary
        firstPixelBelongsToCluster = @pixelMap[firstPixel.x]?[firstPixel.y]?
        lineNormal2D.multiplyScalar -1 unless firstPixelBelongsToCluster is lineNormalIsPositive

        # Project pixels on the normal.
        firstPixelCenter.copy(firstPixel).add(centerOffset).sub linePoint2D
        firstPixelDistance = firstPixelCenter.dot lineNormal2D
        secondPixelCenter.copy(secondPixel).add(centerOffset).sub linePoint2D
        secondPixelDistance = secondPixelCenter.dot lineNormal2D

        # Pixels that should be in the cluster must have negative distance.
        @_cleanPixel firstPixel if firstPixelBelongsToCluster and firstPixelDistance > 0
        @_addCleanupPixel firstPixel if not firstPixelBelongsToCluster and firstPixelDistance < 0
        @_cleanPixel secondPixel if not firstPixelBelongsToCluster and secondPixelDistance > 0
        @_addCleanupPixel secondPixel if firstPixelBelongsToCluster and secondPixelDistance < 0

    # Update pixel map.
    for pixel in @cleanupPixels
      @geometryPixelMap[pixel.x] ?= {}
      @geometryPixelMap[pixel.x][pixel.y] = pixel

    for pixel in @cleanedPixels
      delete @geometryPixelMap[pixel.x][pixel.y]

    # Recompute pixel edges.
    @_markPixelEdges @geometryPixelMap

  _cleanPixel: (pixel) ->
    return unless clusterPixel = _.find @geometryPixels, (clusterPixel) => clusterPixel.x is pixel.x and clusterPixel.y is pixel.y

    _.pull @geometryPixels, clusterPixel
    @cleanedPixels.push clusterPixel
    # Note: we don't remove the pixel from the map yet since the map
    # is being used to determine which pixels are in the cluster.

  _addCleanupPixel: (pixel) ->
    return if _.find @geometryPixels, (clusterPixel) => clusterPixel.x is pixel.x and clusterPixel.y is pixel.y

    clusterPixel = _.extend
      x: pixel.x
      y: pixel.y
    ,
      @picture.getMapValuesForPixel pixel.x, pixel.y

    @geometryPixels.push clusterPixel
    @cleanupPixels.push clusterPixel
    # Note: we don't add the pixel to the map yet since the map
    # is being used to determine which pixels are in the cluster.

  getPoints: (options) ->
    elementsPerVertex = 3
    verticesArray = new Float32Array @points.length * elementsPerVertex
    colorsArray = new Float32Array @points.length * elementsPerVertex

    mesh = @layerCluster.layer.object.mesh
    palette = mesh.customPalette or LOI.Assets.Palette.documents.findOne mesh.palette._id

    paletteColor = @material.paletteColor

    unless paletteColor
      if @material.materialIndex?
        paletteColor = mesh.materials.get @material.materialIndex

    color = palette.ramps[paletteColor.ramp].shades[paletteColor.shade]

    for point, index in @points
      verticesArray[index * elementsPerVertex] = point.vertex.x
      verticesArray[index * elementsPerVertex + 1] = point.vertex.y
      verticesArray[index * elementsPerVertex + 2] = point.vertex.z

      if point.type is @constructor.PointTypes.Pixel
        colorsArray[index * elementsPerVertex] = color.r
        colorsArray[index * elementsPerVertex + 1] = color.g
        colorsArray[index * elementsPerVertex + 2] = color.b

      else
        for offset in [0..2]
          colorsArray[index * elementsPerVertex + offset] = @constructor.PointTypeColors[point.type][offset]

    geometry = new THREE.BufferGeometry
    geometry.setAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
    geometry.setAttribute 'color', new THREE.BufferAttribute colorsArray, elementsPerVertex

    material = new THREE.PointsMaterial
      size: 5
      vertexColors: THREE.VertexColors
      sizeAttenuation: false

    new THREE.Points geometry, material

  generateGeometry: (options) ->
    nanWarned = false
    elementsPerVertex = 3
    coordinatesPerVertex = 2
    bounds = @picture.bounds()

    if @properties?.extrusion
      # Calculate hull edges.
      hullMap = {}

      addEdge = (index1, index2) =>
        # Map to vertex indices.
        index1 = @indices[index1]
        index2 = @indices[index2]

        if hullMap[index1]?[index2]
          # The edge is represented twice so it's not on the hull.
          hullMap[index1][index2] = false

        else if hullMap[index2]?[index1]
          # Also not a hull edge.
          hullMap[index2][index1] = false

        else
          # This edge hasn't been added yet so we do it.
          hullMap[index1] ?= {}
          hullMap[index1][index2] = true

      for triangleIndexStart in [0...@indices.length] by 3
        addEdge triangleIndexStart, triangleIndexStart + 1
        addEdge triangleIndexStart + 1, triangleIndexStart + 2
        addEdge triangleIndexStart + 2, triangleIndexStart

      # Accumulate hull edges from the map.
      hullEdges = []

      for startIndex, endings of hullMap
        for endIndex, value of endings when value
          hullEdges.push
            start: parseInt startIndex
            end: parseInt endIndex

          break

      # Create vertices and normals.
      verticesCount = @points.length * 2 + hullEdges.length * 4
      vertices = new Float32Array verticesCount * elementsPerVertex
      pixelCoordinates = new Float32Array verticesCount * coordinatesPerVertex
      layerPixelCoordinates = new Float32Array verticesCount * coordinatesPerVertex
      normals = new Float32Array verticesCount * elementsPerVertex

      oppositeClusterVertexIndexOffset = @points.length
      extrusionVertexIndexOffset = 2 * oppositeClusterVertexIndexOffset

      # Extrude by the provided factor in the reverse direction of the plane normal.
      extrusionVector = @plane.normal.clone().multiplyScalar -@properties.extrusion

      for point, index in @points
        vertices[index * elementsPerVertex] = point.vertex.x
        vertices[index * elementsPerVertex + 1] = point.vertex.y
        vertices[index * elementsPerVertex + 2] = point.vertex.z

        normals[index * elementsPerVertex] = @plane.normal.x
        normals[index * elementsPerVertex + 1] = @plane.normal.y
        normals[index * elementsPerVertex + 2] = @plane.normal.z

        pixelCoordinates[index * coordinatesPerVertex] = point.pixel.x - @minPixel.x
        pixelCoordinates[index * coordinatesPerVertex + 1] = point.pixel.y - @minPixel.y

        layerPixelCoordinates[index * coordinatesPerVertex] = point.pixel.x - bounds.x
        layerPixelCoordinates[index * coordinatesPerVertex + 1] = point.pixel.y - bounds.y

        # Offset the position by the extrusion
        vertices[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex] = point.vertex.x + extrusionVector.x
        vertices[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 1] = point.vertex.y + extrusionVector.y
        vertices[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 2] = point.vertex.z + extrusionVector.z

        # Flip the normal for the reverse cluster.
        normals[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex] = -@plane.normal.x
        normals[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 1] = -@plane.normal.y
        normals[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 2] = -@plane.normal.z

        pixelCoordinates[(oppositeClusterVertexIndexOffset + index) * coordinatesPerVertex] = point.pixel.x - @minPixel.x
        pixelCoordinates[(oppositeClusterVertexIndexOffset + index) * coordinatesPerVertex + 1] = point.pixel.y - @minPixel.y

        layerPixelCoordinates[(oppositeClusterVertexIndexOffset + index) * coordinatesPerVertex] = point.pixel.x - bounds.x
        layerPixelCoordinates[(oppositeClusterVertexIndexOffset + index) * coordinatesPerVertex + 1] = point.pixel.y - bounds.y

        if not nanWarned and _.isNaN point.vertex.x
          console.warn "Cluster on layer #{@picture.layer.name()} has invalid vertices at", index, @
          nanWarned = true

      # Create extrusion vertices.
      for hullEdge, edgeIndex in hullEdges
        startPoint = @points[hullEdge.start]
        endPoint = @points[hullEdge.end]

        # First two points are the start and end points.
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex] = startPoint.vertex.x
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 1] = startPoint.vertex.y
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 2] = startPoint.vertex.z

        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 3] = endPoint.vertex.x
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 4] = endPoint.vertex.y
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 5] = endPoint.vertex.z

        # Second two points are the extruded start and end points.
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 6] = startPoint.vertex.x + extrusionVector.x
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 7] = startPoint.vertex.y + extrusionVector.y
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 8] = startPoint.vertex.z + extrusionVector.z

        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 9] = endPoint.vertex.x + extrusionVector.x
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 10] = endPoint.vertex.y + extrusionVector.y
        vertices[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + 11] = endPoint.vertex.z + extrusionVector.z

        # Calculate the normal of the extrusion.
        normal = new THREE.Vector3().subVectors endPoint.vertex, startPoint.vertex
        normal.cross @plane.normal
        normal.normalize()

        for pointIndex in [0..3]
          normals[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + pointIndex * 3] = normal.x
          normals[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + pointIndex * 3 + 1] = normal.y
          normals[(extrusionVertexIndexOffset + edgeIndex * 4) * elementsPerVertex + pointIndex * 3 + 2] = normal.z

          point = if pointIndex % 2 then endPoint else startPoint
          pixelCoordinates[(extrusionVertexIndexOffset + edgeIndex * 4) * coordinatesPerVertex + pointIndex * 3] = point.pixel.x - @minPixel.x
          pixelCoordinates[(extrusionVertexIndexOffset + edgeIndex * 4) * coordinatesPerVertex + pointIndex * 3 + 1] = point.pixel.y - @minPixel.y
          layerPixelCoordinates[(extrusionVertexIndexOffset + edgeIndex * 4) * coordinatesPerVertex + pointIndex * 3] = point.pixel.x - bounds.x
          layerPixelCoordinates[(extrusionVertexIndexOffset + edgeIndex * 4) * coordinatesPerVertex + pointIndex * 3 + 1] = point.pixel.y - bounds.y

      # Create indices.
      oppositeClusterIndicesIndexOffset = @indices.length
      extrusionIndicesIndexOffset = 2 * oppositeClusterIndicesIndexOffset

      indicesCount = @indices.length * 2 + hullEdges.length * 6
      indices = new Uint32Array indicesCount

      # Fill cluster indices.
      for triangleIndexStart in [0...@indices.length] by 3
        indices[triangleIndexStart] = @indices[triangleIndexStart]
        indices[triangleIndexStart + 1] = @indices[triangleIndexStart + 1]
        indices[triangleIndexStart + 2] = @indices[triangleIndexStart + 2]

        # Reverse cluster needs orientation of the triangle reversed.
        indices[oppositeClusterIndicesIndexOffset + triangleIndexStart] = @indices[triangleIndexStart] + oppositeClusterVertexIndexOffset
        indices[oppositeClusterIndicesIndexOffset + triangleIndexStart + 1] = @indices[triangleIndexStart + 2] + oppositeClusterVertexIndexOffset
        indices[oppositeClusterIndicesIndexOffset + triangleIndexStart + 2] = @indices[triangleIndexStart + 1] + oppositeClusterVertexIndexOffset

      # Fill extrusion indices.
      for hullEdge, edgeIndex in hullEdges
        indices[extrusionIndicesIndexOffset + edgeIndex * 6] = extrusionVertexIndexOffset + edgeIndex * 4
        indices[extrusionIndicesIndexOffset + edgeIndex * 6 + 1] = extrusionVertexIndexOffset + edgeIndex * 4 + 3
        indices[extrusionIndicesIndexOffset + edgeIndex * 6 + 2] = extrusionVertexIndexOffset + edgeIndex * 4 + 1

        indices[extrusionIndicesIndexOffset + edgeIndex * 6 + 3] = extrusionVertexIndexOffset + edgeIndex * 4
        indices[extrusionIndicesIndexOffset + edgeIndex * 6 + 4] = extrusionVertexIndexOffset + edgeIndex * 4 + 2
        indices[extrusionIndicesIndexOffset + edgeIndex * 6 + 5] = extrusionVertexIndexOffset + edgeIndex * 4 + 3

    else
      vertices = new Float32Array @points.length * elementsPerVertex
      normals = new Float32Array @points.length * elementsPerVertex
      pixelCoordinates = new Float32Array @points.length * coordinatesPerVertex
      layerPixelCoordinates = new Float32Array @points.length * coordinatesPerVertex
      indices = new Uint32Array @indices

      for point, index in @points
        vertices[index * elementsPerVertex] = point.vertex.x
        vertices[index * elementsPerVertex + 1] = point.vertex.y
        vertices[index * elementsPerVertex + 2] = point.vertex.z

        normals[index * elementsPerVertex] = @plane.normal.x
        normals[index * elementsPerVertex + 1] = @plane.normal.y
        normals[index * elementsPerVertex + 2] = @plane.normal.z

        pixelCoordinates[index * coordinatesPerVertex] = point.pixel.x - @minPixel.x
        pixelCoordinates[index * coordinatesPerVertex + 1] = point.pixel.y - @minPixel.y

        layerPixelCoordinates[index * coordinatesPerVertex] = point.pixel.x - bounds.x
        layerPixelCoordinates[index * coordinatesPerVertex + 1] = point.pixel.y - bounds.y

        if not nanWarned and _.isNaN point.vertex.x
          console.warn "Cluster on layer #{@picture.layer.name()} has invalid vertices at", index, @
          nanWarned = true

    console.log "Created geometry for cluster", @, vertices, normals, pixelCoordinates, indices if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

    {vertices, normals, pixelCoordinates, layerPixelCoordinates, indices}
