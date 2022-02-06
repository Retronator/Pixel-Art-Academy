LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.PlaneGrid extends THREE.Object3D
  constructor: (@meshCanvas) ->
    super arguments...

    @grid = new ReactiveField null

    material = new THREE.LineBasicMaterial vertexColors: THREE.VertexColors

    # Reactively generate grid geometry.
    @meshCanvas.autorun (computation) =>
      return unless meshData = @meshCanvas.meshData()

      geometry = new THREE.BufferGeometry
      
      planeGridData = _.defaults meshData.planeGrid,
        size: 100
        spacing: 1
        subdivisions: 0

      minorSpacing = planeGridData.spacing / (planeGridData.subdivisions + 1)
      gridlinesCountPerExtent = Math.ceil planeGridData.size / minorSpacing
      extent = gridlinesCountPerExtent * minorSpacing

      # We create a grid from -gridlinesCountPerExtent to gridlinesCountPerExtent. That's 2 * gridlinesCountPerExtent + 1
      # lines in each direction and each line has 2 vertices (start and end).
      linesCount = 2 * gridlinesCountPerExtent + 1
      elementsPerVertex = 3
      elementsPerLine = elementsPerVertex * 2
  
      verticesArray = new Float32Array linesCount * 2 * elementsPerLine
      horizontalVerticesArray = verticesArray.subarray linesCount * elementsPerLine
  
      colorsArray = new Float32Array linesCount * 2 * elementsPerLine
      horizontalColorsArray = colorsArray.subarray linesCount * elementsPerLine

      spacingEpsilon = 1e-5
  
      for i in [0...linesCount]
        x = -extent + i * minorSpacing
  
        verticesArray[i * elementsPerLine] = x
        verticesArray[i * elementsPerLine + 1] = -extent
        verticesArray[i * elementsPerLine + 3] = x
        verticesArray[i * elementsPerLine + 4] = extent
  
        horizontalVerticesArray[i * elementsPerLine] = -extent
        horizontalVerticesArray[i * elementsPerLine + 1] = x
        horizontalVerticesArray[i * elementsPerLine + 3] = extent
        horizontalVerticesArray[i * elementsPerLine + 4] = x

        absX = Math.abs(x)

        if absX < spacingEpsilon
          shade = 1

        else if (absX + spacingEpsilon) % planeGridData.spacing < 2 * spacingEpsilon
          shade = 0.5

        else
          shade = 0.25
  
        for offset in [0..5]
          colorsArray[i * elementsPerLine + offset] = shade
          horizontalColorsArray[i * elementsPerLine + offset] = shade
  
      geometry.setAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
      geometry.setAttribute 'color', new THREE.BufferAttribute colorsArray, elementsPerVertex

      grid = new THREE.LineSegments geometry, material
      grid.layers.set LOI.Assets.MeshEditor.RenderLayers.OverlayHelpers

      # Remove previous grid.
      scene = @meshCanvas.sceneHelper().scene()

      Tracker.nonreactive =>
        if previousGrid = @grid()
          previousGrid.geometry.dispose()
          scene.remove previousGrid

      # Add new grid.
      scene.add grid
      @grid grid

      @meshCanvas.sceneHelper().scene.updated()
      
    # Reactively change visibility of the grid.
    @meshCanvas.autorun =>
      return unless grid = @grid()

      grid.visible = @meshCanvas.planeGridEnabled()
      @meshCanvas.sceneHelper().scene.updated()

    # Match orientation to normal.
    zero = new THREE.Vector3
    up = new THREE.Vector3 0, 1, 0
    right = new THREE.Vector3 1, 0, 0

    @meshCanvas.autorun (computation) =>
      return unless grid = @grid()
      
      coplanarPoint = new THREE.Vector3()

      if cluster = @meshCanvas.currentClusterHelper().cluster()
        polyhedronCluster = cluster.layer.object.solver.clusters[cluster.id]
        polyhedronCluster.getPlane().coplanarPoint coplanarPoint

      normal = @meshCanvas.paintHelper.normal()

      plane = new THREE.Plane().setFromNormalAndCoplanarPoint normal, coplanarPoint

      planeZero = new THREE.Vector3()
      plane.projectPoint zero, planeZero

      # Note: We use right to align the grid at the poles since
      # there the normal and up get very close and unpredictable.
      grid.matrix.lookAt zero, plane.normal, if Math.abs(plane.normal.y) > 0.99 then right else up

      # Move the grid slightly above the cluster to prevent Z-fighting.
      grid.matrix.setPosition planeZero.add plane.normal.clone().multiplyScalar 0.001
      grid.matrix.decompose grid.position, grid.quaternion, grid.scale

      @meshCanvas.sceneHelper().scene.updated()
