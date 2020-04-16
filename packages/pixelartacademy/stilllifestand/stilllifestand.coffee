AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_cursorIntersectionPoints = []
_cursorRaycaster = new THREE.Raycaster
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
        mass: 3
      position:
        x: -0.6, y: 0.2, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Sphere'
      properties:
        radius: 0.05
        mass: 1
      position:
        x: -0.4, y: 0.2, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Box'
      properties:
        size:
          x: 0.1, y: 0.2, z: 0.3
        mass: 3
      position:
        x: -0.2, y: 0.2, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Box'
      properties:
        size:
          x: 0.15, y: 0.15, z: 0.15
        mass: 3
      position:
        x: 0, y: 0.2, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Cone'
      properties:
        radius: 0.1
        height: 0.3
        mass: 2
      position:
        x: 0.2, y: 0.2, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Cylinder'
      properties:
        radius: 0.05
        height: 0.15
        mass: 2
      position:
        x: 0.4, y: 0.075, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ,
      id: Random.id()
      type: 'PixelArtAcademy.StillLifeStand.Item.Cylinder'
      properties:
        radius: 0.1
        height: 0.05
        mass: 2
      position:
        x: 0.6, y: 0.025, z: 0
      rotationQuaternion:
        x: 0, y: 0, z: 0, w: 1
    ]

    @hoveredItem = new ReactiveField null, (a, b) => a is b
    @movingItem = new ReactiveField null

    @_cursorVerticalPlane = new THREE.Plane
    @_cursorHorizontalPlane = new THREE.Plane
    @_cursorVerticalPlaneActive = true

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
        # We need to move the cursor in the movement planes. Try the vertical plane first if it's still active.
        if @_cursorVerticalPlaneActive
          _cursorRaycaster.ray.intersectPlane @_cursorVerticalPlane, _cursorPosition

        # We need to use the horizontal axis unless the vertical one is active and we are above the horizontal one.
        unless @_cursorVerticalPlaneActive and _cursorPosition.y >= -@_cursorHorizontalPlane.constant - 0.01
          @_cursorVerticalPlaneActive = false
          _cursorRaycaster.ray.intersectPlane @_cursorHorizontalPlane, _cursorPosition

        sceneManager.cursor.position.copy _cursorPosition
        physicsManager.moveItem _cursorPosition

      else
        # We need to find out what we're hovering over.
        hoveredItem = null

        # Update intersection points.
        _cursorIntersectionPoints.length = 0
        _cursorRaycaster.intersectObjects scene.children, true, _cursorIntersectionPoints

        if intersectionPoint = _cursorIntersectionPoints[0]
          # Update cursor to this intersection.
          sceneManager.cursor.position.copy intersectionPoint.point

          # See if this mesh is part of a still life item.
          searchObject = intersectionPoint.object

          while searchObject
            if searchObject instanceof @constructor.Item.RenderObject
              hoveredItem = searchObject.parentItem
              break

            searchObject = searchObject.parent

        @hoveredItem hoveredItem

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

      # Set cursor movement planes. By default we move in the horizontal plane.
      cursorPosition = @sceneManager().cursor.position
      @_cursorHorizontalPlane.setFromNormalAndCoplanarPoint new THREE.Vector3(0, 1, 0), cursorPosition

      # If camera is looking relatively sideways, we also allow lifting items.
      camera = @cameraManager().camera()
      cameraDirection = camera.position.clone().normalize()

      @_cursorVerticalPlaneActive = Math.abs(cameraDirection.y) < 0.5

      if @_cursorVerticalPlaneActive
        verticalPlaneNormal = new THREE.Vector3().copy cameraDirection
        verticalPlaneNormal.y = 0

        @_cursorVerticalPlane.setFromNormalAndCoplanarPoint verticalPlaneNormal, cursorPosition

      physicsManager = @physicsManager()
      physicsManager.startMovingItem hoveredItem, cursorPosition

      # Wire end of dragging on mouse up anywhere in the window.
      $(document).on 'mouseup.pixelartacademy-stilllifestand', =>
        $(document).off 'mouseup.pixelartacademy-stilllifestand'

        @movingItem null
        physicsManager.endMovingItem()

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
