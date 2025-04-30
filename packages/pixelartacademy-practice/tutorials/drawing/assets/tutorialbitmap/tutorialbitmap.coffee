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

  # Override to define a palette.
  @restrictedPaletteName: -> null
  @customPaletteImageUrl: -> null
  @customPalette: -> null
  
  # Override if the bitmap should have fixed dimensions.
  @fixedDimensions: -> null
  
  # Override if the asset requires display of markup.
  @markup: -> false

  # Override to provide bitmap properties that need to be set on the asset.
  @properties: -> null
  
  @initialize: ->
    super arguments...
    
    @initializeReferences()
    
  @_isPixelEmpty: (pixel, backgroundColor, palette) ->
    # We're empty if we don't have a pixel.
    return true unless pixel
    
    # We do have a pixel, so if there is no background color, it can't be empty.
    return false unless backgroundColor
    
    # We have a pixel and a background color, the pixel is empty if it matches it.
    LOI.Assets.ColorHelper.areAssetColorsEqual pixel, backgroundColor, palette

  constructor: ->
    super arguments...
    
    @tutorial = @project

    # Create bitmap automatically if it is not present.
    @_createBitmapAutorun = Tracker.autorun (computation) =>
      # Note: We need to read the assets from the assetsData property instead of directly from the state since this
      # needs to work even when assets array is not even yet present in the state. The assetsData method ensures at
      # least an empty array is sent as soon as the state is ready.
      return unless assets = @tutorial.assetsData()
      computation.stop()

      # All is good if we have the asset with a bitmap ID.
      return if _.find assets, (asset) => asset.id is @id() and asset.bitmapId

      # We need to create the asset with the bitmap.
      Tracker.nonreactive => @constructor.create LOI.adventure.profileId(), @tutorial, @id()
    
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
    
  initializingConditions: ->
    # Initialize uncompleted artworks immediately so their starting steps can place any pixels.
    # Otherwise wait till we've selected the asset as the active one in the editor.
    return unless @tutorial.state 'assets'
    return true unless @completed()
    
    super arguments...
    
  debugResourceLoading: -> false

  _initialize: ->
    super arguments...
    
    # Fetch palette.
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
    
    @resourcesReady = new ReactiveField false
    
    resourcesReadyRecursive = (resources) =>
      if @debugResourceLoading()
        console.log "Resource ready?", resources, resources.ready() if resources.ready
        
      return resources.ready() if resources.ready
      
      if _.isArray resources
        for resource in resources
          return false unless resourcesReadyRecursive resource
      
      else if _.isObject resources
        for name, resource of resources
          return false unless resourcesReadyRecursive resource
      
      true
      
    @_loadResourcesAutorun = Tracker.autorun (computation) =>
      # Wait until all resources have loaded.
      return unless resourcesReadyRecursive @resources
      
      @resourcesReady true
      
      # Wait until the declared palette (and default for background colors) have loaded.
      return if @hasPalette() and not @palette()
      LOI.Assets.Palette.defaultPalette()
      
      # Wait until the bitmap document becomes available.
      return unless @bitmap()
      
      computation.stop()
      
      # Resources are loaded, create tutorial steps.
      Tracker.nonreactive => @initializeSteps()
      
  reset: ->
    # Nothing to reset if we haven't initialized yet (resetting will be called when first creating the bitmap).
    return unless @initialized()
    
    # Prevent recomputation of completed states while resetting.
    @resetting true
    
    # Reset all steps.
    stepArea.reset() for stepArea in @stepAreas()
    
    # Remove any asset data.
    if assetData = @getAssetData()
      assetData.stepAreas = []
      assetData.completed = false
      
      @setAssetData assetData
    
    # Unlock recomputation after changes have been applied.
    Tracker.afterFlush => @resetting false
    
  getAssetData: ->
    assetsData = @tutorial.assetsData()
    assetId = @id()
    
    _.find assetsData, (assetData) => assetData.id is assetId
    
  setAssetData: (assetData) ->
    assetsData = @tutorial.assetsData()
    assetId = @id()
    
    assetDataIndex = _.findIndex assetsData, (assetData) => assetData.id is assetId
    assetsData[assetDataIndex] = assetData
    
    @tutorial.state 'assets', assetsData
  
  addStepArea: (stepArea) ->
    stepAreas = @stepAreas()
    stepAreas.push stepArea
    @stepAreas stepAreas
    
    # Return the step area index.
    stepAreas.length - 1
  
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
  
  hasGoalPixel: (x, y) ->
    return unless @initialized()
    
    # Check if any of the step areas require a pixel at these absolute bitmap coordinates.
    for stepArea in @stepAreas()
      return true if stepArea.hasGoalPixel x, y
    
    false
