PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap extends PAA.Practice.Project.Asset.Bitmap
  @id: -> 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap'
  
  # Override to provide an SVG URL to describing the drawing.
  @svgUrl: -> null

  # Override to limit the scale at which the bitmap appears in the clipboard.
  @minClipboardScale: -> null
  @maxClipboardScale: -> null

  # Override to define a background color.
  @backgroundColor: -> null

  # Override to define a palette.
  @restrictedPaletteName: -> null
  @customPaletteImageUrl: -> null
  @customPalette: -> null
  
  @initialize: ->
    super arguments...
    
    # Create reference images on the server. They should be exported as database content.
    if Meteor.isServer and not Meteor.settings.startEmpty
      if references = @references?()
        Document.startup =>
          for reference in references
            # Allow sending in just the reference URL.
            imageUrl = reference.image?.url or reference
      
            LOI.Assets.Image.documents.insert url: imageUrl unless LOI.Assets.Image.documents.findOne url: imageUrl

  constructor: ->
    super arguments...
    
    @tutorial = @project

    # Create bitmap automatically if it is not present.
    Tracker.autorun (computation) =>
      return unless assets = @tutorial.assetsData()
      computation.stop()

      # All is good if we have the asset with a bitmap ID.
      return if _.find assets, (asset) => asset.id is @id() and asset.bitmapId

      # We need to create the asset with the bitmap.
      Tracker.nonreactive => @constructor.create LOI.adventure.profileId(), @tutorial, @id()
      
    # Fetch palette.
    @palette = new ComputedField =>
      return unless bitmapData = @bitmap()
      bitmapData.customPalette or LOI.Assets.Palette.documents.findOne bitmapData.palette._id

    # Load SVG.
    @svgPaths = new ReactiveField null
    @currentActivePathIndex = new ReactiveField 0

    svgUrl = Meteor.absoluteUrl @constructor.svgUrl()
    fetch(svgUrl).then((response) => response.text()).then (svgXml) =>
      parser = new DOMParser();
      svgDocument = parser.parseFromString svgXml, "image/svg+xml"
      @svgPaths svgDocument.getElementsByTagName 'path'
      
    # Create paths
    @paths = new ReactiveField []
    
    Tracker.autorun (computation) =>
      return unless @bitmap()
      return unless svgPaths = @svgPaths()
      computation.stop()
      
      @paths (new @constructor.Path @, svgPath for svgPath in svgPaths)

    # Create the component that will show the goal state.
    @engineComponent = new @constructor.EngineComponent
      svgPaths: => @svgPaths()
      paths: => @paths()
      currentActivePathIndex: => @currentActivePathIndex()

    @completed = new ComputedField =>
      return unless paths = @paths()

      completedPaths = 0
      
      for path in paths
        if path.completed()
          completedPaths++
          
        else
          break
      
      @currentActivePathIndex Math.min completedPaths, paths.length - 1
      
      completedPaths is paths.length
    ,
      true

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

      @tutorial.state 'assets', assets if updated

  destroy: ->
    super arguments...

    @completed.stop()
    @_completedAutorun.stop()
  
  getBackgroundColor: ->
    return unless backgroundColor = @constructor.backgroundColor()

    # If the color is given directly it's a direct color.
    backgroundColor = directColor: backgroundColor unless backgroundColor.paletteColor
    
    backgroundColor
  
  solve: ->
  
  editorDrawComponents: -> [
    component: @engineComponent, before: LOI.Assets.Engine.PixelImage.Bitmap
  ]

  styleClasses: ->
    classes = [
      'completed' if @completed()
    ]

    _.without(classes, undefined).join ' '

  minClipboardScale: -> @constructor.minClipboardScale?()
  maxClipboardScale: -> @constructor.maxClipboardScale?()
