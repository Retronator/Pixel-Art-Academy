AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

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

  update: (appTime) ->
    @physicsManager()?.update appTime

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

    # We should drag the blueprint if we're not dragging a goal.
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
