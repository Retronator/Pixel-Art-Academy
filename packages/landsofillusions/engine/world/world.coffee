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

    @_cursorIntersectionPoints = []
    @cursorIntersectionPoints = new ReactiveField @_cursorIntersectionPoints

    @avatarUnderCursor = new ReactiveField null, (a, b) => a is b

    @navigator = new ReactiveField null

    @$world = new ReactiveField null

    @physicsDebug = new ReactiveField false
    @spaceOccupationDebug = new ReactiveField false

    @_raycaster = new THREE.Raycaster

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
    Tracker.nonreactive =>
      appTime = @app.appTime()
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
        return unless thing = LOI.adventure.getCurrentThing thingClass
        return unless thing.avatar.getRenderObject()?.position

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

    # Update avatar under cursor if the cursor is in the window. We need to do
    # this even if the mouse is not moving since the objects underneath might be.
    @_updateCursorIntersectionPoints() if @_hovering

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

    # Clear cursor intersection points.
    @_cursorIntersectionPoints.length = 0
    @_cursorIntersectionPointsUpdated()

  onClickCanvas: (event) ->
    return unless @_cursorIntersectionPoints.length

    keyboardState = AC.Keyboard.getState()

    if keyboardState.isKeyDown AC.Keys.shift
      point = @_cursorIntersectionPoints[0].point

    else
      point = _.last(@_cursorIntersectionPoints).point

    if keyboardState.isKeyDown AC.Keys.leftMeta
      newObject = new LOI.Engine.Debug.DummySceneItem.Ball point, 0.5

    else if keyboardState.isKeyDown AC.Keys.rightMeta
      newObject = new LOI.Engine.Debug.DummySceneItem.Box point, 0.5

    if newObject
      sceneManager = @sceneManager()
      sceneManager.scene().add newObject.renderObject
      sceneManager.addedSceneObjects()

      # HACK: We need to force recomputation for scene to apply uniforms to the
      # new object. Otherwise render draw will run before the recomputation.
      Tracker.flush()

  _updateCursorIntersectionPoints: ->
    return unless displayCoordinate = @mouse().displayCoordinate()
    illustrationSize = @options.adventure.interface.illustrationSize
    scene = @sceneManager().scene()

    @cameraManager().updateRaycaster(@_raycaster,
      x: displayCoordinate.x - illustrationSize.width() / 2
      y: displayCoordinate.y - illustrationSize.height() / 2
    )

    # Clear current intersected objects.
    @_cursorIntersectionPoints.length = 0

    # Update intersection points.
    @_raycaster.intersectObjects scene.children, true, @_cursorIntersectionPoints
    @_cursorIntersectionPointsUpdated()

  _cursorIntersectionPointsUpdated: ->
    @cursorIntersectionPoints @_cursorIntersectionPoints

    # Update avatar as well.
    @_updateAvatarUnderCursor()

  _updateAvatarUnderCursor: ->
    # Find any avatars we're hovering over from front to back.
    for point in @_cursorIntersectionPoints
      # See if this mesh is part of a render object with an avatar.
      searchObject = point.object

      while searchObject
        if searchObject.avatar
          @avatarUnderCursor searchObject.avatar
          return

        searchObject = searchObject.parent

    # We couldn't find any objects with avatars.
    @avatarUnderCursor null
