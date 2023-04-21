AB = Artificial.Base
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Project.Asset.Bitmap
  @id: -> 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.TutorialBitmap'
  
  # Override to provide a bitmap string describing the bitmap.
  @bitmapString: -> null
  @goalBitmapString: -> null

  # Override to provide an image URL to describing the bitmap.
  @imageUrl: -> null
  @goalImageUrl: -> null

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

    # Load goal pixels.
    @goalPixels = new ReactiveField null
    @goalPixelsMap = new ReactiveField null

    if goalBitmapString = @constructor.goalBitmapString()
      # Load pixels from the bitmapString string.
      @_setGoalPixels @constructor.createPixelsFromBitmapString goalBitmapString

    else if goalImageUrl = @constructor.goalImageUrl()
      # Load pixels from the source image.
      image = new Image
      image.addEventListener 'load', =>
        @_setGoalPixels @constructor.createPixelsFromImage image
      ,
        false

      # Initiate the loading.
      image.src = Meteor.absoluteUrl goalImageUrl

    # Create the component that will show the goal state.
    @engineComponent = new @constructor.EngineComponent
      spriteData: =>
        return unless goalPixels = @goalPixels()
        return unless bitmapId = @bitmapId()

        # Take same overall visual asset data (bounds, palette) as the bitmap used for drawing, but
        # exclude the layers since we'll be converting the bitmap to a sprite and provide our own pixels.
        bitmap = LOI.Assets.Bitmap.documents.findOne bitmapId,
          fields:
            'layers': false
            'layerGroups': false
            'pixelFormat': false

        return unless bitmap
        
        spriteData = bitmap.toPlainObject()

        # Replace layers with the goal state.
        spriteData.layers = [pixels: goalPixels]
  
        new LOI.Assets.Sprite spriteData

    @completed = new ComputedField =>
      # Compare goal layer with current bitmap layer.
      return unless bitmapLayer = @bitmap()?.layers[0]
      return unless goalPixelsMap = @goalPixelsMap()
      return unless @palette()

      if backgroundColor = @constructor.backgroundColor()
        # Convert background color to the same format as goal pixels.
        backgroundColor = directColor: backgroundColor unless backgroundColor.paletteColor
        backgroundColor.integerDirectColor = if backgroundColor.paletteColor then @_paletteToIntegerDirectColor backgroundColor.paletteColor else @_directToIntegerDirectColor backgroundColor.directColor

      for x in [0...bitmapLayer.width]
        for y in [0...bitmapLayer.height]
          pixel = bitmapLayer.getPixel(x, y) or backgroundColor
          goalPixel = goalPixelsMap[x]?[y] or backgroundColor
  
          # Both pixels must either exist or not.
          return false unless pixel? is goalPixel?
          
          # Nothing further to check if the pixel is empty.
          continue unless pixel and goalPixel
          
          # If either of the pixels has a direct color, we need to translate the other one too.
          if pixel.paletteColor and goalPixel.paletteColor
            return false unless EJSON.equals pixel.paletteColor, goalPixel.paletteColor
  
          else
            pixelIntegerDirectColor = if pixel.paletteColor then @_paletteToIntegerDirectColor pixel.paletteColor else @_directToIntegerDirectColor pixel.directColor
            return false unless EJSON.equals pixelIntegerDirectColor, goalPixel.integerDirectColor

      true
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
  
  solve: ->
    bitmap = @bitmap()
    goalPixelsMap = @goalPixelsMap()
    pixels = []
  
    for x in [0...bitmap.bounds.width]
      for y in [0...bitmap.bounds.height]
        pixels.push goalPixelsMap[x]?[y] or {x, y}
  
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
  _setGoalPixels: (goalPixels) ->
    @goalPixels goalPixels

    Tracker.autorun (computation) =>
      return unless @palette()
      computation.stop()

      # We create a map representation for fast retrieval as well.
      map = {}

      for pixel in goalPixels
        map[pixel.x] ?= {}
        map[pixel.x][pixel.y] = pixel
        pixel.integerDirectColor = if pixel.directColor then @_directToIntegerDirectColor pixel.directColor else @_paletteToIntegerDirectColor pixel.paletteColor

      @goalPixelsMap map

  _paletteToIntegerDirectColor: (paletteColor) ->
    palette = @palette()
    @_directToIntegerDirectColor palette.ramps[paletteColor.ramp]?.shades[paletteColor.shade]

  _directToIntegerDirectColor: (color) ->
    r: Math.round color.r * 255
    g: Math.round color.g * 255
    b: Math.round color.b * 255

  editorDrawComponents: -> [
    component: @engineComponent, before: LOI.Assets.SpriteEditor.PixelCanvas.OperationPreview
  ]

  styleClasses: ->
    classes = [
      'completed' if @completed()
    ]

    _.without(classes, undefined).join ' '

  minClipboardScale: -> @constructor.minClipboardScale?()
  maxClipboardScale: -> @constructor.maxClipboardScale?()
