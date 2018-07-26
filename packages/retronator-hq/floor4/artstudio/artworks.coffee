LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Artworks extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.ArtStudio.Artworks'
  @fullName: -> "artworks"
  @description: ->
    "
      There are various traditional artworks and prints all over the studio.
    "

  @initialize()
