AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.ColorTools extends C1.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.ColorTools'

  @fullName: -> "Tutorial: Color tools"

  @initialize()

  # Methods

  constructor: ->
    super

    @assets = new ComputedField =>
      assets = []

      @colorSwatches ?= Tracker.nonreactive => new @constructor.ColorSwatches @
      assets.push @colorSwatches

      if @_assetsCompleted @colorSwatches
        @colorPicking ?= Tracker.nonreactive => new @constructor.ColorPicking @
        assets.push @colorPicking

      if @_assetsCompleted @colorPicking
        @colorPickingShortcuts ?= Tracker.nonreactive => new @constructor.ColorPickingShortcuts @
        assets.push @colorPickingShortcuts

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @colorSwatches?.destroy()
    @colorPicking?.destroy()
    @colorPickingShortcuts?.destroy()

    @assets.stop()
