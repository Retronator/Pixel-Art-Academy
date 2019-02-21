AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.RendererManager
  constructor: (@world) ->
    @renderer = new THREE.WebGLRenderer

    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.type = THREE.BasicShadowMap

    # Resize the renderer when canvas size changes.
    @world.autorun =>
      illustrationSize = @world.options.adventure.interface.illustrationSize

      @renderer.setSize illustrationSize.width(), illustrationSize.height()

      if @world.isRendered()
        # Force a redraw since only then does the canvas size get updated. Note that we need to
        # call the world's draw and not just ours since world also updates the scaled pixel image.
        @world.forceUpdateAndDraw()

  draw: (appTime) ->
    scene = @world.sceneManager().scene()
    camera = @world.cameraManager().camera()

    @renderer.render scene, camera

  destroy: ->
    @renderer.dispose()
