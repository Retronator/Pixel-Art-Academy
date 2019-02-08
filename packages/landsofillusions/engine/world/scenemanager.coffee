AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.SceneManager
  constructor: (@world) ->
    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene

    ambientLight = new THREE.AmbientLight 0xffffff, 0.4
    scene.add ambientLight

    directionalLight = new THREE.DirectionalLight 0xffffff, 0.6

    directionalLight.castShadow = true
    d = 20
    directionalLight.shadow.camera.left = -d
    directionalLight.shadow.camera.right = d
    directionalLight.shadow.camera.top = d
    directionalLight.shadow.camera.bottom = -d
    directionalLight.shadow.camera.near = 50
    directionalLight.shadow.camera.far = 400
    directionalLight.shadow.mapSize.width = 4096
    directionalLight.shadow.mapSize.height = 4096
    directionalLight.shadow.bias = -0.0001

    @directionalLight = directionalLight
    @setLightDirection -1, -1, -1

    scene.add directionalLight

    # Add location mesh.
    @_currentLocationMesh = null
    
    @world.autorun (computation) =>
      return unless illustrationName = LOI.adventure.currentLocation()?.illustration()?.name

      LOI.Assets.Asset.forName.subscribe LOI.Assets.Mesh.className, illustrationName
      return unless meshData = LOI.Assets.Mesh.documents.findOne name: illustrationName

      # Remove previous mesh.
      if @_currentLocationMesh
        scene.remove @_currentLocationMesh
        @_currentLocationMesh.destroy()
      
      # Initialize mesh data, since it's a rich document, and create an engine mesh based on the data.
      meshData.initialize()
      @_currentLocationMesh = new LOI.Assets.Engine.Mesh
        meshData: => meshData
        sceneManager: @
        
      # Initialize the camera from the camera angle.
      @world.cameraManager().setFromCameraAngle meshData.cameraAngles.get 0
      
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
        @scene.updated()

      removed: (thing) =>
        # Remove thing's render object.
        return unless renderObject = thing.avatar.getRenderObject?()
        scene.remove renderObject
        @scene.updated()

  destroy: ->
    @locationThings.stop()
    
  setLightDirection: (x, y, z) ->
    @directionalLight.position.set(x, y, z).normalize().multiplyScalar(-100)
    @directionalLight.lookAt 0, 0, 0
