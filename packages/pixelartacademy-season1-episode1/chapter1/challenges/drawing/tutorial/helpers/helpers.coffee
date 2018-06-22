AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Helpers extends C1.Challenges.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Helpers'

  @fullName: -> "Tutorial: Helpers"

  @initialize()

  # Methods

  constructor: ->
    super

    @assets = new ComputedField =>
      assets = []

      @zoom ?= Tracker.nonreactive => new @constructor.Zoom @
      assets.push @zoom

      if @_assetsCompleted @zoom
        @references ?= Tracker.nonreactive => new @constructor.References @
        assets.push @references

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    @zoom?.destroy()
    @references?.destroy()

    @assets.stop()

  completed: ->
    finalAsset = _.find @assets(), (asset) => asset instanceof @constructor.References
    finalAsset?.completed()
