AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_vector3 = new Ammo.btVector3

class PAA.Items.StillLifeItems.Item.Avatar.Model.Loader
  @gltfLoader = new THREE.GLTFLoader

  dracoLoader = new THREE.DRACOLoader
  dracoLoader.setDecoderPath '/artificialengines/everywhere/three/draco/'
  @gltfLoader.setDRACOLoader dracoLoader

  @models = {}

  @load: (path, onLoadHandler) ->
    # See if we've already come across this path.
    if model = @models[path]
      # See if this model was already loaded.
      if model.loaded
        # Simply pass the loaded data to the handler.
        onLoadHandler model.data

      else
        # Add the handler to the waiting list.
        model.waitingOnLoadHandlers.push onLoadHandler

      return

    # We need to start loading this model.
    model = waitingOnLoadHandlers: [onLoadHandler]
    @models[path] = model

    @gltfLoader.load path, (loadedData) =>
      model = @models[path]
      model.data = @_createModelData loadedData
      model.loaded = true

      onLoadHandler model.data for onLoadHandler in model.waitingOnLoadHandlers

  @_createModelData: (loadedData) ->
    collisionObject = _.find loadedData.scene.children, (child) => child.name.toLowerCase().includes 'collision'
    _.pull loadedData.scene.children, collisionObject

    {collisionShape, dragObjects} = @_createPhysicsData collisionObject

    # Assume the remaining mesh to be the one to render.
    renderMesh = @_createRenderMesh loadedData.scene.children[0]

    {collisionShape, dragObjects, renderMesh}

  @_createRenderMesh: (mesh) ->
    renderMesh = mesh.clone()

    # Create physical material with our maps.
    material = new THREE.MeshPhysicalMaterial

    for mapName in ['map', 'normalMap', 'roughnessMap'] when mesh.material[mapName]
      material[mapName] = mesh.material[mapName]
      material[mapName].wrapS = THREE.ClampToEdgeWrapping
      material[mapName].wrapT = THREE.ClampToEdgeWrapping

    # Transfer other properties.
    for property in ['color', 'metalness', 'reflectivity', 'roughness', 'alphaTest', 'side']
      value = mesh.material[property] ? mesh.material.userData?[property]
      continue unless value?

      if material[property].copy
        material[property].copy value

      else
        material[property] = value

    renderMesh.material = material

    renderMesh

  @_createPhysicsData: (collisionObject) ->
    if collisionObject instanceof THREE.Mesh
      # We have a single convex hull shape.
      {shape, dragObject} = @_createCollisionShapeFromMesh collisionObject, false
      collisionShape = shape
      dragObjects = [dragObject]

    else
      # We have a compound object.
      compoundShape = new Ammo.btCompoundShape
      dragObjects = []

      for child in collisionObject.children
        {shape, transform, dragObject} = @_createCollisionShapeFromMesh child
        compoundShape.addChildShape transform, shape
        dragObjects.push dragObject

      collisionShape = compoundShape

    {collisionShape, dragObjects}

  @_createCollisionShapeFromMesh: (mesh, calculateTransform = true) ->
    name = mesh.name.toLowerCase()
    if name.includes 'cylinder'
      {shape, transform} = @_createCylinderShape mesh

    else if name.includes 'ellipsoid'
      {shape, transform} = @_createEllipsoidShape mesh

    else
      {shape, transform} = @_createConvexHullShape mesh, calculateTransform

    shape.setMargin mesh.userData?.margin ? PAA.Items.StillLifeItems.Item.Avatar.roughEdgeMargin

    # Add mesh to drag objects.
    boundingBox = mesh.geometry.boundingBox
    boundingBoxSize = boundingBox.max.clone().sub boundingBox.min
    boundingBoxCenter = boundingBoxSize.clone().multiplyScalar(0.5).add boundingBox.min

    dragObject = position: boundingBoxCenter, size: boundingBoxSize

    {shape, transform, dragObject}

  @_createCylinderShape: (mesh) ->
    transform = new Ammo.btTransform mesh.quaternion.toBulletQuaternion(), mesh.position.toBulletVector3()

    # We assume the bounding box holds the extents of the cylinder.
    shape = new Ammo.btCylinderShape mesh.geometry.boundingBox.max.toBulletVector3()

    {shape, transform}

  @_createEllipsoidShape: (mesh) ->
    transform = new Ammo.btTransform mesh.quaternion.toBulletQuaternion(), mesh.position.toBulletVector3()

    # We assume the bounding box holds the extents of the ellipsoid.
    shape = new Ammo.btMultiSphereShape [new Ammo.btVector3()], [1], 1
    shape.setLocalScaling mesh.geometry.boundingBox.max.toBulletVector3()

    {shape, transform}

  @_createConvexHullShape: (mesh, calculateTransform) ->
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
