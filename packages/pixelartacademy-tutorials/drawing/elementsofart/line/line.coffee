AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line extends PAA.Tutorials.Drawing.ElementsOfArt
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line'

  @fullName: -> "Elements of art: line"

  @initialize()
  
  @assets: -> [
    @StraightLines
    @CurvedLines
    @BrokenLines
    @BrokenLines2
    @Outlines
  ]

  # Methods

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      assets = []

      @straightLines ?= Tracker.nonreactive => new @constructor.StraightLines @
      assets.unshift @straightLines
      
      if @_assetsCompleted @straightLines
        @curvedLines ?= Tracker.nonreactive => new @constructor.CurvedLines @
        assets.unshift @curvedLines
        
      if @_assetsCompleted @curvedLines
        @brokenLines ?= Tracker.nonreactive => new @constructor.BrokenLines @
        assets.unshift @brokenLines
        
      if @_assetsCompleted @brokenLines
        @brokenLines2 ?= Tracker.nonreactive => new @constructor.BrokenLines2 @
        assets.unshift @brokenLines2
        
      if @_assetsCompleted @brokenLines2
        @outlines ?= Tracker.nonreactive => new @constructor.Outlines @
        assets.unshift @outlines

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @straightLines?.destroy()
    @curvedLines?.destroy()
    @brokenLines?.destroy()
    @brokenLines2?.destroy()
    @outlines?.destroy()

    @assets.stop()
