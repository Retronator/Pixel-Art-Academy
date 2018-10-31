AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Engine.World.CameraManager
  constructor: (@world) ->
    @_camera = new THREE.PerspectiveCamera 90, 1, 0.1, 1000
    @camera = new AE.ReactiveWrapper @_camera

    @_camera.position.y = 0.5
    @_camera.position.z = 2.7

    @world.autorun (computation) =>
      illustrationSize = @world.options.adventure.interface.illustrationSize

      @_camera.aspect = illustrationSize.width() / illustrationSize.height()
      @_camera.updateProjectionMatrix()

      @camera.updated()
