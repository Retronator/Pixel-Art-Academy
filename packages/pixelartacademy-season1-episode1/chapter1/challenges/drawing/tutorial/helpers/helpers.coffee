AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Helpers extends C1.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Helpers'

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

      if @_assetsCompleted @lines
        @references ?= Tracker.nonreactive => new @constructor.References @
        assets.push @references

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
