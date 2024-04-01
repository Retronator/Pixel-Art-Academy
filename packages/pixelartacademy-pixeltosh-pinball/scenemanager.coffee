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
    
    @debugAmbientLight = new THREE.AmbientLight
    @debugAmbientLight.intensity = 0.5
    @debugAmbientLight.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
    @scene.add @debugAmbientLight

    @debugDirectionalLight = new THREE.DirectionalLight
    @debugDirectionalLight.intensity = 0.5
    @debugDirectionalLight.position.set -0.25, 1, -0.5
    @debugDirectionalLight.castShadow = true
    @debugDirectionalLight.shadow.normalBias = -0.0001
    @debugDirectionalLight.shadow.mapSize.x = 4096
    @debugDirectionalLight.shadow.mapSize.y = 4096
    @debugDirectionalLight.shadow.camera.left = -0.75
    @debugDirectionalLight.shadow.camera.right = 0.75
    @debugDirectionalLight.shadow.camera.top = 0.75
    @debugDirectionalLight.shadow.camera.bottom = -0.75
    @debugDirectionalLight.shadow.camera.near = 0.5
    @debugDirectionalLight.shadow.camera.far = 1.5
    @debugDirectionalLight.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
    @scene.add @debugDirectionalLight
    
    @debugPointLight = new THREE.PointLight
    @debugPointLight.intensity = 0.5
    @debugPointLight.position.set @constructor.playfieldWidth / 2, 0.3, @constructor.shortPlayfieldHeight / 2
    @debugPointLight.castShadow = true
    @debugPointLight.shadow.mapSize.x = 4096
    @debugPointLight.shadow.mapSize.y = 4096
    @debugPointLight.shadow.camera.near = 0.1
    @debugPointLight.shadow.camera.far = 0.5
    @debugPointLight.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
    @scene.add @debugPointLight
    
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
        
    # Detect ball Y coordinate.
    @_ballSpawner = new Pinball.Parts.BallSpawner @pinball

    @ballPositionY = new AE.LiveComputedField =>
      return unless bitmap = @_ballSpawner.bitmap()
      pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation bitmap
      shape = Pinball.Part.Avatar.Sphere.detectShape pixelArtEvaluation, {}
      pixelArtEvaluation.destroy()
      shape?.positionY() or 0.0135
    
  destroy: ->
    @renderObjects.stop()
    part.destroy() for part in @_parts
    @_ballSpawner.destroy()
    @_ballSpawnerPixelArtEvaluation.destroy()
    @ballPositionY.stop()
    
  getPart: (playfieldPartId) ->
    _.find @parts(), (part) => part.playfieldPartId is playfieldPartId

  getPartOfType: (partType) ->
    _.find @parts(), (part) => part instanceof partType

  _addPart: (playfieldPartId, partData) ->
    partClass = _.thingClass partData.type
    part = new partClass @pinball, playfieldPartId

    # Do any extra initialization logic (after the avatar is created in the constructor).
    part.initialize()

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
