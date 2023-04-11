AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Helpers extends PAA.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Helpers'

  @fullName: -> "Tutorial: Helpers"

  @initialize()

  @completed: ->
    @isAssetCompleted @References

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
    @references?.destroy()

    @assets.stop()
