AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers'

  @fullName: -> "Pixel art tools: helpers"

  @initialize()

  @assets: -> [
    @Zoom
    @MoveCanvas
    @UndoRedo
    @Lines
  ]

  # Methods

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      assets = []
      
      @zoom ?= Tracker.nonreactive => new @constructor.Zoom @
      assets.unshift @zoom
  
      if @_assetsCompleted @zoom
        @lines ?= Tracker.nonreactive => new @constructor.Lines @
        assets.unshift @lines

      if @_assetsCompleted @lines
        @moveCanvas ?= Tracker.nonreactive => new @constructor.MoveCanvas @
        assets.unshift @moveCanvas

      if @_assetsCompleted @moveCanvas
        @undoRedo ?= Tracker.nonreactive => new @constructor.UndoRedo @
        assets.unshift @undoRedo

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @zoom?.destroy()
    @moveCanvas?.destroy()
    @undoRedo?.destroy()
    @lines?.destroy()

    @assets.stop()
