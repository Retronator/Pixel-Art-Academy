AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.SceneManager
  constructor: (@stillLifeStand) ->
    @scene = new THREE.Scene()
    @scene.manager = @

    # Create lighting.
    @ambientLight = new THREE.AmbientLight 0x151820, 0.2
    @scene.add @ambientLight

    @directionalLight = new THREE.DirectionalLight 0xa59e88, 0.1
    @directionalLight.position.set -120, 40, 60
    @directionalLight.castShadow = true
    @directionalLight.shadow.mapSize.width = 4096
    @directionalLight.shadow.mapSize.height = 4096
    @scene.add @directionalLight

    @skydome = new LOI.Engine.Skydome
      resolution: 4096
      generateCubeTexture: true

    @scene.add @skydome

    @ground = new THREE.Mesh new THREE.PlaneBufferGeometry(1000, 1000), new THREE.MeshPhysicalMaterial
      color: 0x606060
      envMap: @skydome.cubeTexture
      roughness: 0.9
      metalness: 0
      reflectivity: 0.1

    @ground.receiveShadow = true
    @ground.rotation.x = -Math.PI / 2
    @scene.add @ground

    @_items = []
    @items = new ReactiveField @_items

    # Instantiate still life items based on the data.
    @stillLifeStand.autorun =>
      remainingItemIds = (item.id for item in @_items)

      newItemsData = @stillLifeStand.itemsData()

      sceneItemsChanged = false

      for newItemData in newItemsData
        if newItemData.id in remainingItemIds
          # Item has already been instantiated. See if its properties have changed.
          item = _.find @_items, (item) => item.id is newItemData.id

          unless EJSON.equals newItemData.properties, item.data.properties
            # Replace item with a new instance.
            @_removeItemWithId item.id
            @_addItem newItemData
            sceneItemsChanged = true

          _.pull remainingItemIds, newItemData.id

        else
          # This is a new item. Instantiate it and add it to the scene.
          @_addItem newItemData
          sceneItemsChanged = true

      # Any leftover remaining items have been removed.
      for itemId in remainingItemIds
        @_removeItemWithId itemId
        sceneItemsChanged = true

      # Update items array if any items were added or removed.
      if sceneItemsChanged
        @items @_items

    # Create debug scene.
    @debugScene = new THREE.Scene

    @cursor = new THREE.Mesh new THREE.SphereBufferGeometry(0.05), new THREE.MeshBasicMaterial color: 0xdddd00
    @debugScene.add @cursor

  destroy: ->
    item.destroy() for item in @_items
    @skydome.destroy()

  _addItem: (itemData) ->
    itemClass = PAA.StillLifeStand.Item.getClassForId itemData.type
    item = new itemClass itemData

    item.renderObject.material.envMap = @skydome.cubeTexture
    item.renderObject.material.roughness = 0.9
    item.renderObject.material.metalness = 0
    item.renderObject.material.reflectivity = 0.1

    @_items.push item
    @scene.add item.renderObject

  _removeItemWithId: (itemId) ->
    item = _.find @_items, (item) => item.id is itemId
    _.pull @_items, item
    @scene.remove item.renderObject
    item.destroy()
