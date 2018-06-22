AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Basics extends C1.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Basics'

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

      if @_assetsCompleted @eraser
        @colorFill ?= Tracker.nonreactive => new @constructor.ColorFill @
        assets.push @colorFill

      if @_assetsCompleted @colorFill
        @colorFill2 ?= Tracker.nonreactive => new @constructor.ColorFill2 @
        assets.push @colorFill2

      if @_assetsCompleted @colorFill2
        @basicTools ?= Tracker.nonreactive => new @constructor.BasicTools @
        assets.push @basicTools

      if @_assetsCompleted @basicTools
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
    @basicTools?.destroy()
    @shortcuts?.destroy()
    
    @assets.stop()

  completed: ->
    finalAsset = _.find @assets(), (asset) => asset instanceof @constructor.Shortcuts
    finalAsset?.completed()
