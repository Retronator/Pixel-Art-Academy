AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.RendererManager
  @RenderLayers:
    Main: 0
    PhysicsDebug: 1
    SpaceOccupationDebug: 2
    
  constructor: (@world) ->
    @renderer = new THREE.WebGLRenderer

    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @preprocessingRenderTarget = new THREE.WebGLRenderTarget 16, 16,
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    # Resize the renderer and render targets when canvas size changes.
    @world.autorun =>
      illustrationSize = @world.options.adventure.interface.illustrationSize
      width = illustrationSize.width()
      height = illustrationSize.height()

      return unless width and height

      @renderer.setSize width, height
      @preprocessingRenderTarget.setSize width, height

      if @world.isRendered()
        # Force a redraw since only then does the canvas size get updated. Note that we need to
        # call the world's draw and not just ours since world also updates the scaled pixel image.
        @world.forceUpdateAndDraw()

  draw: (appTime) ->
    sceneManager = @world.sceneManager()
    scene = sceneManager.scene()
    camera = @world.cameraManager().camera()

    camera.layers.set @constructor.RenderLayers.Main

    # Render the preprocessing step. First set the preprocessing material on all meshes.
    scene.traverse (object) =>
      # Remember if the object is supposed to be visible since we'll change it in some of the rendering steps.
      object.wasVisible = object.visible

      # In general, during additional render passes, all renderable
      # objects except meshes are visible if they are renderable.
      object.visible = true if object.isRenderable

      return unless object.isMesh

      if object.preprocessingMaterial
        object.material = object.preprocessingMaterial
        object.visible = object.wasVisible

      else
        object.visible = false

    # Render main shadow maps (opaque and transparent materials) as well
    # in this pass. This will setup shadows for further passes as well.
    @renderer.shadowMap.needsUpdate = true

    @renderer.setClearColor 0x000000, 1
    @renderer.setRenderTarget @preprocessingRenderTarget
    @renderer.render scene, camera

    # Render the color shadow maps. First set the shadow color material on all meshes.
    scene.traverse (object) =>
      return unless object.isMesh

      if object.shadowColorMaterial
        object.material = object.shadowColorMaterial
        object.visible = object.wasVisible

      else
        object.visible = false

    # Render all lights' shadow color maps.
    for directionalLight in sceneManager.directionalLights()
      @renderer.setClearColor 0xffff00, 1
      @renderer.setRenderTarget directionalLight.shadow.colorMap
      @renderer.render scene, directionalLight.shadow.camera

    # Render the opaque shadow maps. We need to hide all transparent meshes.
    scene.traverse (object) =>
      return unless object.isMesh

      if object.customDepthMaterial
        object.material = object.customDepthMaterial
        object.visible = object.wasVisible and not object.mainMaterial?.transparent

      else
        object.visible = false

    # Render all lights' opaque shadow maps.
    for directionalLight in sceneManager.directionalLights()
      @renderer.setClearColor 0xffffff, 1
      @renderer.setRenderTarget directionalLight.shadow.opaqueMap
      @renderer.render scene, directionalLight.shadow.camera

    # Reinstate main materials and object visibility.
    scene.traverse (object) =>
      object.visible = object.wasVisible

      return unless object.isMesh

      object.material = object.mainMaterial if object.mainMaterial

    # Draw debug elements that should be rendered within the depth of the scene.
    camera.layers.enable @constructor.RenderLayers.PhysicsDebug if @world.physicsDebug()
    camera.layers.enable @constructor.RenderLayers.SpaceOccupationDebug if @world.spaceOccupationDebug()

    # Render main pass.
    @renderer.setClearColor 0, 1
    @renderer.setRenderTarget null
    @renderer.render scene, camera

  destroy: ->
    @renderer.dispose()
