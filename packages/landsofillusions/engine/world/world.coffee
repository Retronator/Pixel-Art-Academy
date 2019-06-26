AC = Artificial.Control
AS = Artificial.Spectrum
AR = Artificial.Reality
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World extends AM.Component
  @register 'LandsOfIllusions.Engine.World'

  @textureDebug = false
  
  @UpdateModes:
    Realtime: 'Realtime'
    Hover: 'Hover'

  constructor: (@options) ->
    super arguments...

    # Prepare all reactive fields.
    @rendererManager = new ReactiveField null
    @sceneManager = new ReactiveField null
    @cameraManager = new ReactiveField null
    @audioManager = new ReactiveField null
    @physicsManager = new ReactiveField null

    @mouse = new ReactiveField null
    
    @navigator = new ReactiveField null

    @$world = new ReactiveField null

    @physicsDebug = new ReactiveField false
    @spaceOccupationDebug = new ReactiveField false

  onCreated: ->
    super arguments...

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    # Initialize components.
    @sceneManager new @constructor.SceneManager @
    @cameraManager new @constructor.CameraManager @

    rendererManager = new @constructor.RendererManager @
    @rendererManager rendererManager

    # HACK: In Safari we need to manually upscale the rendered image.
    if AM.Browser.isSafari()
      @renderedImage = new AM.PixelImage
        image: rendererManager.renderer.domElement

    @audioManager new @constructor.AudioManager @
    @physicsManager new @constructor.PhysicsManager @

    @mouse new @constructor.Mouse @
    
    @navigator new @constructor.Navigator @

  onRendered: ->
    super arguments...

    @$world @$('.landsofillusions-engine-world')
    @display = @callAncestorWith 'display'

    # Do initial forced update and draw.
    @forceUpdateAndDraw()

    # Add the WebGL canvas directly to DOM unless we're manually upscaling it.
    unless @renderedImage
      @$('.landsofillusions-engine-world').append @rendererManager().renderer.domElement

    if @constructor.textureDebug
      @autorun (computation) =>
        @$('.engine-texture')[0].src = LOI.character()?.avatar.getRenderObject().debugTextureDataUrl()

  forceUpdateAndDraw: ->
    appTime = Tracker.nonreactive => @app.appTime()
    @_update appTime
    @_draw appTime

  onDestroyed: ->
    super arguments...

    @app.removeComponent @

    @rendererManager().destroy()
    @sceneManager().destroy()

  onScroll: (scrollTop) ->
    @$world().css transform: "translate3d(0, #{-scrollTop / 2}px, 0)"

  getPositionVector: (source) ->
    if _.isString source
      # See if the source is a name of a thing in the scene.
      if thingClass = _.thingClass source
        thing = LOI.adventure.getCurrentThing thingClass
        thing.avatar.getRenderObject().position

      else
        # See if we have a landmark with this name.
        mesh = @sceneManager().currentLocationMeshData()
        
        if mesh.getLandmarkByName source
          mesh.getLandmarkPositionVector source

        else #if cluster = mesh.getClusterByName source
          # TODO: Get a random location on the cluster.
          x = (Math.random() - 0.5) * 15
          y = 0
          z = (Math.random() - 0.5) * 10

          new THREE.Vector3 x, y, z

    else if source.position
      source.position

    else if source.avatar
      source.avatar.getRenderObject().position
      
    else
      THREE.Vector3.fromObject source

  findEmptySpace: (item, position) ->
    @navigator().spaceOccupation.findEmptySpace item, position

  update: (appTime) ->
    return if @options.updateMode is @constructor.UpdateModes.Hover and not @_hovering

    # Don't update when you can't see the game world.
    return unless @worldIsVisible()

    @_update appTime

  worldIsVisible: ->
    @options.adventure.interface.illustrationSize.height()

  _update: (appTime) ->
    @navigator()?.update appTime
    @physicsManager()?.update appTime

    for sceneItem in @sceneManager().scene().children when sceneItem instanceof AS.RenderObject
      sceneItem.update? appTime

  draw: (appTime) ->
    return if @options.updateMode is @constructor.UpdateModes.Hover and not @_hovering

    # Don't draw when you can't see the game world.
    return unless @worldIsVisible()

    @_draw appTime

  _draw: (appTime) ->
    return unless rendererManager = @rendererManager()

    rendererManager.draw appTime
    @renderedImage?.update()

  events: ->
    super(arguments...).concat
      'mouseenter canvas': @onMouseEnterCanvas
      'mouseleave canvas': @onMouseLeaveCanvas
      'click canvas': @onClickCanvas
      
  onMouseEnterCanvas: (event) ->
    @_hovering = true

  onMouseLeaveCanvas: (event) ->
    @_hovering = false
    @forceUpdateAndDraw()

  onClickCanvas: (event) ->
    displayCoordinate = @mouse().displayCoordinate()
    illustrationSize = @options.adventure.interface.illustrationSize
    scene = @sceneManager().scene()

    return unless raycaster = @cameraManager().getRaycaster(
      x: displayCoordinate.x - illustrationSize.width() / 2
      y: displayCoordinate.y - illustrationSize.height() / 2
    )

    intersects = raycaster.intersectObjects scene.children, true
    return unless intersects.length

    keyboardState = AC.Keyboard.getState()

    if keyboardState.isKeyDown AC.Keys.shift
      point = intersects[0].point

    else
      point = _.last(intersects).point

    if keyboardState.isKeyDown AC.Keys.leftMeta
      newObject = new LOI.Engine.Debug.DummySceneItem.Ball point, 0.5

    else if keyboardState.isKeyDown AC.Keys.rightMeta
      newObject = new LOI.Engine.Debug.DummySceneItem.Box point, 0.5

    else
      # Create move memory action.
      type = LOI.Memory.Actions.Move.type
      situation = LOI.adventure.currentSituationParameters()
      LOI.Memory.Action.do type, LOI.characterId(), situation,
        coordinates: _.last(intersects).point.toObject()

    if newObject
      sceneManager = @sceneManager()
      sceneManager.scene().add newObject.renderObject
      sceneManager.scene.updated()
