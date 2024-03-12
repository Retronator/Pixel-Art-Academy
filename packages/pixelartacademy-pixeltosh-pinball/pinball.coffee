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
    @mouse = new ReactiveField null
    
    @partsData = @state.field 'parts', default: []
    
    @cursorPosition = new ReactiveField new THREE.Vector3(), EJSON.equals
    
    @sceneImage = new ReactiveField null
  
  load: ->
    @os.addWindow @constructor.Interface.createInterfaceData()
    
    @app = @os.ancestorComponentOfType Artificial.Base.App
    @app.addComponent @

    # Initialize components.
    @sceneManager new @constructor.SceneManager @
    @cameraManager new @constructor.CameraManager @
    @rendererManager new @constructor.RendererManager @
    @physicsManager new @constructor.PhysicsManager @
    @mouse new @constructor.Mouse @
    
    @sceneImage new AM.PixelImage
      display: @os.display
      image: @rendererManager().renderer.domElement
    
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
        sceneManager.cursor.position.copy intersectionPoint.point

        # See if this mesh is part of a playfield part.
        searchObject = intersectionPoint.object

        while searchObject
          if searchObject.avatar?.thing
            hoveredPart = searchObject.avatar.thing
            break

          searchObject = searchObject.parent

      @hoveredPart hoveredPart

  draw: (appTime) ->
    @rendererManager()?.draw appTime
    
  menuItems: -> [
    caption: ''
    items: []
  ,
    caption: 'File'
    items: [
      PAA.Pixeltosh.OS.Interface.Actions.Quit.id()
    ]
  ]
