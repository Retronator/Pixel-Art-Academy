AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.RendererManager
  constructor: (@world) ->
    @renderer = new THREE.WebGLRenderer

    @renderer.setClearColor new THREE.Color 0x222222
    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.type = THREE.BasicShadowMap

    # Resize the renderer when canvas size changes.
    @world.autorun =>
      illustrationSize = LOI.adventure.interface.illustrationSize

      @renderer.setSize illustrationSize.width(), illustrationSize.height()

  draw: (appTime) ->
    scene = @world.sceneManager().scene()
    camera = @world.cameraManager().camera()

    @renderer.render scene, camera

  destroy: ->
    @renderer.dispose()
