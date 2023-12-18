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

  # Override if the asset requires a pixel art grading analysis.
  @pixelArtGrading: -> false

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
      
    @completed = new AE.LiveComputedField =>
      stepAreas = @stepAreas()
      return unless stepAreas.length
      
      for stepArea in stepAreas
        return false unless stepArea.completed()
      
      true
      
    # Create engine components.
    @hintsEngineComponents =
      underlying: new @constructor.HintsEngineComponent @, 'drawUnderlyingHints'
      overlaid: new @constructor.HintsEngineComponent @, 'drawOverlaidHints'
    
    if @constructor.markup()
      @instructionsMarkupEngineComponent = new PAA.Practice.Tutorials.Drawing.InstructionsMarkupEngineComponent
    
    # Create additional helpers.
    if @constructor.pixelArtGrading()
      @pixelArtGradingInstance = new ComputedField =>
        return unless bitmap = @versionedBitmap()
        @_pixelArtGrading?.destroy()
        @_pixelArtGrading = new PAA.Practice.PixelArtGrading bitmap
        
      @pixelArtGrading = new ComputedField =>
        return unless pixelArtGrading = @pixelArtGradingInstance()
        pixelArtGrading.depend()
        pixelArtGrading
       
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
    
    resourcesReady = (resources) ->
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
  
  destroy: ->
    super arguments...
    
    @_createBitmapAutorun.stop()
    @hasExtraPixels.stop()
    @hasMissingPixels.stop()
    @completed.stop()
    @_completedAutorun.stop()
    @_loadResourcesAutorun.stop()
  
    stepArea.destroy() for stepArea in @stepAreas()
    
    @_pixelArtGrading?.destroy()
    
  addStepArea: (stepArea) ->
    stepAreas = @stepAreas()
    stepAreas.push stepArea
    @stepAreas stepAreas
    
    # Return the step area index.
    stepAreas.length - 1
    
  getBackgroundColor: ->
    return unless backgroundColor = @constructor.backgroundColor()

    if backgroundColor.paletteColor
      backgroundColor = @palette().color backgroundColor.paletteColor.ramp, backgroundColor.paletteColor.shade
    
    backgroundColor
  
  editorDrawComponents: ->
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
    stepArea.solve() for stepArea in @stepAreas()
  
  hasGoalPixel: (x, y) ->
    # Check if any of the step areas require a pixel at these absolute bitmap coordinates.
    for stepArea in @stepAreas()
      return true if stepArea.hasGoalPixel x, y
    
    false
