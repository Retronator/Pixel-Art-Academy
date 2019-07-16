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
    
    @origin =
      x: @picture.bounds?.x or 0
      y: @picture.bounds?.y or 0

    @recomputePixels = true
    @recomputeEdges = true

    @startRecomputation()

  startRecomputation: ->
    @pixelsChanged = false
    @edgesChanged = false
    @planeChanged = false
    @previousPlane = _.clone @plane

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

  updatePixels: ->
    @material = @layerCluster.material()
    @properties = @layerCluster.properties()
    @setPlaneNormal @material.normal
    
    # Create map for fast retrieval.
    @pixels = []
    @pixelMap = {}

    bounds = @picture.bounds()

    clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

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

    # Mark edges.
    for x, column of @pixelMap
      for y, pixel of column
        pixel.clusterNeighbors =
          left: @pixelMap[pixel.x - 1]?[pixel.y]
          right: @pixelMap[pixel.x + 1]?[pixel.y]
          up: @pixelMap[pixel.x]?[pixel.y - 1]
          down: @pixelMap[pixel.x]?[pixel.y + 1]
          leftUp: @pixelMap[pixel.x - 1]?[pixel.y - 1]
          rightUp: @pixelMap[pixel.x + 1]?[pixel.y - 1]
          leftDown: @pixelMap[pixel.x - 1]?[pixel.y + 1]
          rightDown: @pixelMap[pixel.x + 1]?[pixel.y + 1]

        pixel.clusterEdges = {}

        # Edge is on each side that doesn't have a neighbor.
        for side in ['left', 'right', 'up', 'down', 'leftUp', 'rightUp', 'leftDown', 'rightDown']
          pixel.clusterEdges[side] = not pixel.clusterNeighbors[side]

    @recomputePixels = false
    @pixelsChanged = true
    
  addEdge: (edge) ->
    otherCluster = edge.getOtherCluster @
    @edges[otherCluster.id] = edge
    @edgesChanged = true
    
  removeEdge: (edge) ->
    otherCluster = edge.getOtherCluster @
    delete @edges[otherCluster.id]
    @edgesChanged = true

  getAbsolutePixelCoordinates: (pixel) ->
    x: pixel.x + @origin.x
    y: pixel.y + @origin.y

  findPixelAtAbsoluteCoordinate: (absoluteX, absoluteY) ->
    x = Math.floor absoluteX - @origin.x
    y = Math.floor absoluteY - @origin.y
    
    @pixelMap[x]?[y]

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
    geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
    geometry.addAttribute 'color', new THREE.BufferAttribute colorsArray, elementsPerVertex

    material = new THREE.PointsMaterial
      size: 5
      vertexColors: THREE.VertexColors
      sizeAttenuation: false

    new THREE.Points geometry, material

  generateGeometry: (options) ->
    nanWarned = false
    elementsPerVertex = 3

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

        # Offset the position by the extrusion
        vertices[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex] = point.vertex.x + extrusionVector.x
        vertices[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 1] = point.vertex.y + extrusionVector.y
        vertices[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 2] = point.vertex.z + extrusionVector.z

        # Flip the normal for the reverse cluster.
        normals[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex] = -@plane.normal.x
        normals[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 1] = -@plane.normal.y
        normals[(oppositeClusterVertexIndexOffset + index) * elementsPerVertex + 2] = -@plane.normal.z

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
      indices = new Uint32Array @indices

      for point, index in @points
        vertices[index * elementsPerVertex] = point.vertex.x
        vertices[index * elementsPerVertex + 1] = point.vertex.y
        vertices[index * elementsPerVertex + 2] = point.vertex.z

        normals[index * elementsPerVertex] = @plane.normal.x
        normals[index * elementsPerVertex + 1] = @plane.normal.y
        normals[index * elementsPerVertex + 2] = @plane.normal.z

        if not nanWarned and _.isNaN point.vertex.x
          console.warn "Cluster on layer #{@picture.layer.name()} has invalid vertices at", index, @
          nanWarned = true

    {vertices, normals, indices}
