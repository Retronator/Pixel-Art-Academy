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
        
    @entities = new ComputedField =>
      return [] unless gameManager = @pinball.gameManager()
      simulationActive = gameManager.simulationActive()
      
      entities = []
      
      for part in @parts()
        continue if part instanceof Pinball.Parts.BallSpawner and simulationActive
        entities.push part
      
      if simulationActive
        entities.push gameManager.balls()...
      
      entities
      
    # Add render objects to the scene.
    @renderObjects = new AE.ReactiveArray =>
      renderObject for entity in @entities() when renderObject = entity.getRenderObject()
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
    part = new partClass @pinball, => partData

    @_partsById[partData.id] = part
    
    # Initialize the avatar.
    part.avatar.initialize()

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
