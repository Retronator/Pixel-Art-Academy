AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.EssentialTools extends C1.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.EssentialTools'

  @fullName: -> "Tutorial: Basics"

  @initialize()

  # Methods

  constructor: ->
    super

    @assets = new ComputedField =>
      assets = []

      @pencil ?= Tracker.nonreactive => new @constructor.Pencil @
      assets.push @pencil

      if @_assetsCompleted @pencil
        @eraser ?= Tracker.nonreactive => new @constructor.Eraser @
        assets.push @eraser

        @colorFill ?= Tracker.nonreactive => new @constructor.ColorFill @
        assets.push @colorFill

      if @_assetsCompleted @pencil, @eraser, @colorFill
        @colorFill2 ?= Tracker.nonreactive => new @constructor.ColorFill2 @
        assets.push @colorFill2

      if @_assetsCompleted @colorFill2
        @final ?= Tracker.nonreactive => new @constructor.Final @
        assets.push @final

      if @_assetsCompleted @final
        @shortcuts ?= Tracker.nonreactive => new @constructor.Shortcuts @
        assets.push @shortcuts

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @pencil?.destroy()
    @eraser?.destroy()
    @colorFill?.destroy()
    @colorFill2?.destroy()
    @final?.destroy()
    @shortcuts?.destroy()
    
    @assets.stop()
