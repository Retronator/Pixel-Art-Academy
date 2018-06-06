AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Project.Asset.Sprite
  @id: -> 'PixelArtAcademy.Practice.Challenges.Drawing.TutorialSprite'

  # Methods

  @create: new AB.Method name: "#{@id()}.create"
  @reset: new AB.Method name: "#{@id()}.reset"

  @createPixelsFromBitmap: (bitmap) ->
    # We need to quit if we get an empty string since the regex would never quit on it.
    return [] unless bitmap?.length

    regExp = /^\|?(.*)/gm
    lines = (match[1] while match = regExp.exec bitmap)

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

  constructor: ->
    super
    
    @tutorial = @project

    # Create sprite automatically if it is not present.
    Tracker.autorun (computation) =>
      return unless assets = @tutorial.assetsData()
      computation.stop()

      # All is good if we have the asset.
      return if _.find assets, (asset) => asset.id is @id()

      # We need to create the sprite by calling reset.
      @constructor.create LOI.characterId(), @tutorial.id(), @id()

    @goalPixels = @constructor.createPixelsFromBitmap @constructor.goalBitmap()

    @engineComponent = new @constructor.EngineComponent
      spriteData: =>
        return unless spriteId = @spriteId()

        # Take same overall sprite data (bounds, palette) as sprite used for drawing, but exclude the pixels.
        spriteData = LOI.Assets.Sprite.documents.findOne spriteId,
          fields:
            'layers': false

        return unless spriteData

        # Replace pixels with the goal state.
        spriteData.layers = [pixels: @goalPixels]

        spriteData

    @briefComponent = new @constructor.BriefComponent @

    @completed = new ComputedField =>
      # Compare goal pixels with current sprite pixels.
      return unless spritePixels = @sprite()?.layers[0].pixels

      return false unless @goalPixels.length is spritePixels.length

      for goalPixel in @goalPixels
        return false unless _.find spritePixels, (spritePixel) => EJSON.equals goalPixel, spritePixel

      true

    # Save completed value to tutorial state.
    Tracker.autorun (computation) =>
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

  editorDrawComponents: -> [
    @engineComponent
  ]

  styleClasses: ->
    classes = [
      'completed' if @completed()
    ]

    _.without(classes, undefined).join ' '
