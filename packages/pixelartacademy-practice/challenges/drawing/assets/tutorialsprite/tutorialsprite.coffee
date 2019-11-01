AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Project.Asset.Sprite
  @id: -> 'PixelArtAcademy.Practice.Challenges.Drawing.TutorialSprite'
    
  # Override to provide a bitmap string describing the sprite.
  @bitmapString: -> null
  @goalBitmapString: -> null

  # Override to provide an image URL to describing the sprite.
  @imageUrl: -> null
  @goalImageUrl: -> null

  # Override to limit the scale at which the sprite appears in the clipboard.
  @minClipboardScale: -> null
  @maxClipboardScale: -> null

  # Override to define a background color.
  @backgroundColor: -> null

  # Override to define a palette.
  @restrictedPaletteName: -> null
  @customPaletteImageUrl: -> null
  @customPalette: -> null

  # Methods

  @create: new AB.Method name: "#{@id()}.create"
  @reset: new AB.Method name: "#{@id()}.reset"

  @createPixelsfromBitmapString: (bitmapString) ->
    # We need to quit if we get an empty string since the regex would never quit on it.
    return [] unless bitmapString?.length

    regExp = /^\|?(.*)/gm
    lines = (match[1] while match = regExp.exec bitmapString)

    pixels = []

    for line, y in lines
      for character, x in line
        # Skip spaces (empty pixel).
        continue if character is ' '

        # We support up to 16 colors denoted in hex notation.
        ramp = parseInt character, 16

        pixels.push
          x: x
          y: y
          paletteColor:
            ramp: ramp
            shade: 0

    pixels

  @createPixelsFromImageData: (imageData) ->
    pixels = []

    for x in [0...imageData.width]
      for y in [0...imageData.height]
        pixelOffset = (x + y * imageData.width) * 4

        # Skip transparent pixels.
        continue unless imageData.data[pixelOffset + 3]

        pixels.push
          x: x
          y: y
          directColor:
            r: imageData.data[pixelOffset] / 255
            g: imageData.data[pixelOffset + 1] / 255
            b: imageData.data[pixelOffset + 2] / 255

    pixels

  constructor: ->
    super arguments...
    
    @tutorial = @project

    # Create sprite automatically if it is not present.
    Tracker.autorun (computation) =>
      return unless assets = @tutorial.assetsData()
      computation.stop()

      # All is good if we have the asset.
      return if _.find assets, (asset) => asset.id is @id()

      # We need to create the asset with the sprite.
      @constructor.create LOI.characterId(), @tutorial.id(), @id()

    # Fetch palette.
    @palette = new ComputedField =>
      return unless spriteData = @sprite()
      spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

    # Load goal pixels.
    @goalPixels = new ReactiveField null
    @goalPixelsMap = new ReactiveField null

    if goalBitmapString = @constructor.goalBitmapString()
      # Load pixels from the bitmapString string.
      @setGoalPixels @constructor.createPixelsfromBitmapString goalBitmapString

    else if goalImageUrl = @constructor.goalImageUrl()
      # Load pixels from the source image.
      image = new Image
      image.addEventListener 'load', =>
        @setGoalPixels @constructor.createPixelsFromImage image
      ,
        false

      # Initiate the loading.
      image.src = Meteor.absoluteUrl goalImageUrl

    # Create the component that will show the goal state.
    @engineComponent = new @constructor.EngineComponent
      spriteData: =>
        return unless goalPixels = @goalPixels()
        return unless spriteId = @spriteId()

        # Take same overall sprite data (bounds, palette) as sprite used for drawing, but exclude the pixels.
        spriteData = LOI.Assets.Sprite.documents.findOne spriteId,
          fields:
            'layers': false

        return unless spriteData

        # Replace pixels with the goal state.
        spriteData.layers = [pixels: goalPixels]

        spriteData

    @completed = new ComputedField =>
      # Compare goal pixels with current sprite pixels.
      return unless spritePixels = @sprite()?.layers[0].pixels
      return unless goalPixels = @goalPixels()
      return unless goalPixelsMap = @goalPixelsMap()
      return unless @palette()

      # Make sure enough pixels are even present. There might be more in case of background color pixels.
      return false if spritePixels.length < goalPixels.length

      if backgroundColor = @constructor.backgroundColor()
        # Convert background color to the same format as goal pixels.
        backgroundColor = directColor: backgroundColor unless backgroundColor.paletteColor
        backgroundColor.integerDirectColor = if backgroundColor.paletteColor then @_paletteToIntegerDirectColor backgroundColor.paletteColor else @_directToIntegerDirectColor backgroundColor.directColor

      for pixel in spritePixels
        goalPixel = goalPixelsMap[pixel.x]?[pixel.y] or backgroundColor

        # We must have a color to match against.
        return false unless goalPixel

        # If any of the pixels has a direct color, we need to translate the other one too.
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

  setGoalPixels: (goalPixels) ->
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
    @engineComponent
  ]

  styleClasses: ->
    classes = [
      'completed' if @completed()
    ]

    _.without(classes, undefined).join ' '

  minClipboardScale: -> @constructor.minClipboardScale?()
  maxClipboardScale: -> @constructor.maxClipboardScale?()
