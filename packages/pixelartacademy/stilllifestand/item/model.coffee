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
    initialize: (mesh) ->
      @mesh = mesh.clone()

      # Create physical material with our maps.
      @material = new THREE.MeshPhysicalMaterial

      for mapName in ['map', 'normalMap', 'roughnessMap'] when @mesh.material[mapName]
        @material[mapName] = @mesh.material[mapName]
        @material[mapName].wrapS = THREE.ClampToEdgeWrapping
        @material[mapName].wrapT = THREE.ClampToEdgeWrapping

      # Transfer other properties.
      for property in ['color', 'metalness', 'reflectivity', 'roughness', 'alphaTest', 'side']
        value = @mesh.material[property] ? @mesh.material.userData?[property]
        continue unless value?

        if @material[property].copy
          @material[property].copy value

        else
          @material[property] = value

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
        {shape} = @createCollisionShapeFromMesh @collisionObject, false
        shape

      else
        # We have a compound object.
        compoundShape = new Ammo.btCompoundShape

        for child in @collisionObject.children
          {shape, transform} = @createCollisionShapeFromMesh child
          compoundShape.addChildShape transform, shape

        compoundShape

    createCollisionShapeFromMesh: (mesh, calculateTransform = true) ->
      name = mesh.name.toLowerCase()
      if name.includes 'cylinder'
        {shape, transform} = @createCylinderShape mesh

      else if name.includes 'ellipsoid'
        {shape, transform} = @createEllipsoidShape mesh

      else
        {shape, transform} = @createConvexHullShape mesh, calculateTransform

      shape.setMargin mesh.userData?.margin ? PAA.StillLifeStand.Item.roughEdgeMargin

      # Add mesh to drag objects.
      boundingBox = mesh.geometry.boundingBox
      boundingBoxSize = boundingBox.max.clone().sub boundingBox.min
      boundingBoxCenter = boundingBoxSize.clone().multiplyScalar(0.5).add boundingBox.min

      @addDragObject position: boundingBoxCenter, size: boundingBoxSize

      {shape, transform}

    createCylinderShape: (mesh) ->
      transform = new Ammo.btTransform mesh.quaternion.toBulletQuaternion(), mesh.position.toBulletVector3()

      # We assume the bounding box holds the extents of the cylinder.
      shape = new Ammo.btCylinderShape mesh.geometry.boundingBox.max.toBulletVector3()

      {shape, transform}

    createEllipsoidShape: (mesh) ->
      transform = new Ammo.btTransform mesh.quaternion.toBulletQuaternion(), mesh.position.toBulletVector3()

      # We assume the bounding box holds the extents of the ellipsoid.
      shape = new Ammo.btMultiSphereShape [new Ammo.btVector3()], [1], 1
      shape.setLocalScaling mesh.geometry.boundingBox.max.toBulletVector3()

      {shape, transform}

    createConvexHullShape: (mesh, calculateTransform) ->
      if calculateTransform
        center = mesh.geometry.boundingSphere.center
        transform = new Ammo.btTransform Ammo.btQuaternion.identity, center.toBulletVector3()

      vertexArray = mesh.geometry.attributes.position.array
      shape = new Ammo.btConvexHullShape

      for vertexOffset in [0...vertexArray.length] by 3
        _vector3.setX vertexArray[vertexOffset] - (center?.x or 0)
        _vector3.setY vertexArray[vertexOffset + 1] - (center?.y or 0)
        _vector3.setZ vertexArray[vertexOffset + 2] - (center?.z or 0)

        recalculateLocalAABB = vertexOffset is vertexArray.length - 3

        shape.addPoint _vector3, recalculateLocalAABB

      {shape, transform}
