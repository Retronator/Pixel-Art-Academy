AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.SceneManager
  constructor: (@journalsView) ->
    @scene = new AE.ReactiveWrapper null

    # Initialize components.
    scene = new THREE.Scene()
    @scene scene
