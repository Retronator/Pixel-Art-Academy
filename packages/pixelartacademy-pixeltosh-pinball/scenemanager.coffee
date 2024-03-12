AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.SceneManager
  @playfieldWidth = 1 / 2 # m
  @shortPlayfieldHeight = 5 / 9 # m
  @standardPlayfieldHeight = 1 # m

  constructor: (@pinball) ->
    @scene = new THREE.Scene()
    @scene.manager = @

    # Create lighting.
    @ambientLight = new THREE.AmbientLight
    @scene.add @ambientLight

    @directionalLight = new THREE.DirectionalLight
    @directionalLight.position.set -0.25, 1, -0.5
    @directionalLight.castShadow = true
    @directionalLight.shadow.mapSize.width = 4096
    @directionalLight.shadow.mapSize.height = 4096
    @scene.add @directionalLight

    @ground = new THREE.Mesh new THREE.PlaneBufferGeometry(@constructor.playfieldWidth, @constructor.shortPlayfieldHeight), new THREE.MeshLambertMaterial
      color: 0xaaaaaa
    @ground.position.set @constructor.playfieldWidth / 2, 0, @constructor.shortPlayfieldHeight / 2
    @ground.receiveShadow = true
    @ground.rotation.x = -Math.PI / 2
    @scene.add @ground
    
    pixelSize = Pinball.CameraManager.pixelSize
    
    sphereRadius = 0.0135
    @sphere = new THREE.Mesh new THREE.SphereGeometry(sphereRadius), new THREE.MeshLambertMaterial
      color: 0xaa0000
    
    @sphere.receiveShadow = true
    @sphere.castShadow = true
    @sphere.position.set pixelSize * 30, sphereRadius, pixelSize * 30
    @scene.add @sphere
    
    @sphere = new THREE.Mesh new THREE.SphereGeometry(0.25), new THREE.MeshLambertMaterial
      color: 0x00aa00

    @_parts = []
    @parts = new ReactiveField @_parts

    @_partsById = {}

    @startingPartsHaveBeenInitialized = new ReactiveField false

    # Notify when all starting parts have been initialized.
    @pinball.autorun (computation) =>
      # Wait until all parts in the data have been added.
      return unless @pinball.partsData()?.length is @parts().length
      computation.stop()

      @startingPartsHaveBeenInitialized true

    # Instantiate still life parts based on the data.
    @pinball.autorun =>
      remainingPartIds = (part._id for part in @_parts)

      return unless newPartsData = @pinball.partsData()

      for newPartData in newPartsData
        if newPartData.id in remainingPartIds
          # Part has already been instantiated.
          _.pull remainingPartIds, newPartData.id

        else
          # This is a new part. Instantiate it and add it to the scene.
          @_addPart newPartData

      # Any leftover remaining parts have been removed.
      for partId in remainingPartIds
        @_removePartWithId partId

    @ready = new ComputedField =>
      # Scene is ready when all starting parts have been initialized.
      @startingPartsHaveBeenInitialized()
    
  destroy: ->
    part.destroy() for part in @_parts

  _addPart: (partData) ->
    partClass = _.thingClass partData.type

    if partData.type is partData.id
      # If no special ID is given, we have a unique part.
      part = new partClass

    else
      # Otherwise we need to get the specific copy for the ID.
      part = partClass.getCopyForId partData.id

    @_partsById[partData.id] = part

    # Initialize the avatar and wait for it to complete.
    part.avatar.initialize()

    Tracker.autorun (computation) =>
      return unless part.avatar.initialized()
      computation.stop()

      # Do not complete initialization if it was canceled.
      return if part._initializationCanceled

      # Update parts array.
      @_parts.push part
      @parts @_parts

      # Set physics state.
      physicsObject = part.avatar.getPhysicsObject()
      physicsObject.setPosition partData.position if partData.position
      physicsObject.setRotation partData.rotationQuaternion if partData.rotationQuaternion

      # Add render object to the scene.
      renderObject = part.avatar.getRenderObject()
      @scene.add renderObject

  _removePartWithId: (partId) ->
    part = _.find @_parts, (part) => part._id is partId

    unless part
      # If we couldn't find the part it's probably still loading.
      if @_partsById[partId]
        @_partsById[partId]._initializationCanceled = true
        @_partsById[partId].destroy()

      else
        console.error "Playfield part to be removed hasn't been added.", partId

      return

    # Update parts array.
    _.pull @_parts, part
    @parts @_parts

    # Remove render object from the scene.
    @scene.remove part.avatar.getRenderObject()
    part.destroy()
