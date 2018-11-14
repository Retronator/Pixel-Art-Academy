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
    d = 10
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

    plane = new THREE.Mesh new THREE.PlaneGeometry(7, 7), new THREE.MeshLambertMaterial(color: 0xcccccc)
    plane.position.y = -0.95
    plane.rotation.x = -Math.PI / 2
    plane.receiveShadow = true
    scene.add plane

    box = new THREE.Mesh new THREE.BoxGeometry(1, 1, 1), new THREE.MeshLambertMaterial(color: 0xcccccc, shadowSide: THREE.DoubleSide)
    box.position.x = 2
    box.position.y = -0.5
    box.receiveShadow = true
    box.castShadow = true
    scene.add box

    box = new THREE.Mesh new THREE.BoxGeometry(3, 2, 1), new THREE.MeshLambertMaterial(color: 0xcccccc, shadowSide: THREE.DoubleSide)
    box.position.x = -1
    box.position.z = -1.5
    box.position.y = 0
    box.receiveShadow = true
    box.castShadow = true
    scene.add box

    @locationThings = new AE.ReactiveArray (=> @world.options.adventure.currentLocationThings()),
      added: (thing) =>
        # Look if the thing's avatar has a render object.
        return unless renderObject = thing.avatar.getRenderObject?()

        if thing instanceof LOI.Character.Person
          actions = thing.recentActions()

          move = _.findLast actions, (action) => action.type is LOI.Memory.Actions.Move.type

          if move.content.coordinates
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
