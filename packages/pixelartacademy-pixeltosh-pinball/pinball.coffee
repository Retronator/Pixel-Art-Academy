AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
PAA = PixelArtAcademy

_cursorIntersectionPoints = []
_cursorRaycaster = new THREE.Raycaster
_cursorPosition = new THREE.Vector3

class PAA.Pixeltosh.Programs.Pinball extends PAA.Pixeltosh.Program
  # cameraDisplayType: enum whether the camera should be perspective or orthographic
  # debugPhysics: boolean whether to show debug view of the playfield
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
    @gameManager = new ReactiveField null
    @mouse = new ReactiveField null
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    @partsData = new ReactiveField [
      type: @constructor.Parts.BallSpawner.id()
      id: Random.id()
      position:
        x: 173.5 * pixelSize
        y: 175.5 * pixelSize
    ,
      type: @constructor.Parts.Playfield.id()
      id: Random.id()
      position:
        x: 90 * pixelSize
        y: 100 * pixelSize
    ,
      type: @constructor.Parts.Wall.id()
      id: Random.id()
      position:
        x: 90 * pixelSize
        y: 100 * pixelSize
    ,
      type: @constructor.Parts.Plunger.id()
      id: Random.id()
      position:
        x: 173.5 * pixelSize
        y: 189.5 * pixelSize
    ,
      type: @constructor.Parts.Flipper.id()
      id: Random.id()
      position:
        x: 66.5 * pixelSize
        y: 176.5 * pixelSize
      maxAngleDegrees: -39.5
    ,
      type: @constructor.Parts.Flipper.id()
      id: Random.id()
      position:
        x: 103.5 * pixelSize
        y: 176.5 * pixelSize
      flipped: true
      maxAngleDegrees: 39.5
    ,
      type: @constructor.Parts.GobbleHole.id()
      id: Random.id()
      position:
        x: 85 * pixelSize
        y: 90 * pixelSize
      score: 1000
    ,
      type: @constructor.Parts.Trough.id()
      id: Random.id()
      position:
        x: 85 * pixelSize
        y: 197 * pixelSize
    ]
    
    @cursorPosition = new ReactiveField new THREE.Vector3(), EJSON.equals
    
    @sceneImage = new ReactiveField null
    
    @debugPhysics = @state.field 'debugPhysics', default: false
    
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
    @gameManager new @constructor.GameManager @
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
    
    @sceneManager()?.destroy()
    @rendererManager()?.destroy()
    @physicsManager()?.destroy()
    
    @sceneManager null
    @cameraManager null
    @rendererManager null
    @physicsManager null
    @inputManager null
    @gameManager null
    @mouse null
    @sceneImage null
    
    @_macintoshPaletteSubscription.stop()
  
  update: (appTime) ->
    # Wait until the scene is initialized.
    sceneManager = @sceneManager()
    gameManager = @gameManager()

    if sceneManager.ready() and gameManager.simulationActive()
      # Update physics.
      physicsManager = @physicsManager()
      physicsManager.update appTime
      
      # Quantize position when in normal view.
      if @cameraManager().displayType() is Pinball.CameraManager.DisplayTypes.Orthographic and not @debugPhysics()
        pixelSize = Pinball.CameraManager.orthographicPixelSize
        
        for renderObject in sceneManager.renderObjects()
          originScreenX = renderObject.position.x / pixelSize
          originScreenY = renderObject.position.z / pixelSize
          
          screenX = originScreenX - renderObject.shape.bitmapOrigin.x
          screenY = originScreenY - renderObject.shape.bitmapOrigin.y
          
          integerScreenX = Math.round screenX
          integerScreenY = Math.round screenY
          
          renderObject.position.x = (integerScreenX + renderObject.shape.bitmapOrigin.x) * pixelSize
          renderObject.position.z = (integerScreenY + renderObject.shape.bitmapOrigin.y) * pixelSize
      
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
    entity.update? appTime for entity in sceneManager.entities()
    
  fixedUpdate: (elapsed) ->
    sceneManager = @sceneManager()
    entity.fixedUpdate? elapsed for entity in sceneManager.entities()

  draw: (appTime) ->
    @rendererManager()?.draw appTime
    
  menuItems: -> @constructor.Interface.createMenuItems()
  
  shortcuts: -> @constructor.Interface.createShortcuts()
