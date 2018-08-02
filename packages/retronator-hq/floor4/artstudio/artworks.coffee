LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Artworks extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.ArtStudio.Artworks'
  @fullName: -> "artworks"
  @descriptiveName: -> "Various traditional ![artworks](look at artworks)."
  @description: ->
    "
      Drawings, paintings, and prints of all kinds are found all around the studio.
    "

  @initialize()
