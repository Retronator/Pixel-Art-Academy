AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.SceneManager
  @playfieldWidth = 1 / 2 # m
  @shortPlayfieldHeight = 5 / 9 # m
  @standardPlayfieldHeight = 1 # m
  @shortPlayfieldPitchDegrees = 6.5 # degrees
  @standardPlayfieldPitchDegrees = 6.5 # degrees

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

    @ground = new THREE.Mesh new THREE.PlaneBufferGeometry(@constructor.playfieldWidth, @constructor.shortPlayfieldHeight), new THREE.MeshLambertMaterial color: 0xffffff
    @ground.position.set @constructor.playfieldWidth / 2, 0, @constructor.shortPlayfieldHeight / 2
    @ground.receiveShadow = true
    @ground.rotation.x = -Math.PI / 2
    @scene.add @ground
    
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

    # Instantiate playfield parts based on the data.
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
        
    # Add render objects to the scene.
    @renderObjects = new AE.ReactiveArray =>
      renderObject for part in @parts() when renderObject = part.avatar.getRenderObject()
    ,
      added: (renderObject) =>
        @scene.add renderObject
      
      removed: (renderObject) =>
        @scene.remove renderObject

    @ready = new ComputedField =>
      # Scene is ready when all starting parts have been initialized.
      @startingPartsHaveBeenInitialized()
    
  destroy: ->
    @renderObjects.stop()
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
    
    # Initialize the avatar.
    part.avatar.initialize partData

    # Update parts array.
    @_parts.push part
    @parts @_parts

  _removePartWithId: (partId) ->
    part = _.find @_parts, (part) => part._id is partId

    # Update parts array.
    _.pull @_parts, part
    @parts @_parts

    # Destroy the part.
    part.destroy()
