AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Bitmap extends PAA.Practice.Project.Asset
  # bitmapId: reference to a bitmap
  
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
  
  # Override to add a style class to bitmap info.
  @bitmapInfoClass: -> ''

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

  # Override if the asset requires a readability analysis.
  @readabilityAnalysis: -> false
  
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

    # Allow palette access.
    # Note: We need this immediately so that background color can be calculated in the portfolio.
    @palette = new AE.LiveComputedField => @customPalette() or @restrictedPalette()
    
    briefComponentClass = @constructor.briefComponentClass()
    @briefComponent = new briefComponentClass @
    
    # Subscribe to the palette.
    if restrictedPaletteName = @constructor.restrictedPaletteName()
      @_restrictedPaletteSubscription = LOI.Assets.Palette.forName.subscribeContent restrictedPaletteName

    # Prepare lazy initialization.
    @initialized = new ReactiveField false

    @isActiveInEditor = new ReactiveField false
    @isActiveDrawingInEditor = new ReactiveField false
    
    @_isActiveInEditorAutorun = Tracker.autorun (computation) =>
      editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
      activeInEditor = editor?.isCreated() and editor?.activeAsset() instanceof @constructor
      @isActiveInEditor activeInEditor
      @isActiveDrawingInEditor activeInEditor and editor.drawingActive()

    # Allow derived classes to finish constructing.
    Meteor.setTimeout =>
      @_initializingAutorun = Tracker.autorun (computation) =>
        return unless @initializingConditions()
        computation.stop()
        Tracker.nonreactive => @_initializeIfNeeded()

  destroy: ->
    super arguments...

    @bitmapId.stop()
    @bitmap.stop()
    @versionedBitmap.stop()
    @palette.stop()
    
    @_restrictedPaletteSubscription?.stop()
    @_isActiveInEditorAutorun.stop()
    @_initializingAutorun?.stop()
    @_pixelArtEvaluation?.destroy()
    @_readabilityAnalysis?.destroy()
    
  initializingConditions: ->
    # Wait with initializing until we've selected the asset as the active one in the editor.
    @isActiveInEditor()
  
  _initializeIfNeeded: ->
    return if @_initializeNotNeeded
    @_initializeNotNeeded = true
    @_initialize()

  # Override to provide extra initialization functionality.
  _initialize: ->
    # Create additional helpers.
    if pixelArtEvaluation = @constructor.pixelArtEvaluation()
      # Pixel art evaluation options can either come from the constructor or from the instance.
      # We check if the instance provides this options method, otherwise we take the static one.
      if @pixelArtEvalutionOptions
        pixelArtEvaluationOptions = @pixelArtEvaluationOptions()
        
      else
        pixelArtEvaluationOptions = if _.isObject pixelArtEvaluation then pixelArtEvaluation else {}
      
      @pixelArtEvaluationInstance = new ComputedField =>
        return unless bitmap = @versionedBitmap()
        @_pixelArtEvaluation?.destroy()
        @_pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation bitmap, pixelArtEvaluationOptions
      
      @pixelArtEvaluation = new ComputedField =>
        return unless pixelArtEvaluationInstance = @pixelArtEvaluationInstance()
        pixelArtEvaluationInstance.depend()
        pixelArtEvaluationInstance
        
    if readabilityAnalysis = @constructor.readabilityAnalysis()
      # Readability analysis options can either come from the constructor or from the instance.
      # We check if the instance provides this options method, otherwise we take the static one.
      if @readabilityAnalysisOptions
        readabilityAnalysisOptions = @readabilityAnalysisOptions()
        
      else
        readabilityAnalysisOptions = if _.isObject readabilityAnalysis then readabilityAnalysis else {}
      
      @readabilityAnalysisInstance = new ComputedField =>
        return unless bitmap = @versionedBitmap()
        @_readabilityAnalysis?.destroy()
        @_readabilityAnalysis = new PAA.Practice.ReadabilityAnalysis bitmap, readabilityAnalysisOptions
      
      @readabilityAnalysis = new ComputedField =>
        return unless readabilityAnalysisInstance = @readabilityAnalysisInstance()
        readabilityAnalysisInstance.depend()
        readabilityAnalysisInstance
    
    Meteor.setTimeout => @initialized true

  urlParameter: -> @bitmapId()
  
  ready: ->
    # We're ready when the bitmap has been loaded.
    @bitmap()
  
  width: -> @bitmap()?.bounds.width
  height: -> @bitmap()?.bounds.height
  pixelArtScaling: -> true
  portfolioBorderWidth: -> 6
  
  # Returns information about presenting the asset in the drawing app.
  # borderWidth: how thick the border should be
  # scale: what magnification the preview is using
  # position: where the top-left corner of the preview is
  #   top, left: CSS string for positioning the preview
  previewInfo: ->
    return unless @clipboardComponent.isCreated()
    @clipboardComponent.callFirstWith null, 'previewInfo'

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
      return unless palette = @palette()
      palette.color paletteColor.ramp, paletteColor.shade

    else
      # We assume the color is already a color instance.
      backgroundColor

  bitmapInfo: ->
    translation = AB.translate @_translationSubscription, 'bitmapInfo'
    if translation.language then translation.text else null

  bitmapInfoTranslation: -> AB.translation @_translationSubscription, 'bitmapInfo'
  
  bitmapInfoClass: -> @constructor.bitmapInfoClass()
  
  imageUrl: ->
    return unless bitmapId = @bitmapId()
    "/assets/bitmap.png?id=#{bitmapId}"
    
  # Override if you want to send options based on the bitmap instance (instead of the static options).
  pixelArtEvaluationOptions: ->
  readabilityAnalysisOptions: ->

# We want a generic state for bitmap assets so we create it outside of the constructor as inherited classes don't need it.
# canEdit: can the user edit the bitmaps with built-in editors
# canUpload: can the user upload bitmaps
# unlockedPixelArtEvaluationCriteria: array of pixel art evaluation criteria that the user can enable
Bitmap = PAA.Practice.Project.Asset.Bitmap

Bitmap.stateAddress = new LOI.StateAddress "things.PixelArtAcademy.Practice.Project.Asset.Bitmap"
Bitmap.state = new LOI.StateObject address: Bitmap.stateAddress
