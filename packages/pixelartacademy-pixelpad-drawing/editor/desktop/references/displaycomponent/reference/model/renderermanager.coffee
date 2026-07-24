AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Model = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model

class Model.RendererManager
  constructor: (@reference) ->
    @renderer = new THREE.WebGLRenderer
      antialias: true
    
    Model.Helpers.configureRenderer THREE, @renderer
    
    @_rendererUpdatedDependency = new Tracker.Dependency
    
    # Resize the renderer when viewport size changes.
    @reference.autorun =>
      return unless viewportSize = @reference.viewportSize()
      @renderer.setSize viewportSize.width, viewportSize.height
      @_rendererUpdatedDependency.changed()

    # Update exposure from the reference.
    @reference.autorun =>
      Model.Helpers.applyRendererDisplayOptions @renderer, @reference.data().displayOptions
      @_rendererUpdatedDependency.changed()

  destroy: ->
    @renderer.dispose()
    @renderer.forceContextLoss()

  startRendering: ->
    new Promise (resolve) =>
      # Start the reactive redraw routine.
      @reference.autorun =>
        # Render when renderer changes.
        @_rendererUpdatedDependency.depend()

        # Render after scene is ready.
        sceneManager = @reference.sceneManager()
        return unless sceneManager.ready()
        scene = sceneManager.scene.withUpdates()

        cameraManager = @reference.cameraManager()
        camera = cameraManager.camera.withUpdates()

        @renderer.render scene, camera

        unless firstRenderDone
          firstRenderDone = true
          resolve()
