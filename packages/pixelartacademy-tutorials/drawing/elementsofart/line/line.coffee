AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line extends PAA.Tutorials.Drawing.ElementsOfArt
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line'

  @fullName: -> "Elements of art: line"

  @initialize()
  
  @assets: -> [
    @BrokenLines
  ]

  # Methods

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      assets = []

      @brokenLines ?= Tracker.nonreactive => new @constructor.BrokenLines @
      assets.unshift @brokenLines

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @brokenLines?.destroy()

    @assets.stop()
