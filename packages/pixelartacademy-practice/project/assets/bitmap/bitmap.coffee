AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Bitmap extends PAA.Practice.Project.Asset
  # bitmapId: reference to a bitmap
  
  @portfolioBorderWidth = 6
  
  # Type of this asset.
  @type: -> @Types.Bitmap

  # Override to provide an object with width and height to specify that this bitmap has predefined dimensions.
  @fixedDimensions: -> null

  # Override to provide an object with width and height to specify that this bitmap has a minimum size.
  @minDimensions: -> null

  # Override to provide an object with width and height to specify that this bitmap has a maximum size.
  @maxDimensions: -> null

  # Override to provide the name of the palette this bitmap must be created with.
  @restrictedPaletteName: -> null

  # Override to set which background color is used.
  @backgroundColor: -> null

  # Override to restrict the total number of colors used.
  @maxColorCount: -> null

  # Override to provide a string with more information related to the bitmap (e.g. author info in challenges).
  @bitmapInfo: -> null

  @portfolioComponentClass: ->
    @PortfolioComponent
    
  @clipboardComponentClass: ->
    @ClipboardComponent
  
  @briefComponentClass: ->
    # Override to provide a different brief component.
    @BriefComponent

  # Override if the asset requires a pixel art evaluation analysis.
  # You can return an object to be sent as options to the constructor.
  @pixelArtEvaluation: -> false
  
  @initialize: ->
    super arguments...

    # On the server, create this asset's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()

        for property in ['bitmapInfo']
          if value = @[property]?()
            AB.createTranslation translationNamespace, property, value

  constructor: ->
    super arguments...

    @bitmapId = new AE.LiveComputedField =>
      @data()?.bitmapId

    @bitmap = new AE.LiveComputedField =>
      return unless bitmapId = @bitmapId()

      LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
    
    # Allow to get the versioned document in a non-reactive way.
    @versionedBitmap = new AE.LiveComputedField =>
      return unless bitmapId = @bitmapId()
      
      LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId, false
    
    # Alias for the drawing app.
    @document = @bitmap

    briefComponentClass = @constructor.briefComponentClass()
    @briefComponent = new briefComponentClass @
    
    # Subscribe to the palette.
    if restrictedPaletteName = @constructor.restrictedPaletteName()
      LOI.Assets.Palette.forName.subscribeContent restrictedPaletteName

    # Prepare lazy initialization.
    @initialized = new ReactiveField false

    # Allow dereived classes to finish constructing.
    Meteor.setTimeout =>
      @_initializingAutorun = Tracker.autorun (computation) =>
        return unless @initializingConditions()
        computation.stop()
        Tracker.nonreactive => @initialize()

  destroy: ->
    super arguments...

    @bitmapId.stop()
    @bitmap.stop()
    @versionedBitmap.stop()
    
    @_initializingAutorun?.stop()
    @_pixelArtEvaluation?.destroy()
    
  initializingConditions: ->
    # Wait with initalizing until we've selected the asset as the active one in the editor.
    @_isActiveInEditor false
  
  _isActiveInEditor: (requiresDrawingActive) ->
    return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
    return unless editor.isCreated()
    return unless asset = editor.activeAsset()
    return unless asset instanceof @constructor
    return if requiresDrawingActive and not editor.drawingActive()
    true
  
  initialize: ->
    return if @_initializing
    @_initializing = true
    @_initialize()

  # Override to provide extra initialization functionality.
  _initialize: ->
    @palette = new ComputedField => @customPalette() or @restrictedPalette()
  
    # Create additional helpers.
    if pixelArtEvaluation = @constructor.pixelArtEvaluation()
      pixelArtEvaluationOptions = if _.isObject pixelArtEvaluation then pixelArtEvaluation else {}
      
      @pixelArtEvaluationInstance = new ComputedField =>
        return unless bitmap = @versionedBitmap()
        @_pixelArtEvaluation?.destroy()
        @_pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation bitmap, pixelArtEvaluationOptions
      
      @pixelArtEvaluation = new ComputedField =>
        return unless pixelArtEvaluationInstance = @pixelArtEvaluationInstance()
        pixelArtEvaluationInstance.depend()
        pixelArtEvaluationInstance
        
    Meteor.setTimeout => @initialized true
  
  _afterInitialization: (action) ->
    @initialize()
    
    Tracker.autorun (computation) =>
      return unless @initialized()
      computation.stop()
      action()

  urlParameter: -> @bitmapId()
  
  ready: ->
    # We're ready when the bitmap has been loaded.
    @bitmap()
  
  width: -> @bitmap()?.bounds.width
  height: -> @bitmap()?.bounds.height
  portfolioBorderWidth: -> 6

  fixedDimensions: -> @constructor.fixedDimensions()

  restrictedPalette: ->
    return unless restrictedPaletteName = @constructor.restrictedPaletteName()

    LOI.Assets.Palette.documents.findOne
      name: restrictedPaletteName
      
  customPalette: ->
    new LOI.Assets.Palette customPalette if customPalette = @bitmap()?.customPalette
  
  backgroundColor: ->
    return unless backgroundColor = @constructor.backgroundColor()

    if paletteColor = backgroundColor.paletteColor
      # We need to wait until we're initialized so that the palette field is ready.
      return unless @initialized()
      return unless palette = @palette()
      palette.color paletteColor.ramp, paletteColor.shade

    else
      # We assume the color is already a color instance.
      backgroundColor

  bitmapInfo: ->
    translation = AB.translate @_translationSubscription, 'bitmapInfo'
    if translation.language then translation.text else null

  bitmapInfoTranslation: -> AB.translation @_translationSubscription, 'bitmapInfo'
  
  imageUrl: ->
    return unless bitmapId = @bitmapId()
    "/assets/bitmap.png?id=#{bitmapId}"

# We want a generic state for bitmap assets so we create it outside of the constructor as inherited classes don't need it.
# canEdit: can the user edit the bitmaps with built-in editors
# canUpload: can the user upload bitmaps
# unlockedPixelArtEvaluationCriteria: array of pixel art evaluation criteria that the user can enable
Bitmap = PAA.Practice.Project.Asset.Bitmap

Bitmap.stateAddress = new LOI.StateAddress "things.PixelArtAcademy.Practice.Project.Asset.Bitmap"
Bitmap.state = new LOI.StateObject address: Bitmap.stateAddress
