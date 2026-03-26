AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part extends LOI.Adventure.Item
  @_partClasses = {}

  @initialize: ->
    super arguments...
    
    @_partClasses[@id()] = @
  
  @getPartClasses: -> _.values @_partClasses
  @getSelectablePartClasses: -> _.filter @getPartClasses(), (partClass) => partClass.selectable()
  @getPlaceablePartClasses: -> _.filter @getPartClasses(), (partClass) => partClass.placeable()
  @getClassForId: (id) -> @_partClasses[id]
  
  @assetId: -> # Override if this part's asset comes from the project.
  @imageUrls: -> # Override if this part's asset comes from static images.
  
  @avatarShapes: -> throw new AE.NotImplementedException  "A playfield part must specify which shapes it can have in order of preference."
  
  @avatarClass: -> Pinball.Part.Avatar # Override if the part requires a custom avatar.
  
  @selectable: -> true # Override if this part can't be selected.
  
  @placeableRequiredTask: -> null # Override if this part becomes placeable after completing a certain task.
  
  @placeable: ->
    return unless placeableRequiredTask = @placeableRequiredTask()
    placeableRequiredTask.getAdventureInstance()?.completed()
  
  constructor: (@pinball, @playfieldPartId) ->
    super arguments...
    
    # Load the bitmap asset.
    @bitmap = new ReactiveField null, (a, b) => a is b
    
    if imageUrls = @constructor.imageUrls()
      # Load static images and create a bitmap out of them.
      imageUrls = [imageUrls] unless _.isArray imageUrls
      @_loadImageAssets imageUrls
      
    else if assetId = @constructor.assetId()
      # Reactively load the bitmap asset.
      @autorun (computation) =>
        return unless project = PAA.Practice.Project.documents.findOne @pinball.projectId()
        
        if asset = _.find project.assets, (asset) => asset.id is assetId
          @bitmap LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset?.bitmapId, false
          
        else
          # Asset hasn't been added to the project yet, fallback to the default images.
          assetClass = PAA.Practice.Project.Asset.getClassForId assetId
          imageUrls = assetClass.imageUrls()
          imageUrls = [imageUrls] unless _.isArray imageUrls
          @_loadImageAssets imageUrls

    # Create reactive data for the part.
    @data = new AE.LiveComputedField =>
      data = _.clone @pinball.getPartData(@playfieldPartId) or {}
      
      for property, setting of @settings() when setting.default?
        data[property] ?= setting.default
        
      _.defaults data, @defaultData()
    ,
      EJSON.equals
    
    @shapeProperties = new AE.LiveComputedField =>
      _.defaults {}, _.pick(@data(), @shapeDataPropertyNames()), @extraShapeProperties(), @constants()
    ,
      EJSON.equals
    
    @physicsProperties = new AE.LiveComputedField =>
      _.defaults {}, _.pick(@data(), @physicsDataPropertyNames()), @extraPhysicsProperties(), @constants()
    ,
      EJSON.equals
      
    @_temporaryPosition = new ReactiveField null
    @_temporaryRotationAngle = new ReactiveField null
    
    # Reset the part whenever data changes.
    @autorun (computation) =>
      @data()
      @reset()
      
  destroy: ->
    super arguments...
    
    @data.stop()
    @shapeProperties.stop()
    @physicsProperties.stop()
    
  shapeDataPropertyNames: -> ['flipped']
  physicsDataPropertyNames: -> ['restitution', 'friction', 'rollingFriction']
  
  ready: -> @getRenderObject() and @getPhysicsObject() and @pixelArtEvaluation()
  
  shape: -> @avatar.shape()
  texture: -> @avatar.texture()
  pixelArtEvaluation: -> @avatar.pixelArtEvaluation()
  
  setTemporaryPosition: (position) ->
    @_temporaryPosition position
    @avatar.reset()
    
  position: ->
    @_temporaryPosition() or @data()?.position
    
  setTemporaryRotationAngle: (angle) ->
    @_temporaryRotationAngle angle
    @avatar.reset()
    
  rotationAngle: ->
    @_temporaryRotationAngle() ? @data()?.rotationAngle ? 0
    
  rotationQuaternion: ->
    new THREE.Quaternion().setFromEuler new THREE.Euler 0, @rotationAngle(), 0
  
  createAvatar: ->
    avatarClass = @constructor.avatarClass()
    new avatarClass @
  
  settings: -> {} # Override to supply which settings the player can change for this part.
  defaultData: -> {} # Override to supply defaults for the data (not defined through the settings).
  constants: -> {} # Override to supply constant properties to the avatar.
  extraShapeProperties: -> {} # Override to supply additional properties to the shape.
  extraPhysicsProperties: -> {} # Override to supply additional properties to the physics object.
  
  getRenderObject: -> @avatar.getRenderObject()
  getPhysicsObject: -> @avatar.getPhysicsObject()
  
  playfieldHoleBoundaries: ->
    # Override to return an array of polygon boundaries of this part if it creates holes in the playfield.
    null
  
  initialize: ->
    @avatar.initialize()
    
  reset: ->
    @avatar.reset()
  
  _loadImageAssets: (imageUrls) ->
    # Load all the images.
    imagePromises = for imageUrl in imageUrls
      new Promise (resolve) =>
        image = new Image
        image.addEventListener 'load', =>
          resolve image
        ,
          false
        
        # Initiate the loading.
        image.src = Meteor.absoluteUrl imageUrl
        
    # Load the macintosh palette.
    macintoshPalette = await new Promise (resolve) =>
      Tracker.autorun (computation) =>
        return unless palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Macintosh
        computation.stop()
        resolve palette

    # Create a bitmap out of the images.
    Promise.all(imagePromises).then (imageResults) =>
      bitmap = new LOI.Assets.Bitmap
        palette:
          _id: macintoshPalette._id
          name: macintoshPalette.name
        bounds:
          fixed: true
          left: 0
          right: imageResults[0].width - 1
          top: 0
          bottom: imageResults[0].height - 1
        pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor'
        
      bitmap.initialize()
      
      for imageResult, layerIndex in imageResults
        bitmap.addLayer()
        bitmap.layers[layerIndex].importImage imageResult, macintoshPalette

      @bitmap bitmap
