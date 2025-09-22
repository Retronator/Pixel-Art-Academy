AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.RendererManager
  constructor: (@reference) ->
    @renderer = new THREE.WebGLRenderer
      antialias: true
    
    @renderer.outputEncoding = THREE.LinearEncoding
    @renderer.toneMapping = THREE.ACESFilmicToneMapping
    
    @_rendererUpdatedDependency = new Tracker.Dependency
    
    # Resize the renderer when viewport size changes.
    @reference.autorun =>
      return unless viewportSize = @reference.viewportSize()
      @renderer.setSize viewportSize.width, viewportSize.height
      @_rendererUpdatedDependency.changed()

    # Update exposure from the reference.
    @reference.autorun =>
      exposureValue = @reference.data().displayOptions?.exposureValue or 0
      @renderer.toneMappingExposure = 2 ** exposureValue
      @_rendererUpdatedDependency.changed()

  destroy: ->
    @renderer.dispose()
    @renderer.forceContextLoss()

  startRendering: ->
    # Start the reactive redraw routine.
    @reference.autorun =>
      # Render when renderer changes.
      @_rendererUpdatedDependency.depend()

      # Render when scene or camera changes.
      scene = @reference.sceneManager().scene.withUpdates()
      camera = @reference.cameraManager().camera.withUpdates()

      @renderer.render scene, camera
