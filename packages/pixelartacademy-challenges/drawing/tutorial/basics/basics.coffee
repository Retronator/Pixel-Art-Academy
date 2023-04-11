AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Basics extends PAA.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Basics'

  @fullName: -> "Tutorial: Basics"

  @initialize()

  @completed: ->
    @isAssetCompleted @References

  # Methods

  constructor: ->
    super arguments...

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
        @colorFill3 ?= Tracker.nonreactive => new @constructor.ColorFill3 @
        assets.push @colorFill3

      if @_assetsCompleted @colorFill3
        @basicTools ?= Tracker.nonreactive => new @constructor.BasicTools @
        assets.push @basicTools

      if @_assetsCompleted @basicTools
        @shortcuts ?= Tracker.nonreactive => new @constructor.Shortcuts @
        assets.push @shortcuts
  
      if @_assetsCompleted @shortcuts
        @references ?= Tracker.nonreactive => new @constructor.References @
        assets.push @references

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
    @colorFill3?.destroy()
    @basicTools?.destroy()
    @shortcuts?.destroy()
    
    @assets.stop()
