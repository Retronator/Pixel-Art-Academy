LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Cafe.Artworks extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Cafe.Artworks'
  @fullName: -> "featured artworks"
  @shortName: -> "artworks"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      You look at the brilliant pixel artworks, which can't be done justice with this text description.
      You'll have to wait until the gallery feature of the game is coded to really see them.
    "

  @initialize()
