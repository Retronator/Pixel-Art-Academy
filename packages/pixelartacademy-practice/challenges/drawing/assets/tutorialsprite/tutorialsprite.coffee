AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Project.Asset.Sprite
  @id: -> 'PixelArtAcademy.Practice.Challenges.Drawing.TutorialSprite'

  # Methods

  @create: new AB.Method name: "#{@id()}.create"
  @reset: new AB.Method name: "#{@id()}.reset"

  @createPixelsFromBitmap: (bitmap) ->
    lines = bitmap.match /^\|?(.*)/gm
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

  completed: ->
    # Compare goal pixels with current sprite pixels.
    return unless spritePixels = @sprite()?.layers[0].pixels

    return unless @goalPixels.length is spritePixels.length

    for goalPixel in @goalPixels
      return unless _.find spritePixels, (spritePixel) => EJSON.equals goalPixel, spritePixel

    true
