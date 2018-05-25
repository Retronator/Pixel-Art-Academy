AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial extends LOI.Adventure.Thing
  # READONLY
  # assets: array of assets that are part of this tutorial
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #
  #   SPRITE
  #   sprite: reference to a sprite
  #     _id
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial'

  @fullName: -> "Tutorial"

  @initialize()

  # Methods

  constructor: ->
    super

    @assets = new ComputedField =>
      assets = []

      @pencil ?= new @constructor.Pencil @
      assets.push @pencil
      
      if @pencil.completed()
        @eraser ?= new @constructor.Eraser @
        assets.push @eraser

      assets
    ,
      # We consider our content has changed only when the array values differ.
      (a, b) =>
        return unless a.length is b.length

        for asset, index in a
          return unless asset is b[index]

        true
    ,
      true

  destroy: ->
    @pencil.destroy()
    @assets.stop()

  assetsData: ->
    return unless LOI.adventure.readOnlyGameState()
    
    # We need to mimic a project, so we need to provide the data. If no state is 
    # set, we send a dummy object to let the sprite know we've loaded the state.
    @readOnlyState('assets') or []
    
  # Assets

  class @Pencil extends PAA.Practice.Challenges.Drawing.TutorialSprite
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Pencil'

    @displayName: -> "Pencil"

    @description: -> """
      Using the pencil, fill the pixels with the dot in the middle.
      Click start when you're ready. If you make a mistake, come back and reset the challenge.
    """

    @fixedDimensions: -> width: 11, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
      
    @bitmap: -> "" # Empty sprite

    @goalBitmap: -> """
      |  0      0
      |   0    0
      |  00000000
      | 00 0000 00
      |000000000000
      |0 00000000 0
      |0 0      0 0
      |   00  00
    """

    @initialize()

  class @Eraser extends PAA.Practice.Challenges.Drawing.TutorialSprite
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Eraser'

    @displayName: -> "Eraser"

    @description: -> """
      Using the eraser, remove the pixels with the dot in the middle.
      If you delete too much, simply use the pencil to draw things back in.
    """

    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

    @bitmap: -> """
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
    """

    @goalBitmap: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      |  0  0
      | 0 00 0
      |0 0  0 0
    """

    @initialize()
