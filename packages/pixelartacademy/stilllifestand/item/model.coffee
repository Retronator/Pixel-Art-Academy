AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_vector3 = new Ammo.btVector3

class PAA.StillLifeStand.Item.Model extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Model'
  @initialize()

  constructor: ->
    super arguments...

    @loader = new THREE.GLTFLoader

    dracoLoader = new THREE.DRACOLoader
    dracoLoader.setDecoderPath '/artificialengines/everywhere/three/draco/'
    @loader.setDRACOLoader dracoLoader

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

    @loader.load @data.properties.path, (data) =>
      # Initialize the physics object with the collision mesh.
      collisionMesh = _.find data.scene.children, (child) => child.name.toLowerCase().includes 'collision'
      _.pull data.scene.children, collisionMesh
      @physicsObject.initialize collisionMesh

      # Assume the remaining mesh to be the one to render.
      @renderObject.initialize data.scene.children[0]

      # Signal that we have finished initialization and the model can be added to the scene.
      @options.onInitialized @

  class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
    initialize: (@mesh) ->
      # Create physical material with our maps.
      @material = new THREE.MeshPhysicalMaterial

      for mapName in ['map', 'normalMap', 'roughnessMap']
        @material[mapName] = @mesh.material[mapName]
        @material[mapName].wrapS = THREE.ClampToEdgeWrapping
        @material[mapName].wrapT = THREE.ClampToEdgeWrapping

      @mesh.material = @material

      @geometry = @mesh.geometry

      @mesh.receiveShadow = true
      @mesh.castShadow = true

      @add @mesh

  class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
    initialize: (@collisionObject) ->
      super arguments...

    createCollisionShape: ->
      if @collisionObject instanceof THREE.Mesh
        # We have a single convex hull shape.
        @createConvexHullShape @collisionObject

      else
        # We have a compound object.
        compoundShape = new Ammo.btCompoundShape

        for child in @collisionObject.children
          childTransform = new Ammo.btTransform Ammo.btQuaternion.identity,
            child.geometry.boundingSphere.center.toBulletVector3()

          childConvexHullShape = @createConvexHullShape child, child.geometry.boundingSphere.center
          compoundShape.addChildShape childTransform, childConvexHullShape

        compoundShape

    createConvexHullShape: (mesh, center) ->
      vertexArray = mesh.geometry.attributes.position.array
      convexHullShape = new Ammo.btConvexHullShape

      for vertexOffset in [0...vertexArray.length] by 3
        _vector3.setX vertexArray[vertexOffset] - (center?.x or 0)
        _vector3.setY vertexArray[vertexOffset + 1] - (center?.y or 0)
        _vector3.setZ vertexArray[vertexOffset + 2] - (center?.z or 0)

        recalculateLocalAABB = vertexOffset is vertexArray.length - 3

        convexHullShape.addPoint _vector3, recalculateLocalAABB

      convexHullShape.setMargin mesh.userData?.margin ? PAA.StillLifeStand.Item.roughEdgeMargin
      convexHullShape
