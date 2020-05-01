AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item
  @roughEdgeMargin: 0.001

  @_itemClassesById = {}

  @getClassForId: (id) ->
    @_itemClassesById[id]

  @id: -> throw new AE.NotImplementedException "You must specify still life item's id."

  @initialize: ->
    # Store item class by ID.
    @_itemClassesById[@id()] = @

  constructor: (@data, @options) ->

  destroy: ->
    @renderObject.destroy()
    @physicsObject.destroy()

  class @RenderObject extends AS.RenderObject
    constructor: (@parentItem) ->
      super arguments...

  class @PhysicsObject extends AR.PhysicsObject
    constructor: (@parentItem) ->
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
      positionData = @parentItem.data.position or x: 0, y: 0, z: 0
      position = Ammo.btVector3.fromObject positionData

      rotationQuaternionData = @parentItem.data.rotationQuaternion or x: 0, y: 0, z: 0, w: 0
      rotationQuaternion = Ammo.btQuaternion.fromObject rotationQuaternionData

      transform = new Ammo.btTransform rotationQuaternion, position
      @motionState = new Ammo.btDefaultMotionState transform

      @mass = @parentItem.data.properties.mass ? 1
      @localInertia = new Ammo.btVector3 0, 0, 0
      @collisionShape = @createCollisionShape()
      @collisionShape.calculateLocalInertia @mass, @localInertia

      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody bodyInfo

      @body.setRestitution @parentItem.data.properties.restitution or 0.6
      @body.setFriction @parentItem.data.properties.friction or 0.8
      @body.setRollingFriction @parentItem.data.properties.rollingFriction or 0.05
