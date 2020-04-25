AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.SceneManager
  constructor: (@stillLifeStand) ->
    @scene = new THREE.Scene()
    @scene.manager = @

    # Create lighting.
    @ambientLight = new THREE.AmbientLight
    @scene.add @ambientLight

    @directionalLight = new THREE.DirectionalLight
    @directionalLight.position.set -20, 100, 60
    @directionalLight.castShadow = true
    @directionalLight.shadow.mapSize.width = 4096
    @directionalLight.shadow.mapSize.height = 4096
    @scene.add @directionalLight

    @skydome = new LOI.Engine.Skydome
      generateCubeTexture: true
      readColors: true

    @scene.add @skydome

    @ground = new THREE.Mesh new THREE.PlaneBufferGeometry(1000, 1000), new THREE.MeshPhysicalMaterial
      color: 0x606060
      envMap: @skydome.cubeTexture
      roughness: 1
      metalness: 0
      reflectivity: 0
      dithering: true

    @ground.receiveShadow = true
    @ground.rotation.x = -Math.PI / 2
    @scene.add @ground

    @_items = []
    @items = new ReactiveField @_items

    # Instantiate still life items based on the data.
    @stillLifeStand.autorun =>
      remainingItemIds = (item.id for item in @_items)

      newItemsData = @stillLifeStand.itemsData()

      for newItemData in newItemsData
        if newItemData.id in remainingItemIds
          # Item has already been instantiated. See if its properties have changed.
          item = _.find @_items, (item) => item.id is newItemData.id

          unless EJSON.equals newItemData.properties, item.data.properties
            # Replace item with a new instance.
            @_removeItemWithId item.id
            @_addItem newItemData

          _.pull remainingItemIds, newItemData.id

        else
          # This is a new item. Instantiate it and add it to the scene.
          @_addItem newItemData

      # Any leftover remaining items have been removed.
      for itemId in remainingItemIds
        @_removeItemWithId itemId

    # Create debug scene.
    @debugScene = new THREE.Scene

    @cursor = new THREE.Mesh new THREE.SphereBufferGeometry(0.05), new THREE.MeshBasicMaterial color: 0xdddd00
    @debugScene.add @cursor

    @skydomeReadColorQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(), new THREE.MeshBasicMaterial
      map: @skydome.readColorsRenderTarget.texture

    @skydomeReadColorQuad.position.y = 1
    @skydomeReadColorQuad.scale.x = 2
    @debugScene.add @skydomeReadColorQuad

    # Create sun helper.
    @sunHelper = new THREE.Mesh new THREE.SphereBufferGeometry(100)
    @sunHelper.visible = false
    @scene.add @sunHelper

  destroy: ->
    item.destroy() for item in @_items
    @skydome.destroy()

  _addItem: (itemData) ->
    itemClass = PAA.StillLifeStand.Item.getClassForId itemData.type

    new itemClass itemData, onInitialized: (item) =>
      # Do not complete initialization if it was canceled.
      return if item._initializationCanceled

      # Update items array.
      @_items.push item
      @items @_items

      # Set material properties.
      item.renderObject.material.envMap = @skydome.cubeTexture
      item.renderObject.material.roughness = 1
      item.renderObject.material.metalness = 0
      item.renderObject.material.reflectivity = 0
      item.renderObject.material.dithering = true

      # Add render object to the scene.
      @scene.add item.renderObject

  _removeItemWithId: (itemId) ->
    item = _.find @_items, (item) => item.id is itemId

    unless item
      # If we couldn't find the item it's probably still loading.
      console.log "canceling"
      item._initializationCanceled = true
      item.destroy()
      return

    # Update items array.
    _.pull @_items, item
    @items @_items

    # Remove render object from the scene.
    @scene.remove item.renderObject
    item.destroy()
