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

    @ground = new THREE.Mesh new THREE.PlaneBufferGeometry(1000, 1000), new THREE.MeshPhysicalMaterial
      color: 0xaaaaaa
      roughness: 1
      metalness: 0
      reflectivity: 0
      dithering: true

    @skydome = new LOI.Engine.Skydome.Procedural
      generateCubeTexture: true
      readColors: true
      dithering: true

    @scene.add @skydome
    @scene.environment = @skydome.cubeTexture

    @ground.receiveShadow = true
    @ground.rotation.x = -Math.PI / 2
    @scene.add @ground

    @_items = []
    @items = new ReactiveField @_items

    @_itemsById = {}

    @startingItemsHaveBeenInitialized = new ReactiveField false

    # Notify when all starting items have been initialized.
    @stillLifeStand.autorun (computation) =>
      # Wait for items data to have been loaded.
      return unless LOI.adventureInitialized()

      # Wait until all items in the data have been added.
      return unless @stillLifeStand.itemsData().length is @items().length
      computation.stop()

      @startingItemsHaveBeenInitialized true

    # Instantiate still life items based on the data.
    @stillLifeStand.autorun =>
      remainingItemIds = (item._id for item in @_items)

      newItemsData = @stillLifeStand.itemsData()

      for newItemData in newItemsData
        if newItemData.id in remainingItemIds
          # Item has already been instantiated.
          _.pull remainingItemIds, newItemData.id

        else
          # This is a new item. Instantiate it and add it to the scene.
          @_addItem newItemData

      # Any leftover remaining items have been removed.
      for itemId in remainingItemIds
        @_removeItemWithId itemId

    @ready = new ComputedField =>
      # Scene is ready when all starting items have been initialized.
      @startingItemsHaveBeenInitialized()

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
    @sunHelper = new THREE.Mesh new THREE.SphereBufferGeometry(150)
    @sunHelper.visible = false
    @scene.add @sunHelper

  destroy: ->
    item.destroy() for item in @_items
    @skydome.destroy()

  _addItem: (itemData) ->
    itemClass = _.thingClass itemData.type

    if itemData.type is itemData.id
      # If no special ID is given, we have a unique item.
      item = new itemClass

    else
      # Otherwise we need to get the specific copy for the ID.
      item = itemClass.getCopyForId itemData.id

    @_itemsById[itemData.id] = item

    # Initialize the avatar and wait for it to complete.
    item.avatar.initialize()

    Tracker.autorun (computation) =>
      return unless item.avatar.initialized()
      computation.stop()

      # Do not complete initialization if it was canceled.
      return if item._initializationCanceled

      # Update items array.
      @_items.push item
      @items @_items

      # Set material properties.
      renderObject = item.avatar.getRenderObject()
      renderObject.material.dithering = true

      # Set physics state.
      physicsObject = item.avatar.getPhysicsObject()
      physicsObject.setPosition itemData.position if itemData.position
      physicsObject.setRotation itemData.rotationQuaternion if itemData.rotationQuaternion

      # Add render object to the scene.
      @scene.add renderObject

  _removeItemWithId: (itemId) ->
    item = _.find @_items, (item) => item._id is itemId

    unless item
      # If we couldn't find the item it's probably still loading.
      if @_itemsById[itemId]
        @_itemsById[itemId]._initializationCanceled = true
        @_itemsById[itemId].destroy()

      else
        console.error "Still life item to be removed hasn't been added.", itemId

      return

    # Update items array.
    _.pull @_items, item
    @items @_items

    # Remove render object from the scene.
    @scene.remove item.avatar.getRenderObject()
    item.destroy()
