AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.StillLifeItems.Item.Avatar extends LOI.Adventure.Thing.Avatar
  @roughEdgeMargin: 0.001

  constructor: (thing, @properties = {}) ->
    super thing.constructor

    @thing = thing

    @initialized = new ReactiveField false

  destroy: ->
    super arguments...

    @_renderObject?.destroy()
    @_physicsObject?.destroy()

  # Note: @initialized should be set to true when initialization is completed.
  initialize: -> throw new AE.NotImplementedException "You must initialize render and physics objects."

  getRenderObject: ->
    return @_renderObject if @_renderObject

    @initialize()
    @_renderObject

  getPhysicsObject: ->
    return @_physicsObject if @_physicsObject

    @initialize()
    @_physicsObject

  class @RenderObject extends AS.RenderObject
    constructor: (@avatar) ->
      super arguments...

    renderReflections: (renderer, scene) ->
      unless @cubeCamera
        @cubeCameraRenderTarget = new THREE.WebGLCubeRenderTarget 256,
          format: THREE.RGBAFormat
          type: THREE.FloatType
          stencilBuffer: false

        @cubeCamera = new THREE.CubeCamera 0.001, 1000, @cubeCameraRenderTarget

      @visible = false
      @cubeCamera.position.copy @position

      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      renderer.shadowMap.needsUpdate = true
      @cubeCameraRenderTarget.clear renderer
      @cubeCamera.update renderer, scene

      @visible = true

      @material.envMap = @cubeCamera.renderTarget.texture

  class @PhysicsObject extends AR.PhysicsObject
    constructor: (@avatar) ->
      super arguments...

      @dragObjects = []

    addDragObject: (dragObject) ->
      if size = dragObject.size
        dragFactors =
          x: @_calculateDragFactors size.x, size.y, size.z
          y: @_calculateDragFactors size.y, size.x, size.z
          z: @_calculateDragFactors size.z, size.y, size.x

        dragObject.linearDragFactor ?= new THREE.Vector3 dragFactors.x.linear, dragFactors.y.linear, dragFactors.z.linear
        dragObject.angularDragFactor ?= new THREE.Vector3 dragFactors.x.angular, dragFactors.y.angular, dragFactors.z.angular

      @dragObjects.push dragObject

    _calculateDragFactors: (height, width, depth) ->
      area = width * depth
      dragCoefficient = 1 / (((height ** 2) / (width * depth)) + 1)
      linearDragFactor = area * dragCoefficient

      longerSide = Math.max width, depth
      shorterSide = Math.min width, depth
      angularArea = longerSide * height
      angularDragCoefficient = 1 / ((shorterSide / longerSide) + 1)
      angularDragFactor = (longerSide / 2) ** 3 * angularArea * angularDragCoefficient

      linear: linearDragFactor
      angular: angularDragFactor

    initialize: ->
      transform = new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3
      @motionState = new Ammo.btDefaultMotionState transform

      @mass = @avatar.properties.mass ? 1
      @localInertia = new Ammo.btVector3 0, 0, 0
      @collisionShape = @createCollisionShape()
      @collisionShape.calculateLocalInertia @mass, @localInertia

      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody bodyInfo

      @body.setRestitution @avatar.properties.restitution or 0.6
      @body.setFriction @avatar.properties.friction or 0.8
      @body.setRollingFriction @avatar.properties.rollingFriction or 0.05
