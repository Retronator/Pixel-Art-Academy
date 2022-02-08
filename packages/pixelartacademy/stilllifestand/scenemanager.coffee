AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.SceneManager
  constructor: (@stillLifeStand) ->
    @scene = new THREE.Scene
    @scene.manager = @

    @ground = new THREE.Mesh new THREE.PlaneBufferGeometry(2000, 2000), new THREE.MeshPhysicalMaterial
      color: 0x8899aa
      dithering: true

    @ground.layers.mask = LOI.Engine.RenderLayerMasks.NonEmissive
    @ground.receiveShadow = true
    @ground.rotation.x = -Math.PI / 2
    @scene.add @ground

    # Create lighting.
    # Note: the values 20 and 0.0013 for star/scattering factors were determined experimentally to match typical real environment maps.
    @skydome = new LOI.Engine.Skydome.Procedural
      addDirectionalLight: true
      directionalLightDistance: 100
      intensityFactors:
        star: 20
        scattering: 0.0013

    @skydome.directionalLight.castShadow = true
    @skydome.directionalLight.shadow.mapSize.width = 4096
    @skydome.directionalLight.shadow.mapSize.height = 4096

    @scene.add @skydome

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

  updateEnvironmentMap: ->
    rendererManager = @stillLifeStand.rendererManager()
    itemRenderObjects = (item.avatar.getRenderObject() for item in @items())

    # Hide all the items so we just capture the sky and the ground in the reflections.
    # Note: We don't want to put items on just the final render layer to achieve this because we want to render
    # them when rendering individual reflections on each item where they should be visible to each other.
    itemRenderObject.visible = false for itemRenderObject in itemRenderObjects
    rendererManager.renderer.shadowMap.needsUpdate = true

    # Render environment from slightly above ground.
    @scene.position.set 0, -0.1, 0

    # We need to do an extra first pass so that the ground will already have
    # the correct color when we render the environment map we'll use on the scene.
    unless @environmentMapRenderTarget
      @environmentMapRenderTarget = rendererManager.environmentMapGenerator.fromScene @scene, 0, 0.01, 1000
      @scene.environment = @environmentMapRenderTarget.texture

    # Render the environment map.
    oldEnvironmentMapRenderTarget = @environmentMapRenderTarget
    @environmentMapRenderTarget = rendererManager.environmentMapGenerator.fromScene @scene, 0, 0.01, 1000
    oldEnvironmentMapRenderTarget.dispose()

    # Reset the objects and the scene.
    for itemRenderObject in itemRenderObjects
      itemRenderObject.visible = true

      # Remove any custom environment map set by rendering individual reflections.
      itemRenderObject.material.envMap = null

    @scene.position.set 0, 0, 0

    # Activate the new environment map.
    @scene.environment = @environmentMapRenderTarget.texture
