AS = Artificial.Spectrum
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
    @mouse = new ReactiveField null

    @renderedImage = new ReactiveField null

    @$world = new ReactiveField null

  onCreated: ->
    super arguments...

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    # Initialize components.
    @sceneManager new @constructor.SceneManager @
    @cameraManager new @constructor.CameraManager @

    rendererManager = new @constructor.RendererManager @
    @rendererManager rendererManager

    @renderedImage new AM.PixelImage
      image: rendererManager.renderer.domElement

    @audioManager new @constructor.AudioManager @

    @mouse new @constructor.Mouse @

  onRendered: ->
    super arguments...

    @$world @$('.landsofillusions-engine-world')
    @display = @callAncestorWith 'display'

    # Do initial forced update and draw.
    @forceUpdateAndDraw()

    if @constructor.textureDebug
      @autorun (computation) =>
        @$('.engine-texture')[0].src = LOI.character()?.avatar.textureDataUrl()

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

  update: (appTime) ->
    return if @options.updateMode is @constructor.UpdateModes.Hover and not @_hovering

    @_update appTime

  _update: (appTime) ->
    for sceneItem in @sceneManager().scene().children when sceneItem instanceof AS.RenderObject
      sceneItem.update? appTime

  draw: (appTime) ->
    return if @options.updateMode is @constructor.UpdateModes.Hover and not @_hovering    

    @_draw appTime

  _draw: (appTime) ->
    return unless rendererManager = @rendererManager()

    rendererManager.draw appTime
    @renderedImage().update()

  events: ->
    super(arguments...).concat
      'mouseenter canvas': @onMouseEnterCanvas
      'mousemove canvas': @onMouseMoveCanvas
      'mouseleave canvas': @onMouseLeaveCanvas
      'click canvas': @onClickCanvas
      
  onMouseEnterCanvas: (event) ->
    @_hovering = true

  onMouseMoveCanvas: (event) ->
    viewportCoordinate = @mouse().viewportCoordinate()

    percentageX = viewportCoordinate.x * 4
    percentageY = viewportCoordinate.y + 1

    @sceneManager().setLightDirection -percentageX, -percentageY, -1

  onMouseLeaveCanvas: (event) ->
    @_hovering = false

    @sceneManager().setLightDirection -1, -1, -1

    @forceUpdateAndDraw()

  onClickCanvas: (event) ->
    viewportCoordinate = @mouse().viewportCoordinate()
    scene = @sceneManager().scene()
    camera = @cameraManager().camera()

    raycaster = new THREE.Raycaster
    raycaster.setFromCamera viewportCoordinate, camera

    intersects = raycaster.intersectObjects scene.children
    return unless intersects.length

    # Create move memory action.
    type = LOI.Memory.Actions.Move.type
    situation = LOI.adventure.currentSituationParameters()
    LOI.Memory.Action.do type, LOI.characterId(), situation,
      coordinates: intersects[0].point.toObject()
