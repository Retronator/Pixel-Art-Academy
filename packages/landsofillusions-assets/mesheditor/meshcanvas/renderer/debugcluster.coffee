AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.DebugCluster
  constructor: (@renderer) ->
    meshCanvas = @renderer.meshCanvas

    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene

    @clusterImage = new THREE.Mesh new THREE.PlaneGeometry()
    @clusterImage.material.side = THREE.DoubleSide
    @clusterImage.material.transparent = true
    scene.add @clusterImage

    meshCanvas.autorun (computation) =>
      return unless picture = meshCanvas.activePicture()
      return unless pictureBounds = picture.bounds()

      return unless currentClusterHelper = meshCanvas.currentClusterHelper()
      return unless currentCluster = currentClusterHelper.cluster()
      return unless clusterBoundsInPicture = currentCluster.boundsInPicture()

      # Calculate bounds in absolute coordinates.
      bounds =
        x: pictureBounds.x + clusterBoundsInPicture.x
        y: pictureBounds.y + clusterBoundsInPicture.y
        width: clusterBoundsInPicture.width
        height: clusterBoundsInPicture.height

      # Position cluster in correct place.
      @clusterImage.scale.x = bounds.width
      @clusterImage.scale.y = bounds.height
      @clusterImage.position.x = bounds.x + bounds.width / 2
      @clusterImage.position.y = bounds.y + bounds.height / 2
      @clusterImage.position.z = -1

      # Set cluster radiance map to material.
      sceneCluster = currentClusterHelper.getSceneCluster()
      if radianceState = sceneCluster?.radianceState()
        @clusterImage.material.map = radianceState.radianceAtlas.out.texture
        @clusterImage.material.needsUpdate = true

      @scene.updated()
