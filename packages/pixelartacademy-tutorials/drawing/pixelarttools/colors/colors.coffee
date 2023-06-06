AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Colors extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors'

  @fullName: -> "Pixel art tools: colors"

  @initialize()
  
  @pacManPaletteName: 'PAC-MAN'

  @assets: -> [
    @ColorSwatches
    @ColorPicking
    @QuickColorPicking
  ]

  # Methods

  constructor: ->
    super arguments...

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
