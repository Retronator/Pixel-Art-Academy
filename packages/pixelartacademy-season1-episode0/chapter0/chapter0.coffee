LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter0 extends LOI.Adventure.Chapter
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0'

  @sections: -> [
    @Start
  ]

  inventory: ->
    PAA.Season1.Episode0.Chapter1._inventory @
