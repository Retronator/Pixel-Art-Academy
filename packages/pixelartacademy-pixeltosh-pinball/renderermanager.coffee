AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.RendererManager
  @RenderLayers:
    Main: 0
    PhysicsDebug: 1
  
  @orthographicWidth = 180 # px
  @perspectiveWidth = 320 # px
  
  @height = 200 # px
  
  @orthographicAspectRatio = @orthographicWidth / @height
  @perspectiveAspectRatio = @perspectiveWidth / @height

  constructor: (@pinball) ->
    @skipFrame = false
    
    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'

    @renderer.setClearColor new THREE.Color 0xffffff

    @_sizeAutorun = @pinball.autorun =>
      scale = if @pinball.debugPhysics() then @pinball.os.display.scale() * 2 else 1
      
      switch @pinball.cameraManager()?.displayType()
        when Pinball.CameraManager.DisplayTypes.Orthographic
          @renderer.setSize @constructor.orthographicWidth * scale, @constructor.height * scale
          
        when Pinball.CameraManager.DisplayTypes.Perspective
          @renderer.setSize @constructor.perspectiveWidth * scale, @constructor.height * scale
  
  destroy: ->
    @_sizeAutorun.stop()
    @renderer.dispose()

  draw: (appTime) ->
    if LOI.settings.graphics.slowCPUEmulation.value()
      @skipFrame = not @skipFrame
      return if @skipFrame
    
    scene = @pinball.sceneManager().scene
    camera = @pinball.cameraManager().camera()

    camera.layers.set @constructor.RenderLayers.Main
    camera.layers.set @constructor.RenderLayers.PhysicsDebug if @pinball.debugPhysics()
    
    @renderer.render scene, camera
