AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics'

  @fullName: -> "Pixel art tools: basics"

  @initialize()

  @assets: -> [
    @Pencil
    @Eraser
    @ColorFill
    @ColorFill2
    @ColorFill3
    @BasicTools
    @Shortcuts
    @References
  ]

  # Methods

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      assets = []

      @pencil ?= Tracker.nonreactive => new @constructor.Pencil @
      assets.unshift @pencil

      if @_assetsCompleted @pencil
        @eraser ?= Tracker.nonreactive => new @constructor.Eraser @
        assets.unshift @eraser

      if @_assetsCompleted @eraser
        @colorFill ?= Tracker.nonreactive => new @constructor.ColorFill @
        assets.unshift @colorFill

      if @_assetsCompleted @colorFill
        @colorFill2 ?= Tracker.nonreactive => new @constructor.ColorFill2 @
        assets.unshift @colorFill2

      if @_assetsCompleted @colorFill2
        @colorFill3 ?= Tracker.nonreactive => new @constructor.ColorFill3 @
        assets.unshift @colorFill3

      if @_assetsCompleted @colorFill3
        @basicTools ?= Tracker.nonreactive => new @constructor.BasicTools @
        assets.unshift @basicTools

      if @_assetsCompleted @basicTools
        @shortcuts ?= Tracker.nonreactive => new @constructor.Shortcuts @
        assets.unshift @shortcuts
  
      if @_assetsCompleted @shortcuts
        @references ?= Tracker.nonreactive => new @constructor.References @
        assets.unshift @references

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
