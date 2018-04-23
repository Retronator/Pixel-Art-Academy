LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Soma = SanFrancisco.Soma

class C1.Groups.Family extends LOI.Adventure.Group
  # Uses character's behavior profile to determine NPC members.
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.Family'

  @fullName: -> "family"
  @location: -> Soma.ChinaBasinPark

  @initialize()
