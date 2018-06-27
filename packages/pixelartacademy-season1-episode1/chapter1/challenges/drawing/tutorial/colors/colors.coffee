AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Colors extends C1.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Colors'

  @fullName: -> "Tutorial: Colors"

  @initialize()

  @completed: ->
    @isAssetCompleted @QuickColorPicking

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
        @quickColorPicking ?= Tracker.nonreactive => new @constructor.QuickColorPicking @
        assets.push @quickColorPicking

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @colorSwatches?.destroy()
    @colorPicking?.destroy()
    @quickColorPicking?.destroy()

    @assets.stop()
    