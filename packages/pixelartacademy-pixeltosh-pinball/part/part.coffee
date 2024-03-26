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
  
  @assetID: -> # Override if this part's asset comes from the project.
  @imageUrl: -> # Override if this part's asset comes from static images.
  
  @avatarShapes: -> throw new AE.NotImplementedException  "A playfield part must specify which shapes it can have in order of preference."
  
  @avatarClass: -> Pinball.Part.Avatar # Override if the part requires a custom avatar.
  
  @selectable: -> true # Override if this part can't be selected.
  
  constructor: (@pinball, @playfieldPartId) ->
    super arguments...
    
    # Load the bitmap asset.
    @bitmap = new ReactiveField null
    
    if imageUrls = @constructor.imageUrl()
      # Load static images and create a bitmap out of them.
      imageUrls = [imageUrls] unless _.isArray imageUrls
      @_loadImageAssets imageUrls
      
    else if assetId = @constructor.assetID()
      # Reactively load the bitmap asset.
      @autorun (computation) =>
        @bitmap null

    # Create reactive data for the part.
    @data = new ComputedField =>
      _.extend @defaultData(), @pinball.getPartData @playfieldPartId
    ,
      EJSON.equals
    
    @shapeProperties = new ComputedField =>
      _.defaults {}, _.pick(@data(), ['flipped']), @constants()
    ,
      EJSON.equals
    
    @physicsProperties = new ComputedField =>
      _.defaults {}, _.pick(@data(), ['restitution', 'friction', 'rollingFriction']), @constants()
    ,
      EJSON.equals
      
    @_temporaryPosition = new ReactiveField null
    @_temporaryRotationAngle = new ReactiveField null
    
    # Reset the part whenever data changes.
    @autorun (computation) =>
      @data()
      @reset()
    
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
    
  rotation: ->
    new THREE.Quaternion().setFromEuler new THREE.Euler 0, @rotationAngle(), 0
  
  createAvatar: ->
    avatarClass = @constructor.avatarClass()
    new avatarClass @
  
  defaultData: -> {} # Override to supply default data.
  constants: -> {} # Override to supply additional properties to the avatar.
  
  getRenderObject: -> @avatar.getRenderObject()
  getPhysicsObject: -> @avatar.getPhysicsObject()
  
  playfieldHoleBoundaries: ->
    # Override to return an array of polygon boundaries of this part if it creates holes in the playfield.
    null
  
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
        
    # Load the black palette.
    macintoshPalette = await new Promise (resolve) =>
      Tracker.autorun (computation) =>
        return unless palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Macintosh
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
