LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Grid extends THREE.LineSegments
  constructor: (@meshCanvas) ->
    geometry = new THREE.BufferGeometry

    # We create a unit grid from -gridSize to gridSize. That's 2 * gridSize +1
    # lines in each direction and each line has 2 vertices (start and end).
    gridSize = 100
    linesCount = 2 * gridSize + 1
    elementsPerVertex = 3
    elementsPerLine = elementsPerVertex * 2

    verticesArray = new Float32Array linesCount * 2 * elementsPerLine
    horizontalVerticesArray = verticesArray.subarray linesCount * elementsPerLine

    colorsArray = new Float32Array linesCount * 2 * elementsPerLine
    horizontalColorsArray = colorsArray.subarray linesCount * elementsPerLine

    for i in [0...linesCount]
      x = -gridSize + i

      verticesArray[i * elementsPerLine] = x
      verticesArray[i * elementsPerLine + 1] = -gridSize
      verticesArray[i * elementsPerLine + 3] = x
      verticesArray[i * elementsPerLine + 4] = gridSize

      horizontalVerticesArray[i * elementsPerLine] = -gridSize
      horizontalVerticesArray[i * elementsPerLine + 1] = x
      horizontalVerticesArray[i * elementsPerLine + 3] = gridSize
      horizontalVerticesArray[i * elementsPerLine + 4] = x

      shade = if x then 0.5 else 1

      for offset in [0..5]
        colorsArray[i * elementsPerLine + offset] = shade
        horizontalColorsArray[i * elementsPerLine + offset] = shade

    geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
    geometry.addAttribute 'color', new THREE.BufferAttribute colorsArray, elementsPerVertex

    material = new THREE.LineBasicMaterial vertexColors: THREE.VertexColors

    super geometry, material

    @layers.set 1

    @meshCanvas.sceneHelper().scene().add @

    # Reactively change visibility of the grid.
    @meshCanvas.autorun =>
      @visible = @meshCanvas.planeGridEnabled()
      @meshCanvas.sceneHelper().scene.updated()

    # Match orientation to normal.
    zero = new THREE.Vector3
    up = new THREE.Vector3 0, 1, 0
    right = new THREE.Vector3 1, 0, 0

    @meshCanvas.autorun (computation) =>
      coplanarPoint = new THREE.Vector3()

      if cluster = @meshCanvas.currentClusterHelper().cluster()
        cluster.getPlane().coplanarPoint coplanarPoint

      normal = @meshCanvas.paintHelper.normal()

      plane = new THREE.Plane().setFromNormalAndCoplanarPoint normal, coplanarPoint

      planeZero = new THREE.Vector3()
      plane.projectPoint zero, planeZero

      # Note: We use right to align the grid at the poles since
      # there the normal and up get very close and unpredictable.
      @matrix.lookAt zero, plane.normal, if plane.normal.y > 0.99 then right else up

      # Move the grid slightly above the cluster to prevent Z-fighting.
      @matrix.setPosition planeZero.add plane.normal.clone().multiplyScalar 0.001
      @matrix.decompose @position, @quaternion, @scale

      @meshCanvas.sceneHelper().scene.updated()