AE = Artificial.Everywhere
AC = Artificial.Control
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
    @inventory = new ReactiveField null

    @itemsData = @state.field 'items', default: []

    @hoveredItem = new ReactiveField null, (a, b) => a is b
    @movingItem = new ReactiveField null
    @movingSun = new ReactiveField false

    @cursorPosition = new ReactiveField new THREE.Vector3(), EJSON.equals

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
    @inventory new @constructor.Inventory @

    # Reactively update lighting.
    @autorun (computation) =>
      renderer = @rendererManager().renderer
      sceneManager = @sceneManager()
      sunPosition = sceneManager.directionalLight.position

      if @movingSun()
        # Move directional light to come from cursor direction.
        camera = @cameraManager().camera()
        cursorPosition = @cursorPosition()
        lightDirection = new THREE.Vector3().subVectors(camera.position, cursorPosition).normalize()
        sunPosition.copy(lightDirection).multiplyScalar(-100)
        sceneManager.bouncedLight.position.copy(sunPosition).negate()

      else
        # Read light direction from directional light position.
        lightDirection = sunPosition.clone().normalize().multiplyScalar(-1)

      sceneManager.skydome.updateTexture renderer, lightDirection

      # Update light colors.
      sceneManager.directionalLight.color.copy sceneManager.skydome.starColor
      sceneManager.directionalLight.intensity = sceneManager.skydome.starIntensity

      sceneManager.ambientLight.color.copy sceneManager.skydome.skyColor
      sceneManager.ambientLight.intensity = sceneManager.skydome.skyIntensity

      sceneManager.bouncedLight.color.copy(sceneManager.skydome.starColor).multiplyScalar(sceneManager.skydome.starIntensity)
      sceneManager.bouncedLight.color.add(sceneManager.skydome.skyColor.clone().multiplyScalar(sceneManager.skydome.skyIntensity))

      # Update sun helper position.
      sceneManager.sunHelper.position.copy(sunPosition).normalize().multiplyScalar(1000)

    $(document).on 'keydown.pixelartacademy-stilllifestand', (event) => @onKeyDown event

  onRendered: ->
    super arguments...

    @$('.viewport-area').append @rendererManager().renderer.domElement

  onDestroyed: ->
    super arguments...

    # Save state of items before we exit the stand.
    @_saveItemsState()

    @app.removeComponent @

    @rendererManager()?.destroy()
    @sceneManager()?.destroy()
    @physicsManager()?.destroy()

    $(document).off '.pixelartacademy-stilllifestand'

  endRun: ->
    # Save state of items if player closes the window while the stand is active.
    @_saveItemsState()

  _saveItemsState: ->
    return unless sceneManager = @sceneManager()

    itemsData = @itemsData()
    items = sceneManager.items()

    # Update position and rotation in the items data.
    for itemData in itemsData
      item = _.find items, (item) => item._id is itemData.id
      renderObject = item.avatar.getRenderObject()

      itemData.position = renderObject.position.toObject()
      itemData.rotationQuaternion = renderObject.quaternion.toObject()

    @itemsData itemsData

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  addDraggedItem: (draggedItemData) ->
    itemsData = @itemsData()

    # Make sure this item hasn't been added yet.
    itemData = _.find itemsData, (itemData) => itemData.id is draggedItemData.id
    return if itemData

    # Add the item data to the stand. We need to create a clone so that we don't modify the inventory item's data.
    itemData = _.cloneDeep draggedItemData
    itemsData.push draggedItemData
    @itemsData itemsData

    # Wait for item to get added to the scene.
    @autorun (computation) =>
      sceneManager = @sceneManager()
      items = sceneManager.items()
      item = _.find items, (item) => item._id is itemData.id
      return unless item
      computation.stop()

      # Find a point on top of the object. Render object should still be positioned at identity as the physics
      # simulation hasn't ran yet, so we can simply pick a point from far above the center of the object. We assume
      # that there is at least one triangle above the center.
      renderObject = item.avatar.getRenderObject()
      downRaycaster = new THREE.Raycaster new THREE.Vector3(0, 100, 0), new THREE.Vector3(0, -1, 0)
      intersections = downRaycaster.intersectObject renderObject, true
      return unless grabPosition = intersections[0]?.point

      # Position the cursor in a horizontal plane halfway between the ground and the camera.
      camera = @cameraManager().camera()
      @_cursorHorizontalPlane.setFromNormalAndCoplanarPoint new THREE.Vector3(0, 1, 0), new THREE.Vector3(0, camera.position.y / 2, 0)
      @_cursorVerticalPlaneActive = false

      viewportCoordinates = @mouse().viewportCoordinates()
      _cursorRaycaster.setFromCamera viewportCoordinates, camera
      _cursorRaycaster.ray.intersectPlane @_cursorHorizontalPlane, _cursorPosition

      # Place the object so that the grab position will be at the cursor.
      position = new THREE.Vector3().subVectors _cursorPosition, grabPosition

      physicsObject = item.avatar.getPhysicsObject()
      physicsObject.setPosition position

      # Start moving the item.
      @movingItem item

      physicsManager = @physicsManager()
      physicsManager.startMovingItem item, _cursorPosition

      # Wire end of dragging on mouse up anywhere in the window.
      $(document).on 'mouseup.pixelartacademy-stilllifestand', =>
        $(document).off 'mouseup.pixelartacademy-stilllifestand'

        @movingItem null
        physicsManager.endMovingItem()

  ready: ->
    conditions = [
      super arguments...
    ]

    if @isCreated()
      conditions.push @sceneManager()?.ready()

    _.every conditions

  cursorClass: ->
    return 'grabbing' if @movingItem() or @movingSun()
    return 'can-grab' if @hoveredItem()

    null

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
          @cursorPosition intersectionPoint.point
          sceneManager.cursor.position.copy intersectionPoint.point

          # See if this mesh is part of a still life item.
          searchObject = intersectionPoint.object

          while searchObject
            if searchObject is sceneManager.sunHelper
              hoveredItem = searchObject
              break

            else if searchObject.avatar?.thing
              hoveredItem = searchObject.avatar.thing
              break

            searchObject = searchObject.parent

        @hoveredItem hoveredItem

  draw: (appTime) ->
    @rendererManager()?.draw appTime

  events: ->
    super(arguments...).concat
      'mousedown canvas': @onMouseDownCanvas
      'mousemove': @onMouseMove
      'mouseleave .pixelartacademy-stilllifestand': @onMouseLeaveStillLifeStand
      'wheel': @onMouseWheel
      'contextmenu': @onContextMenu

  onMouseDownCanvas: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    # See if we're starting to move an item.
    if hoveredItem = @hoveredItem()
      sceneManager = @sceneManager()

      if hoveredItem is sceneManager.sunHelper
        @movingSun true

        # Wire end of dragging on mouse up anywhere in the window.
        $(document).on 'mouseup.pixelartacademy-stilllifestand', =>
          $(document).off 'mouseup.pixelartacademy-stilllifestand'

          @movingSun false

      else
        @movingItem hoveredItem

        # Set cursor movement planes. By default we move in the horizontal plane.
        cursorPosition = sceneManager.cursor.position
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

  onMouseLeaveStillLifeStand: (event) ->
    @mouse().onMouseLeave event

  onMouseWheel: (event) ->
    @cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY

  onContextMenu: (event) ->
    # Prevent context menu opening.
    event.preventDefault()

  onKeyDown: (event) ->
    key = event.which
    return unless key is AC.Keys.r

    sceneManager = @sceneManager()
    renderer = @rendererManager().renderer

    for item in sceneManager.items() when item.renderObject.material.reflectivity > 0.01
      item.renderObject.renderReflections renderer, sceneManager.scene
