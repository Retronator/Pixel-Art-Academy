AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_cursorIntersectionPoints = []
_cursorRaycaster = new THREE.Raycaster
_cursorPlane = new THREE.Plane new THREE.Vector3(0, 1, 0), 0
_cursorPosition = new THREE.Vector3

class PAA.StillLifeStand extends LOI.Adventure.Item
  template: -> 'PixelArtAcademy.StillLifeStand'

  @version: -> '0.1.0'

  constructor: ->
    super arguments...

    # Prepare all reactive fields.
    @rendererManager = new ReactiveField null
    @sceneManager = new ReactiveField null
    @cameraManager = new ReactiveField null
    @physicsManager = new ReactiveField null
    @mouse = new ReactiveField null

    @itemsData = new ReactiveField [
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Sphere'
      properties:
        radius: 0.1
        mass: 4
      position:
        x: 0, y: 1.1, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Sphere'
      properties:
        radius: 0.05
        mass: 1
      position:
        x: 0.2, y: 0.6, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ]

    @hoveredItem = new ReactiveField null, (a, b) => a is b
    @movingItem = new ReactiveField null

  onCreated: ->
    super arguments...

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    # Initialize components.
    @sceneManager new @constructor.SceneManager @
    @cameraManager new @constructor.CameraManager @
    @rendererManager new @constructor.RendererManager @
    @physicsManager new @constructor.PhysicsManager @
    @mouse new @constructor.Mouse @

    # Reactively update lighting.
    @autorun (computation) =>
      renderer = @rendererManager().renderer
      sceneManager = @sceneManager()

      lightDirection = sceneManager.directionalLight.position.clone().multiplyScalar(-1)

      sceneManager.skydome.updateTexture renderer, lightDirection

  onRendered: ->
    super arguments...

    @$('.viewport-area').append @rendererManager().renderer.domElement

  onDestroyed: ->
    super arguments...

    @app.removeComponent @
    @rendererManager()?.destroy()
    @sceneManager()?.destroy()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  cursorClass: ->
    return 'grabbing' if @movingItem()
    return 'can-grab' if @hoveredItem()

    null

  update: (appTime) ->
    # Update physics.
    physicsManager = @physicsManager()
    physicsManager.update appTime

    # Update the cursor.
    if viewportCoordinates = @mouse().viewportCoordinates()
      sceneManager = @sceneManager()
      scene = sceneManager.scene
      camera = @cameraManager().camera()

      # Update the raycaster.
      _cursorRaycaster.setFromCamera viewportCoordinates, camera

      # See if we're currently moving an item.
      if @movingItem()
        # We need to move the cursor in the movement plane.
        _cursorRaycaster.ray.intersectPlane _cursorPlane, _cursorPosition
        physicsManager.cursor.setPosition _cursorPosition

      else
        # We need to find out what we're hovering over.
        hoveredItem = null

        # Update intersection points.
        _cursorIntersectionPoints.length = 0
        _cursorRaycaster.intersectObjects scene.children, true, _cursorIntersectionPoints

        if intersectionPoint = _cursorIntersectionPoints[0]
          # Update cursor to this intersection.
          physicsManager.cursor.setPosition intersectionPoint.point

          # See if this mesh is part of a still life item.
          searchObject = intersectionPoint.object

          while searchObject
            if searchObject instanceof @constructor.Item.RenderObject
              hoveredItem = searchObject.parentItem
              break

            searchObject = searchObject.parent

        @hoveredItem hoveredItem

      # Transfer cursor position from physics engine to render scene.
      physicsManager.cursor.getPositionTo _cursorPosition
      sceneManager.cursor.position.copy _cursorPosition

  draw: (appTime) ->
    @rendererManager()?.draw appTime

  events: ->
    super(arguments...).concat
      'mousedown': @onMouseDown
      'mousemove': @onMouseMove
      'mouseleave': @onMouseLeave
      'wheel': @onMouseWheel
      'contextmenu': @onContextMenu

  onMouseDown: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    # See if we're starting to move an item.
    if hoveredItem = @hoveredItem()
      @movingItem hoveredItem

      # Set movement plane to be at the height of the cursor.
      _cursorPlane.constant = @sceneManager().cursor.position.y

    else
      # We should rotate the camera instead.
      @cameraManager().startRotateCamera event.coordinates

  onMouseMove: (event) ->
    @mouse().onMouseMove event

  onMouseLeave: (event) ->
    @mouse().onMouseLeave event

  onMouseWheel: (event) ->
    @cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY

  onContextMenu: (event) ->
    # Prevent context menu opening.
    event.preventDefault()
