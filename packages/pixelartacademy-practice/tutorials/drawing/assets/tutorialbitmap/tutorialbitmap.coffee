AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Project.Asset.Bitmap
  # stepAreas: an array of areas that keep track of step progression
  #   activeStepIndex: the index of the currently active step
  #   referenceUrl: optional url of the reference chosen to be drawn in this step area

  # Id used for the source of versioning actions.
  @id: -> 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.TutorialBitmap'
  
  @portfolioComponentClass: -> @PortfolioComponent
  
  # Override to limit the scale at which the bitmap appears in the clipboard.
  @minClipboardScale: -> null
  @maxClipboardScale: -> null

  # Override to define a background color.
  @backgroundColor: -> null

  # Override to define a palette.
  @restrictedPaletteName: -> null
  @customPaletteImageUrl: -> null
  @customPalette: -> null
  
  # Override if the bitmap should have fixed dimensions.
  @fixedDimensions: -> null
  
  # Override if the asset requires display of markup.
  @markup: -> false

  # Override if the asset requires a pixel art evaluation analysis.
  @pixelArtEvaluation: -> false

  # Override to provide bitmap properties that need to be set on the asset.
  @properties: -> null
  
  @initialize: ->
    super arguments...
    
    @initializeReferences()

  constructor: ->
    super arguments...
    
    @tutorial = @project

    # Create bitmap automatically if it is not present.
    @_createBitmapAutorun = Tracker.autorun (computation) =>
      return unless assets = @tutorial.assetsData()
      computation.stop()

      # All is good if we have the asset with a bitmap ID.
      return if _.find assets, (asset) => asset.id is @id() and asset.bitmapId

      # We need to create the asset with the bitmap.
      Tracker.nonreactive => @constructor.create LOI.adventure.profileId(), @tutorial, @id()
    
    # Prepare lazy initialization.
    @initialized = new ReactiveField false
    
    @completed = new AE.LiveComputedField =>
      # Read completed state from the stored assets field unless we're in the editor.
      return unless assets = @tutorial.state 'assets'
      asset = _.find assets, (asset) => asset.id is @id()
      storedCompleted = asset?.completed
      
      return storedCompleted unless @_isActiveInEditor(true) and @initialized()
      
      stepAreas = @stepAreas()
      return unless stepAreas.length
      
      for stepArea in stepAreas
        return false unless stepArea.completed()
      
      true
    
    @_initializingAutorun = Tracker.autorun (computation) =>
      # Initialize uncompleted artworks immediately so their starting steps can place any pixels.
      # Otherwise wait till we've selected the asset as the active one in the editor.
      return unless @tutorial.state 'assets'
      return unless @_isActiveInEditor(false) or not @completed()
      computation.stop()
      Tracker.nonreactive => @initialize()
      
    @resetting = new ReactiveField false
    
  destroy: ->
    super arguments...
    
    @_createBitmapAutorun.stop()
    @_initializingAutorun.stop()
    @completed.stop()

    @hasExtraPixels?.stop()
    @hasMissingPixels?.stop()
    @_completedAutorun?.stop()
    @_loadResourcesAutorun?.stop()
    
    if @stepAreas
      stepArea.destroy() for stepArea in @stepAreas()
    
    @_pixelArtEvaluation?.destroy()
    
  _isActiveInEditor: (drawingActive) ->
    return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
    return unless editor.isCreated()
    return unless asset = editor.activeAsset()
    return unless asset instanceof @constructor
    return if drawingActive and not editor.drawingActive()
    true
    
  debugResourceLoading: -> false

  initialize: ->
    return if @_initializing
    @_initializing = true
    @_initialize()
    
  # Override to provide extra initialization functionality.
  _initialize: ->
    # Fetch palette.
    @palette = new ComputedField => @customPalette() or @restrictedPalette()
    @hasPalette = new ComputedField => @constructor.customPalette() or @constructor.customPaletteImageUrl() or @constructor.restrictedPaletteName()
    
    # Prepare steps.
    @stepAreas = new ReactiveField []

    @hasExtraPixels = new AE.LiveComputedField =>
      for stepArea in @stepAreas()
        return true if stepArea.hasExtraPixels()
      
      false
      
    @hasMissingPixels = new AE.LiveComputedField =>
      for stepArea in @stepAreas()
        return true if stepArea.hasMissingPixels()
      
      false
      
    # Create engine components.
    @hintsEngineComponents =
      underlying: new @constructor.HintsEngineComponent @, 'drawUnderlyingHints'
      overlaid: new @constructor.HintsEngineComponent @, 'drawOverlaidHints'
    
    if @constructor.markup()
      @instructionsMarkupEngineComponent = new PAA.Practice.Tutorials.Drawing.InstructionsMarkupEngineComponent
    
    # Create additional helpers.
    if @constructor.pixelArtEvaluation()
      @pixelArtEvaluationInstance = new ComputedField =>
        return unless bitmap = @versionedBitmap()
        @_pixelArtEvaluation?.destroy()
        @_pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation bitmap
        
      @pixelArtEvaluation = new ComputedField =>
        return unless pixelArtEvaluation = @pixelArtEvaluationInstance()
        pixelArtEvaluation.depend()
        pixelArtEvaluation
       
    # Save completed value to tutorial state.
    @_completedAutorun = Tracker.autorun (computation) =>
      # Make sure we have the game state loaded. This can become null when switching between characters.
      return unless LOI.adventure.gameState()

      # We expect completed to return true or false, and undefined if can't yet determine (loading).
      completed = @completed()
      return unless completed?

      assets = @tutorial.state 'assets'

      unless assets
        assets = []
        updated = true

      asset = _.find assets, (asset) => asset.id is @id()

      unless asset
        asset = id: @id()
        assets.push asset
        updated = true

      unless asset.completed is completed
        asset.completed = completed
        updated = true
        
      if updated
        Tracker.nonreactive => @tutorial.state 'assets', assets
      
    # Create resources.
    @resources = @constructor.createResources()
    
    resourcesReady = (resources) =>
      if @debugResourceLoading()
        console.log "Resource ready?", resources, resources.ready() if resources.ready
        
      return resources.ready() if resources.ready
      
      if _.isArray resources
        for resource in resources
          return false unless resourcesReady resource
      
      else if _.isObject resources
        for name, resource of resources
          return false unless resourcesReady resource
      
      true
      
    @_loadResourcesAutorun = Tracker.autorun (computation) =>
      # Wait until all resources have loaded.
      return unless resourcesReady @resources

      # Wait until the declared palette (and default for background colors) have loaded.
      return if @hasPalette() and not @palette()
      LOI.Assets.Palette.defaultPalette()
      
      # Wait until the bitmap document becomes available.
      return unless @bitmap()
      
      computation.stop()
      
      # Resources are loaded, create tutorial steps.
      @initializeSteps()
      
      @initialized true
      
  reset: ->
    # Prevent recomputation of completed states while resetting.
    @resetting true
    
    # Reset all steps.
    stepArea.reset() for stepArea in @stepAreas()
    
    # Remove any asset data.
    assetsData = @tutorial.assetsData()
    assetId = @id()
    
    if assetData = _.find assetsData, (assetData) => assetData.id is assetId
      assetData.stepAreas = []
      assetData.completed = false
      
      @tutorial.state 'assets', assetsData
    
    # Unlock recomputation after changes have been applied.
    Tracker.afterFlush => @resetting false
  
  addStepArea: (stepArea) ->
    stepAreas = @stepAreas()
    stepAreas.push stepArea
    @stepAreas stepAreas
    
    # Return the step area index.
    stepAreas.length - 1
    
  getBackgroundColor: ->
    return unless backgroundColor = @constructor.backgroundColor()
    return unless @initialized()

    if backgroundColor.paletteColor
      backgroundColor = @palette().color backgroundColor.paletteColor.ramp, backgroundColor.paletteColor.shade
    
    backgroundColor
  
  editorDrawComponents: ->
    return [] unless @initialized()
    
    components = [
      component: @hintsEngineComponents.underlying, before: LOI.Assets.Engine.PixelImage.Bitmap
    ,
      component: @hintsEngineComponents.overlaid, before: LOI.Assets.SpriteEditor.PixelCanvas.OperationPreview
    ]
    
    if @instructionsMarkupEngineComponent
      components.push
        component: @instructionsMarkupEngineComponent, before: LOI.Assets.SpriteEditor.PixelCanvas.OperationPreview
    
    components

  styleClasses: ->
    classes = [
      'completed' if @completed()
    ]

    _.without(classes, undefined).join ' '

  minClipboardScale: -> @constructor.minClipboardScale?()
  maxClipboardScale: -> @constructor.maxClipboardScale?()

  solve: ->
    @_afterInitialization =>
      stepArea.solve() for stepArea in @stepAreas()
    
  solveAndComplete: ->
    @_afterInitialization =>
      @solve()
      
      assets = @tutorial.state 'assets'
      asset = _.find assets, (asset) => asset.id is @id()
      asset.completed = true
      @tutorial.state 'assets', assets
    
  _afterInitialization: (action) ->
    @initialize()
    
    Tracker.autorun (computation) =>
      return unless @initialized()
      computation.stop()
      action()
  
  hasGoalPixel: (x, y) ->
    return unless @initialized()
    
    # Check if any of the step areas require a pixel at these absolute bitmap coordinates.
    for stepArea in @stepAreas()
      return true if stepArea.hasGoalPixel x, y
    
    false
