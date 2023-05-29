AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers'

  @fullName: -> "Pixel art tools: helpers"

  @initialize()

  @completed: ->
    @isAssetCompleted @Lines

  # Methods

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      assets = []

      @zoom ?= Tracker.nonreactive => new @constructor.Zoom @
      assets.push @zoom

      if @_assetsCompleted @zoom
        @moveCanvas ?= Tracker.nonreactive => new @constructor.MoveCanvas @
        assets.push @moveCanvas

      if @_assetsCompleted @moveCanvas
        @undoRedo ?= Tracker.nonreactive => new @constructor.UndoRedo @
        assets.push @undoRedo

      if @_assetsCompleted @undoRedo
        @lines ?= Tracker.nonreactive => new @constructor.Lines @
        assets.push @lines

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