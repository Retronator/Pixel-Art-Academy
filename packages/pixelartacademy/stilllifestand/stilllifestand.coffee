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

    @itemsData = @state.field 'items'

    @autorun (computation) =>
      # Wait for items data to have been loaded.
      return unless LOI.adventureInitialized()
      computation.stop()

      return if @itemsData()?.length

      @itemsData [
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/bowl-1.glb'
          mass: 2.5
        reflectionsRenderOffset:
          y: 0.1
        position:
          x: 0, y: 0.1, z: 0
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/banana.glb'
          mass: 0.1
        position:
          x: -0.4, y: 0.025, z: 0
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/apple-green.glb'
          mass: 0.08
        position:
          x: -0.6, y: 0.5, z: 0
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/apple-green-half.glb'
          mass: 0.04
        position:
          x: -0.6, y: 0.5, z: 0.2
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/kiwi.glb'
          mass: 0.05
        position:
          x: -0.8, y: 0.5, z: 0
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/kiwi-half.glb'
          mass: 0.05
        position:
          x: -0.8, y: 0.5, z: 0.2
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/blueberry.glb'
          mass: 0.007
        position:
          x: -1.1, y: 0.5, z: 0
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/blueberry.glb'
          mass: 0.007
        position:
          x: -1.1, y: 0.5, z: 0.2
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/blueberry.glb'
          mass: 0.007
        position:
          x: -1.1, y: 0.5, z: 0.4
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/blueberry-leaf.glb'
          mass: 0.005
          dragMultiplier: 40
        position:
          x: -1, y: 0.5, z: 0
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/blueberry-leaf.glb'
          mass: 0.005
          dragMultiplier: 40
        position:
          x: -1, y: 0.5, z: 0.2
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/watermelon.glb'
          mass: 5
        position:
          x: 0.2, y: 0.5, z: 0.7
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Model'
        properties:
          path: '/pixelartacademy/stilllifestand/items/orange-half.glb'
          mass: 0.05
        position:
          x: 0.4, y: 0.5, z: 0.2
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ,
        id: Random.id()
        type: 'PixelArtAcademy.StillLifeStand.Item.Box'
        properties:
          size:
            x: 2, y: 1, z: 2
          mass: 10
        position:
          x: 0, y: 0.5, z: -1.3
        rotationQuaternion:
          x: 0, y: 0, z: 0, w: 1
      ]

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

    for itemData in itemsData
      item = _.find items, (item) => item.data.id is itemData.id
      itemData.position = item.renderObject.position.toObject()
      itemData.rotationQuaternion = item.renderObject.quaternion.toObject()

    @itemsData itemsData

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

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

            else if searchObject instanceof @constructor.Item.RenderObject
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

  onMouseLeave: (event) ->
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
