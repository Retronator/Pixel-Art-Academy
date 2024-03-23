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

    # Instantiate playfield parts based on the data.
    @pinball.autorun =>
      remainingPlayfieldPartIds = (part.playfieldPartId for part in @_parts)

      return unless newPartsData = @pinball.partsData()

      for newPlayfieldPartId, newPartData of newPartsData
        if newPlayfieldPartId in remainingPlayfieldPartIds
          # Part has already been instantiated.
          _.pull remainingPlayfieldPartIds, newPlayfieldPartId

        else
          # This is a new part. Instantiate it and add it to the scene.
          Tracker.nonreactive => @_addPart newPlayfieldPartId, newPartData

      # Any leftover remaining parts have been removed.
      for newPlayfieldPartId in remainingPlayfieldPartIds
        Tracker.nonreactive => @_removePartWithId newPlayfieldPartId
        
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
    
  destroy: ->
    @renderObjects.stop()
    part.destroy() for part in @_parts
    
  getPart: (playfieldPartId) ->
    _.find @parts(), (part) => part.playfieldPartId is playfieldPartId

  _addPart: (playfieldPartId, partData) ->
    partClass = _.thingClass partData.type
    part = new partClass @pinball, playfieldPartId

    # Initialize the avatar.
    part.avatar.initialize()

    # Update parts array.
    @_parts.push part
    @parts @_parts

  _removePartWithId: (playfieldPartId) ->
    part = _.find @_parts, (part) => part.playfieldPartId is playfieldPartId

    # Update parts array.
    _.pull @_parts, part
    @parts @_parts

    Tracker.afterFlush =>
      # Destroy the part.
      part.destroy()
