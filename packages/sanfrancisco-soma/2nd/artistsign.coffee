LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.SecondStreet.ArtistSign extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.Soma.SecondStreet.ArtistSign'
  @fullName: -> "featured artist sign"
  @shortName: -> "sign"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      Through the glass front of the HQ you can see a sign announcing the current featured artist.
      You can go ![inside](inside) to look at the artworks.
    "

  @initialize()
