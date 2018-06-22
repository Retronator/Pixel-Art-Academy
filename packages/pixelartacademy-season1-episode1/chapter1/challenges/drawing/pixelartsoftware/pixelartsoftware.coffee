LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware'

  @fullName: -> "Pixel art software"

  @initialize()

  @translations: ->
    noAssetsInstructions: """
      To make sure you are ready to complete pixel art drawing assignments, this challenge requires you to copy an
      existing game sprite in your editor of choice. First go to the Retronator HQ Gallery and talk to Corinne to
      obtain a reference image and further instructions.
    """

  noAssetsInstructions: ->
    @translations().noAssetsInstructions

  assetsData: ->
    []

  assets: ->
    []
