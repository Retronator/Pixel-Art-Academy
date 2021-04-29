AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.SceneManager
  constructor: (@world) ->
    scene = new THREE.Scene()
    scene.manager = @
    @scene = new AE.ReactiveWrapper scene

    @sceneObjectsAddedDependency = new Tracker.Dependency

    @meshesCache = {}

    @directionalLights = new ReactiveField []
    
    ambientLight = new THREE.AmbientLight 0xffffff, 0.5
    scene.add ambientLight

    interiorLighting = new THREE.DirectionalLight 0xffffff, 0.5

    interiorLighting.castShadow = true
    d = 20
    interiorLighting.shadow.camera.left = -d
    interiorLighting.shadow.camera.right = d
    interiorLighting.shadow.camera.top = d
    interiorLighting.shadow.camera.bottom = -d
    interiorLighting.shadow.camera.near = 0.5
    interiorLighting.shadow.camera.far = 40
    interiorLighting.shadow.mapSize.width = 4096
    interiorLighting.shadow.mapSize.height = 4096
    interiorLighting.shadow.bias = 0

    for extraShadowMap in ['opaqueMap', 'colorMap']
      interiorLighting.shadow[extraShadowMap] = new THREE.WebGLRenderTarget interiorLighting.shadow.mapSize.x, interiorLighting.shadow.mapSize.y,
        minFilter: THREE.NearestFilter
        magFilter: THREE.NearestFilter

    interiorLighting.position.set 0, 3.5, 0.4
    scene.add interiorLighting
    
    sun = new THREE.DirectionalLight 0xffffff, 1.5

    sun.castShadow = true
    d = 20
    sun.shadow.camera.left = -d
    sun.shadow.camera.right = d
    sun.shadow.camera.top = d
    sun.shadow.camera.bottom = -d
    sun.shadow.camera.near = 50
    sun.shadow.camera.far = 400
    sun.shadow.mapSize.width = 4096
    sun.shadow.mapSize.height = 4096
    sun.shadow.bias = 0

    for extraShadowMap in ['opaqueMap', 'colorMap']
      sun.shadow[extraShadowMap] = new THREE.WebGLRenderTarget sun.shadow.mapSize.x, sun.shadow.mapSize.y,
        minFilter: THREE.NearestFilter
        magFilter: THREE.NearestFilter
        
    sun.position.set 100, 100, 100
    scene.add sun

    @directionalLights [interiorLighting, sun]

    # Apply uniforms to new objects when they get added.
    @world.autorun (computation) =>
      return unless uniforms = @getUniforms()
      @sceneObjectsAddedDependency.depend()

      scene.traverse (object) =>
        return unless object.mainMaterial?.uniforms and not object.mainMaterial.uniformsInitialized
        object.mainMaterial.uniformsInitialized = true

        @_applyUniformsToMaterial uniforms, object.mainMaterial

    # Apply uniforms to all objects when uniforms change.
    @world.autorun (computation) =>
      return unless uniforms = @getUniforms()

      scene.traverse (object) =>
        return unless object.mainMaterial?.uniforms

        @_applyUniformsToMaterial uniforms, object.mainMaterial

      @scene.updated()

    # Add location mesh.
    @_currentLocationMesh = null
    @_currentLocationMeshDependency = new Tracker.Dependency
    @_currentIllustrationName = null
    
    @currentLocationMeshData = new ReactiveField null

    @illustration = new ComputedField =>
      @world.options.adventure.currentSituation()?.illustration()
    ,
      EJSON.equals

    @world.autorun (computation) =>
      illustration = @illustration()
      illustrationName = illustration?.name or null
      meshData = LOI.Assets.Mesh.findInCache name: illustrationName

      # Only react to illustration and mesh changes.
      Tracker.nonreactive =>
        cameraAngle = =>
          return unless illustration and @_currentLocationMesh
          cameraAngles = @_currentLocationMesh.options.meshData().cameraAngles

          if illustration.cameraAngle
            cameraAngles.find name: illustration.cameraAngle

          else
            cameraAngles.getFirst()

        if illustrationName is @_currentIllustrationName
          # Transition to other camera angle after illustration size has been applied.
          Tracker.afterFlush =>
            return unless newCameraAngle = cameraAngle()

            if newCameraAngle isnt @_currentCameraAngle
              @_currentCameraAngle = newCameraAngle

              @world.cameraManager().transitionToCameraAngle @_currentCameraAngle,
                duration: 3000
                easing: 'ease-in-out'
  
        else
          # Remove previous mesh.
          if @_currentLocationMesh
            @_currentIllustrationName = null
            scene.remove @_currentLocationMesh

          # Add new mesh, if the location has an illustration.
          if meshData
            @_currentIllustrationName = illustrationName
            @_currentLocationMesh = @getMesh meshData
            scene.add @_currentLocationMesh
            @addedSceneObjects()

          @_currentLocationMeshDependency.changed()

          # Initialize the camera from the camera angle.
          @_currentCameraAngle = cameraAngle()
          @world.cameraManager().setFromCameraAngle @_currentCameraAngle if @_currentCameraAngle

          # Report we have new mesh data.
          @currentLocationMeshData meshData

    @locationThings = new AE.ReactiveArray (=> @world.options.adventure.currentLocationThings()),
      added: (thing) =>
        # Look if the thing's avatar has a render object.
        return unless renderObject = thing.avatar.getRenderObject?()

        if thing instanceof LOI.Character.Person
          actions = thing.recentActions()

          move = _.findLast actions, (action) => action.type is LOI.Memory.Actions.Move.type

          if move?.content?.coordinates
            renderObject.position.copy move.content.coordinates

        # Add it to the scene.
        scene.add renderObject
        @addedSceneObjects()

      removed: (thing) =>
        # Remove thing's render object.
        return unless renderObject = thing.avatar.getRenderObject?()
        scene.remove renderObject
        @scene.updated()

    # Map thing avatars to objects.
    @world.autorun (computation) =>
      @_currentLocationMeshDependency.depend()
      return unless objects = @_currentLocationMesh?.objects()
      return unless locationThings = @world.options.adventure.currentLocationThings()
      return unless illustrationName = @illustration()?.name

      for thing in locationThings
        if thingIllustration = thing.illustration()
          continue unless thingIllustration.mesh is illustrationName
          continue unless object = _.find objects, (object) => object.data.name() is thingIllustration.object
          object.avatar = thing.avatar

      @scene.updated()

    @physicalItems = new ComputedField =>
      renderObjectsWithPhysics = @getAllChildren (item) => item.parentItem?.getPhysicsObject
      renderObjectWithPhysics.parentItem for renderObjectWithPhysics in renderObjectsWithPhysics

    @sceneItemsReady = new ComputedField =>
      illustration = @illustration()

      if illustration?.name
        # Depend on location mesh changes.
        @_currentLocationMeshDependency.depend()

        return unless @_currentLocationMesh?.ready()

      if locationThings = @world.options.adventure.currentLocationThings()
        for thing in locationThings
          renderObject = thing.avatar.getRenderObject?()
          return if renderObject?.ready and not renderObject.ready()

      true

  destroy: ->
    @locationThings.stop()

  getMesh: (meshData) ->
    # Returned cached version, if available.
    return @meshesCache[meshData._id] if @meshesCache[meshData._id]

    # Initialize mesh data, since it's a rich document, and create an engine mesh based on the data.
    meshData.initialize()

    @meshesCache[meshData._id] = new LOI.Assets.Engine.Mesh
      meshData: => meshData
      sceneManager: @
      objectVisibility: (objectName) =>
        return unless locationThings = @world.options.adventure.currentLocationThings()

        for thing in locationThings
          if thingIllustration = thing.illustration()
            return true if thingIllustration.mesh is meshData.name and thingIllustration.object is objectName

        null

    @meshesCache[meshData._id]

  getMeshObject: (illustrationName, objectName) ->
    return unless illustrationName is @illustration()?.name
    return unless objects = @_currentLocationMesh?.objects()

    @sceneObjectsAddedDependency.changed()

    _.find objects, (object) => object.data.name() is objectName

  getAllChildren: (filterParameter) ->
    filter = _.filterFunction filterParameter
    scene = @scene.withUpdates()

    children = []

    addAllChildren = (item) ->
      children.push item if filter item
      addAllChildren child for child in item.children

    addAllChildren scene
    children

  getUniforms: ->
    return unless rendererManager = @world.rendererManager()

    illustrationSize = @world.options.adventure.interface.illustrationSize
    directionalLights = @directionalLights()

    renderSize: new THREE.Vector2 illustrationSize.width(), illustrationSize.height()
    directionalOpaqueShadowMap: (directionalLight.shadow.opaqueMap.texture for directionalLight in directionalLights)
    directionalShadowColorMap: (directionalLight.shadow.colorMap.texture for directionalLight in directionalLights)
    preprocessingMap: rendererManager.preprocessingRenderTarget.texture
    smoothShading: LOI.settings.graphics.smoothShading.value()
    smoothShadingQuantizationFactor: (LOI.settings.graphics.smoothShadingQuantizationLevels.value() or 1) - 1

  addedSceneObjects: ->
    @sceneObjectsAddedDependency.changed()
    @scene.updated()

  _applyUniformsToMaterial: (uniforms, material) ->
    for uniform, value of uniforms
      if material.uniforms[uniform]
        material.uniforms[uniform].value = value
        material.needsUpdate = true
