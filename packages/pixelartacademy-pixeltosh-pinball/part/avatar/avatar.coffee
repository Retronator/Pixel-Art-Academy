AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar extends LOI.Adventure.Thing.Avatar
  @roughEdgeMargin: 0.001 # m

  constructor: (thing, @properties = {}) ->
    super thing.constructor

    @thing = thing
    
    @_renderObject = new @constructor.RenderObject @
    @_physicsObject = new @constructor.PhysicsObject @

  destroy: ->
    super arguments...

    @_renderObject?.destroy()
    @_physicsObject?.destroy()
  
  createGeometry: ->
    throw new AE.NotImplementedException "Part must provide a geometry."
  
  createCollisionShape: ->
    throw new AE.NotImplementedException "Part must provide a collision shape."
    
  yPosition: ->
    throw new AE.NotImplementedException "Part must specify at which y coordinate it should appear."
  
  collisionShapeMargin: -> @constructor.roughEdgeMargin

  getRenderObject: -> @_renderObject
  getPhysicsObject: -> @_physicsObject

  class @RenderObject extends AS.RenderObject
    constructor: (@avatar) ->
      super arguments...
      
      @material = new THREE.MeshLambertMaterial
        color: 0xff0000
      
      @geometry = @avatar.createGeometry()
      
      @mesh = new THREE.Mesh @geometry, @material
      @mesh.receiveShadow = true
      @mesh.castShadow = true
      
      @add @mesh

    renderReflections: (renderer, scene) ->
      unless @cubeCamera
        @cubeCameraRenderTarget = new THREE.WebGLCubeRenderTarget 256,
          format: THREE.RGBAFormat
          type: THREE.FloatType
          stencilBuffer: false

        @cubeCamera = new THREE.CubeCamera 0.001, 10, @cubeCameraRenderTarget

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

      transform = new Ammo.btTransform Ammo.btQuaternion.identity, new Ammo.btVector3
      @motionState = new Ammo.btDefaultMotionState transform

      @mass = @avatar.properties.mass ? 1
      @localInertia = new Ammo.btVector3 0, 0, 0
      
      @collisionShape = @avatar.createCollisionShape()
      margin = @avatar.collisionShapeMargin()
      @collisionShape.setMargin margin if margin?
      @collisionShape.calculateLocalInertia @mass, @localInertia

      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody bodyInfo

      @body.setRestitution @avatar.properties.restitution or 1
      @body.setFriction @avatar.properties.friction or 0
      @body.setRollingFriction @avatar.properties.rollingFriction or 0

    setDesignPosition: (designPosition) ->
      @setPosition
        x: designPosition.x
        y: @avatar.yPosition()
        z: designPosition.y
