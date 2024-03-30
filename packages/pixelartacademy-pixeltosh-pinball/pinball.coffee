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
    @editorManager = new ReactiveField null
    @mouse = new ReactiveField null
    
    @openedFile = new ReactiveField null
    
    @projectId = new AE.LiveComputedField =>
      return unless file = @openedFile()
      file.data()
      
    @partsData = new AE.LiveComputedField =>
      return unless projectId = @projectId()
      return unless project = PAA.Practice.Project.documents.findOne projectId
      project.playfield
    
    @debugPhysics = @state.field 'debugPhysics', default: false
    @slowMotion = @state.field 'slowMotion', default: false
  
    @sceneImage = new ReactiveField null
    
  destroy: ->
    super arguments...
    
    @partsData.stop()
    @projectId.stop()
    
  getPartData: (playfieldPartId) ->
    @partsData()?[playfieldPartId]
  
  load: (file) ->
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
    @editorManager null
    @mouse null
    @sceneImage null
    
    @_macintoshPaletteSubscription.stop()
    
  openFile: (file) ->
    @openedFile file
    
    # Progress gameplay.
    if file.id() is "#{PAA.Pixeltosh.Programs.Pinball.id()}.PinballMachine"
      LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine', true
  
  update: (appTime) ->
    sceneManager = @sceneManager()
    physicsManager = @physicsManager()

    # Update physics.
    physicsManager.update appTime
    
    # Quantize position when in normal view.
    if @cameraManager().displayType() is Pinball.CameraManager.DisplayTypes.Orthographic and not @debugPhysics()
      for renderObject in sceneManager.renderObjects()
        continue unless shape = renderObject.entity.shape()
        continue unless shape.positionSnapping()
        
        @constructor.CameraManager.snapShapeToPixelPosition shape, renderObject.position, renderObject.getRotationQuaternionForSnapping()
      
    # Update the hovered part.
    hoveredPart = null
    
    if viewportCoordinates = @mouse().viewportCoordinates()
      camera = @cameraManager().camera()

      # Update the raycaster.
      _cursorRaycaster.setFromCamera viewportCoordinates, camera
      _cursorRaycaster.ray.at camera.far, _rayEnd
      
      hoveredEntity = physicsManager.intersectObject _cursorRaycaster.ray.origin, _rayEnd
      hoveredPart = hoveredEntity if hoveredEntity instanceof @constructor.Part
    
    @editorManager().hoveredPart hoveredPart
    
    # Update the parts.
    entity.update? appTime for entity in sceneManager.entities()
    
  fixedUpdate: (elapsed) ->
    sceneManager = @sceneManager()
    entity.fixedUpdate? elapsed for entity in sceneManager.entities()

  draw: (appTime) ->
    @rendererManager()?.draw appTime
    
  menuItems: -> @constructor.Interface.createMenuItems()
  
  shortcuts: -> @constructor.Interface.createShortcuts()
