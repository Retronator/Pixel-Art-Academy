AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
PAA = PixelArtAcademy

_cursorIntersectionPoints = []
_cursorRaycaster = new THREE.Raycaster
_cursorPosition = new THREE.Vector3

class PAA.Pixeltosh.Programs.Pinball extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball'
  @register @id()
  
  @version: -> '0.1.0'
  
  @fullName: -> "Pinball Creation Kit"
  @description: ->
    "
      A do-it-yourself Pinball game.
    "
  
  @slug: -> 'pinball'
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    # Prepare all reactive fields.
    @rendererManager = new ReactiveField null
    @sceneManager = new ReactiveField null
    @cameraManager = new ReactiveField null
    @physicsManager = new ReactiveField null
    @inputManager = new ReactiveField null
    @mouse = new ReactiveField null
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    @partsData = new ReactiveField [
      type: @constructor.Parts.Ball.id()
      id: Random.id()
      position:
        x: 173 * pixelSize
        y: 100 * pixelSize
    ,
      type: @constructor.Parts.Wall.id()
      id: Random.id()
      position:
        x: 0
        y: 0
    ,
      type: @constructor.Parts.Plunger.id()
      id: Random.id()
      position:
        x: 173.5 * pixelSize
        y: (197 - 30) * pixelSize
    ]
    
    @cursorPosition = new ReactiveField new THREE.Vector3(), EJSON.equals
    
    @sceneImage = new ReactiveField null
    
    @debugPhysics = new ReactiveField false
    
  load: ->
    @windowId = @os.addWindow @constructor.Interface.createInterfaceData()
    
    @app = @os.ancestorComponentOfType Artificial.Base.App
    @app.addComponent @

    # Initialize components.
    @sceneManager new @constructor.SceneManager @
    @cameraManager new @constructor.CameraManager @
    @rendererManager new @constructor.RendererManager @
    @physicsManager new @constructor.PhysicsManager @
    @inputManager new @constructor.InputManager @
    @mouse new @constructor.Mouse @
    
    @hoveredPart = new ReactiveField null
    
    @sceneImage new AM.PixelImage
      display: @os.display
      image: @rendererManager().renderer.domElement
    
    # Reactively change the interface layout.
    @autorun (computation) =>
      return unless window = @os.interface.getWindow @windowId
      window.data().set 'contentArea', @constructor.Interface.createContentAreaData @
      
    # Subscribe to the black palette.
    @_macintoshPaletteSubscription = LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
  unload: ->
    @app.removeComponent @
    
    @rendererManager()?.destroy()
    @sceneManager()?.destroy()
    @physicsManager()?.destroy()
    
    @sceneManager null
    @cameraManager null
    @rendererManager null
    @physicsManager null
    @mouse null
    @sceneImage null
    
    @_macintoshPaletteSubscription.stop()
  
  update: (appTime) ->
    # Wait until the scene is initialized.
    sceneManager = @sceneManager()

    if sceneManager.ready()
      # Update physics.
      physicsManager = @physicsManager()
      physicsManager.update appTime
      
    # Update the cursor.
    if viewportCoordinates = @mouse().viewportCoordinates()
      scene = sceneManager.scene
      camera = @cameraManager().camera()

      # Update the raycaster.
      _cursorRaycaster.setFromCamera viewportCoordinates, camera

      # We need to find out what we're hovering over.
      hoveredPart = null

      # Update intersection points.
      _cursorIntersectionPoints.length = 0
      _cursorRaycaster.intersectObjects scene.children, true, _cursorIntersectionPoints

      if intersectionPoint = _cursorIntersectionPoints[0]
        # Update cursor to this intersection.
        @cursorPosition intersectionPoint.point

        # See if this mesh is part of a playfield part.
        searchObject = intersectionPoint.object

        while searchObject
          if searchObject.avatar?.thing
            hoveredPart = searchObject.avatar.thing
            break

          searchObject = searchObject.parent

      @hoveredPart hoveredPart
      
    # Update the parts.
    part.update appTime for part in sceneManager.parts()

  draw: (appTime) ->
    @rendererManager()?.draw appTime
    
  menuItems: -> @constructor.Interface.createMenuItems()
  
  shortcuts: -> @constructor.Interface.createShortcuts()
