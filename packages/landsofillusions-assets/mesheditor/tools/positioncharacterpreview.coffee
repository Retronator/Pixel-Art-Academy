AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PositionCharacterPreview extends LOI.Assets.MeshEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Tools.PositionCharacterPreview'
  @displayName: -> "Position character preview"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @positionCharacter()

  onMouseMove: (event) ->
    super arguments...

    @positionCharacter()

  positionCharacter: ->
    return unless @mouseState.leftButton

    meshCanvas = @editor()

    canvasCoordinate = meshCanvas.mouse().canvasCoordinate()
    raycaster = meshCanvas.renderer.cameraManager.getRaycaster x: canvasCoordinate.x - 0.5, y: canvasCoordinate.y - 0.5

    # Pick also debug meshes (wireframe).
    raycaster.layers.enable 3

    # Update debug ray to show this pick.
    meshCanvas.debugRay().set raycaster.ray.origin, raycaster.ray.direction

    scene = meshCanvas.sceneHelper().scene()
    intersections = raycaster.intersectObjects scene.children, true

    # Find the first cluster.
    for intersection in intersections when intersection.object.parent instanceof LOI.Assets.Engine.Mesh.Object.Layer.Cluster
      # Set character preview to clicked position.
      characterPreviewHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CharacterPreview
      characterPreviewHelper.setPosition intersection.point

      # Turn the character towards the camera.
      camera = @editor().renderer.cameraManager.camera().main
      characterPreviewHelper.setDirection new THREE.Vector3().subVectors camera.position, intersection.point

      return
