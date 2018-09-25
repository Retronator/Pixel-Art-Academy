LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Grid extends THREE.LineSegments
  constructor: (@meshCanvas, @gridEnabled) ->
    geometry = new THREE.BufferGeometry

    # We create a unit grid from -10 to 10. That's 21 lines in
    # each direction and each line has 2 vertices (start and end).
    elementsPerVertex = 3
    elementsPerLine = elementsPerVertex * 2

    verticesArray = new Float32Array 21 * 2 * elementsPerLine
    horizontalVerticesArray = verticesArray.subarray 21 * elementsPerLine

    for i in [0..20]
      x = -10 + i

      verticesArray[i * elementsPerLine] = x
      verticesArray[i * elementsPerLine + 1] = -10
      verticesArray[i * elementsPerLine + 3] = x
      verticesArray[i * elementsPerLine + 4] = 10

      horizontalVerticesArray[i * elementsPerLine] = -10
      horizontalVerticesArray[i * elementsPerLine + 1] = x
      horizontalVerticesArray[i * elementsPerLine + 3] = 10
      horizontalVerticesArray[i * elementsPerLine + 4] = x

    geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, 3

    material = new THREE.LineBasicMaterial color: 0xeeeeee

    super geometry, material

    @rotation.set Math.PI / 2, 0, 0

    @meshCanvas.sceneManager().scene().add @

    if @gridEnabled
      # Reactively change visibility of the grid.
      @meshCanvas.autorun =>
        @visible = @gridEnabled()
        @meshCanvas.sceneManager().scene.updated()
