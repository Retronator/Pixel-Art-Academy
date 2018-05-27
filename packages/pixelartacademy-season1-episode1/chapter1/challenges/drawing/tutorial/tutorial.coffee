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

      if @eraser in assets and @eraser.completed()
        @colorFill ?= new @constructor.ColorFill @
        assets.push @colorFill

      if @colorFill in assets and @colorFill.completed()
        @colorFill2 ?= new @constructor.ColorFill2 @
        assets.push @colorFill2

      if @colorFill2 in assets and @colorFill2.completed()
        @blackAndWhite ?= new @constructor.BlackAndWhite @
        assets.push @blackAndWhite

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
