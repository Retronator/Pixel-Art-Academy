AR = Artificial.Reality
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.GalleryWest'
  @url: -> 'retronator/gallery/west'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Gallery west wing"
  @shortName: -> "gallery"
  @description: ->
    "
      You enter a gallery with huge pixel art pieces hanging on the walls. This is the permanent collection of
      artworks made by Matej 'Retro' Jan. One day you'll be able to look at them, but they're not coded into the game yet.
      The hall continues to the east wing of the gallery. Stairs continue up to the art studio.
    "

  @illustration: ->
    name: 'retronator/hq/floor3/gallery/gallery'
    cameraAngle: 'West'
    height: 120

  @initialize()

  constructor: ->
    super arguments...

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 3

  things: -> [
    @elevatorButton
    @constructor.Colliders
    @constructor.Artworks
    @constructor.Artworks.Tribute
    @constructor.Artworks.PixelChinaMountains
    @constructor.Artworks.ComputersSeries
    @constructor.Artworks.JulieSeries
    @constructor.Artworks.ZXCosmopolis
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 3
    ,
      "#{Vocabulary.Keys.Directions.East}": HQ.GalleryEast
      "#{Vocabulary.Keys.Directions.Up}": HQ.ArtStudio
      "#{Vocabulary.Keys.Directions.Down}": HQ.Store

  class @Colliders extends LOI.Adventure.Thing
    @id: -> 'Retronator.HQ.GalleryWest.Colliders'
    @fullName: -> null
    @initialize()

    isVisible: -> false
    createAvatar: -> new @constructor.Avatar

    class @Avatar extends LOI.Avatar
      constructor: ->
        super arguments...

        @renderObject = new THREE.Object3D

        addColliderBox = (halfSize, position, rotation) =>
          colliderBox = new @constructor.ColliderBox halfSize, position, rotation
          @renderObject.add colliderBox.getRenderObject()

        # Add ground.
        addColliderBox new THREE.Vector3(12.5, 1, 8), new THREE.Vector3(0, -1, 0)

        # Add walls.
        addColliderBox new THREE.Vector3(12, 4, 1), new THREE.Vector3(0, 2, 8.2)
        addColliderBox new THREE.Vector3(12, 4, 1), new THREE.Vector3(0, 2, -8.5)
        addColliderBox new THREE.Vector3(1, 4, 7.5), new THREE.Vector3(-13, 2, 0)
        addColliderBox new THREE.Vector3(1, 4, 7.5), new THREE.Vector3(13, 2, 0)

        # Add insets.
        addColliderBox new THREE.Vector3(2, 4, 1.5), new THREE.Vector3(0, 2, 6.5)
        addColliderBox new THREE.Vector3(2, 4, 1.5), new THREE.Vector3(0, 2, -6.5)
        addColliderBox new THREE.Vector3(1.5, 4, 4), new THREE.Vector3(-11.5, 2, 0)

        # Add reception table.
        addColliderBox new THREE.Vector3(1.25, 0.45, 0.35), new THREE.Vector3(10.1, 0.45, 3.4), new THREE.Euler 0, Math.PI / 4, 0

      fullName: -> null

      getRenderObject: -> @renderObject

      class @ColliderBox
        constructor: (halfSize, position, rotation) ->
          rotation ?= new THREE.Euler 0, 0, 0

          @renderObject = new THREE.Object3D
          @renderObject.parentItem = @
          @renderObject.position.copy position
          @renderObject.rotation.copy rotation

          @physicsObject = new @constructor.PhysicsObject @, halfSize, position, rotation

        getRenderObject: -> @renderObject
        getPhysicsObject: -> @physicsObject

        class @PhysicsObject extends AR.PhysicsObject
          constructor: (@parentItem, @halfSize, @position, @rotation) ->
            super arguments...

            @mass = 0
            @localInertia = new Ammo.btVector3 0, 0, 0

            @collisionShape = @createCollisionShape()

            quaternion = new THREE.Quaternion().setFromEuler @rotation
            transform = new Ammo.btTransform new Ammo.btQuaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w), new Ammo.btVector3 @position.x, @position.y, @position.z
            @motionState = new Ammo.btDefaultMotionState transform

            boxInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
            @body = new Ammo.btRigidBody boxInfo

          createGeometry: (options = {}) ->
            extrude = (options.occupationMargin or 0) + (options.extrude or 0)
            width = (@halfSize.x + extrude) * 2
            height = (@halfSize.y + extrude) * 2
            depth = (@halfSize.z + extrude) * 2

            new THREE.BoxBufferGeometry width, height, depth

          createCollisionShape: ->
            new Ammo.btBoxShape new Ammo.btVector3 @halfSize.x, @halfSize.y, @halfSize.z

          createDebugObject: (options) ->
            options = _.extend {}, options,
              debug: true

            new THREE.Mesh @createGeometry(options), options.material
