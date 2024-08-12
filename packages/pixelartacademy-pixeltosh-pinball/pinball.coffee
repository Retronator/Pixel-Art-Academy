AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
FM = FataMorgana
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

_cursorRaycaster = new THREE.Raycaster
_rayEnd = new THREE.Vector3

class PAA.Pixeltosh.Programs.Pinball extends PAA.Pixeltosh.Program
  # cameraDisplayType: enum whether the camera should be perspective or orthographic
  # debugPhysics: boolean whether to show debug view of the playfield
  # slowMotion: boolean whether to progress the simulation in slow motion
  # displayWalls: boolean whether to display the walls part
  # ballTravelExtents: how far any ball has traveled, used for task completion
  #   x, y, z:
  #     min, max: the minimum and maximum value in the given axis
  # highScore: the highest amount of points scored in a single game
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
  
  @resetBallExtents: ->
    ballExtents =
      x: {min: Number.POSITIVE_INFINITY, max: Number.NEGATIVE_INFINITY}
      y: {min: Number.POSITIVE_INFINITY, max: Number.NEGATIVE_INFINITY}
      z: {min: Number.POSITIVE_INFINITY, max: Number.NEGATIVE_INFINITY}
    
    @state 'ballTravelExtents', ballExtents
    
    ballExtents
    
  constructor: ->
    super arguments...
    
    # Prepare all reactive fields.
    @rendererManager = new ReactiveField null
    @sceneManager = new ReactiveField null
    @cameraManager = new ReactiveField null
    @physicsManager = new ReactiveField null
    @inputManager = new ReactiveField null
    @gameManager = new ReactiveField null
    @editorManager = new ReactiveField null
    @mouse = new ReactiveField null
    
    @openedFile = new ReactiveField null
    
    @projectId = new AE.LiveComputedField =>
      return unless file = @openedFile()
      file.data()
      
    # Try to load the project from content in case it's not the player's project.
    @autorun (computation) =>
      return unless projectId = @projectId()
      PAA.Practice.Project.forId.subscribeContent projectId
    
    @autorun (computation) =>
      return unless projectId = @projectId()
      return unless PAA.Practice.Project.documents.findOne projectId
      PAA.Practice.Project.assetsForProjectId.subscribeContent projectId
    
    @partsData = new AE.LiveComputedField =>
      return unless projectId = @projectId()
      return unless project = PAA.Practice.Project.documents.findOne projectId
      project.playfield
    
    @debugPhysics = @state.field 'debugPhysics', default: false
    @slowMotion = @state.field 'slowMotion', default: false
    @displayWalls = @state.field 'displayWalls', default: true
  
    @sceneImage = new ReactiveField null
    
  destroy: ->
    super arguments...
    
    @partsData.stop()
    @projectId.stop()
    
  getPartData: (playfieldPartId) ->
    @partsData()?[playfieldPartId]
  
  load: (file) ->
    super arguments...
    
    # Reactively set the waiting cursor.
    @autorun (computation) =>
      return unless osCursor = @os.cursor()
      
      unless @sceneManager()?.ready() or not @loaded()
        osCursor.wait @
    
      else
        osCursor.endWait @
    
    file ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.PinballMachine"
      data: => AB.Router.getParameter('projectId') or AB.Router.getParameter('parameter4') or @constructor.Project.state('activeProjectId')
    
    @openFile file
    
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
    @editorManager new @constructor.EditorManager @
    @mouse new @constructor.Mouse @
    
    @sceneImage new AM.PixelImage
      display: @os.display
      image: @rendererManager().renderer.domElement
    
    # Reactively change the interface layout.
    layouts = @constructor.Interface.createLayoutsData @
    
    @autorun (computation) =>
      return unless window = @os.interface.getWindow @windowId
      window.data().set 'contentArea', layouts[@constructor.Interface.determineLayout @]
      
    # Subscribe to the macintosh palette.
    @_macintoshPaletteSubscription = LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    # Track how far the player has pushed the ball for progression purposes.
    unless @_ballTravelExtents = @state 'ballTravelExtents'
      @_ballTravelExtents = @constructor.resetBallExtents()
      
  unload: ->
    super arguments...
    
    @app.removeComponent @
    
    @sceneManager()?.destroy()
    @cameraManager()?.destroy()
    @rendererManager()?.destroy()
    @physicsManager()?.destroy()
    @inputManager()?.destroy()
    @gameManager()?.destroy()
    @editorManager()?.destroy()
    
    @sceneManager null
    @cameraManager null
    @rendererManager null
    @physicsManager null
    @inputManager null
    @gameManager null
    @editorManager null
    @mouse null
    @sceneImage null
    
    @_macintoshPaletteSubscription.stop()
    
    @os.cursor()?.endWait()
    
    @state 'ballTravelExtents', @_ballTravelExtents
    
  openFile: (file) ->
    @openedFile file
    
    # Progress gameplay.
    if file.id() is "#{PAA.Pixeltosh.Programs.Pinball.id()}.PinballMachine"
      LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine', true
      
  onBackButton: ->
    # Pressing escape returns to edit mode if edit is unlocked.
    gameManager = @gameManager()

    if gameManager.mode() isnt @constructor.GameManager.Modes.Edit and @editModeUnlocked()
      gameManager.edit()
      
      # Inform that we've handled the back button.
      true
    
  editModeUnlocked: ->
    LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawGobbleHole.getAdventureInstance().completed()
    
  update: (appTime) ->
    # Update physics.
    return unless physicsManager = @physicsManager()
    physicsManager.update appTime
    
    gameManager = @gameManager()
    sceneManager = @sceneManager()
    cameraManager = @cameraManager()
    editorManager = @editorManager()
    
    # Quantize position when in normal view.
    if cameraManager.displayType() is Pinball.CameraManager.DisplayTypes.Orthographic and not @debugPhysics()
      for renderObject in sceneManager.renderObjects()
        continue unless shape = renderObject.entity.shape()
        continue unless shape.positionSnapping()
        
        @constructor.CameraManager.snapShapeToPixelPosition shape, renderObject.position, renderObject.getRotationQuaternionForSnapping(), renderObject.lastPosition
      
    # Update the hovered part.
    hoveredPart = null
    
    if viewportCoordinates = @mouse().viewportCoordinates()
      camera = cameraManager.camera()

      # Update the raycaster.
      _cursorRaycaster.setFromCamera viewportCoordinates, camera
      _cursorRaycaster.ray.at camera.far, _rayEnd
      
      hoveredEntity = physicsManager.intersectObject _cursorRaycaster.ray.origin, _rayEnd
      hoveredPart = hoveredEntity if hoveredEntity instanceof @constructor.Part
    
    editorManager.hoveredPart hoveredPart
    
    # Update the parts.
    entities = sceneManager.entities()
    entity.update? appTime for entity in entities
    
    # Update ball extents and kill balls that go outside the playfield.
    for entity in entities when entity instanceof Pinball.Ball
      ball = entity
      ballRenderObject = ball.getRenderObject()
      @_ballTravelExtents.x.min = Math.min @_ballTravelExtents.x.min, ballRenderObject.position.x
      @_ballTravelExtents.x.max = Math.max @_ballTravelExtents.x.max, ballRenderObject.position.x
      @_ballTravelExtents.y.min = Math.min @_ballTravelExtents.y.min, ballRenderObject.position.y
      @_ballTravelExtents.y.max = Math.max @_ballTravelExtents.y.max, ballRenderObject.position.y
      @_ballTravelExtents.z.min = Math.min @_ballTravelExtents.z.min, ballRenderObject.position.z
      @_ballTravelExtents.z.max = Math.max @_ballTravelExtents.z.max, ballRenderObject.position.z
      
      if ballRenderObject.position.y < -1
        ball.die()
        gameManager.removeBall ball
    
  fixedUpdate: (elapsed) ->
    sceneManager = @sceneManager()
    entity.fixedUpdate? elapsed for entity in sceneManager.entities()

  draw: (appTime) ->
    @rendererManager()?.draw appTime
    
  menuItems: -> @constructor.Interface.createMenuItems()
  
  shortcuts: -> @constructor.Interface.createShortcuts()
