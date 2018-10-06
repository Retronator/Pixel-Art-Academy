LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest.Retro extends HQ.Actors.Retro
  @initialize()
  
  @descriptiveName: ->
    "#{super} He is sitting behind a table with ![markers](pick up marker) and name tag ![stickers](pick up stickers)."
