AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.CameraManager
  constructor: (@meshCanvas, @options = {}) ->
    camera = new THREE.PerspectiveCamera 90, 1, 0.001, 1000
    camera.position.set 0, 20, 20
    camera.rotation.x = -0.5
    camera.updateProjectionMatrix()

    @camera = new AE.ReactiveWrapper camera
