AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part extends LOI.Adventure.Item
  @assetID: -> # Override if this part's asset comes from the project.
  @imageUrl: -> # Override if this part's asset comes from static images.
  
  @avatarShapes: -> throw new AE.NotImplementedException  "A playfield part must specify which shapes it can have in order of preference."
  
  @avatarClass: -> Pinball.Part.Avatar # Override if the part requires a custom avatar.
  
  constructor: (@pinball, @data) ->
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
        
    @avatarProperties = new ComputedField =>
      _.extend {}, @data(), @createAvatarProperties()
  
  createAvatar: ->
    avatarClass = @constructor.avatarClass()
    new avatarClass @
  
  createAvatarProperties: -> {} # Override to supply additional properties to the avatar.
  
  playfieldHoleRectangle: ->
    # Override to return the bounding rectangle of this part if it creates a hole in the playfield.
    null
  
  onAddedToDynamicsWorld: (dynamicsWorld) ->
    # Override if the part needs to perform any logic after its physics object was added to the dynamics world.
  
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    # Override to perform any cleanup after the physics object was removed from the dynamics world.
  
  update: (appTime) -> # Override if the part needs to perform any update logic.
  
  fixedUpdate: (elapsed) -> # Override if the part needs to perform any update logic.
  
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
