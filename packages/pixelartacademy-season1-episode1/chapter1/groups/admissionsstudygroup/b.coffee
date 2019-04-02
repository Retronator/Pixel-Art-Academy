LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.AdmissionsStudyGroup.B extends C1.Groups.AdmissionsStudyGroup
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.B'
  @location: -> HQ.Bookshelves

  @coordinator: -> HQ.Actors.Shelley
  @npcMembers: -> [
    PAA.Actors.Saanvi
    PAA.Actors.Lisa
  ]

  @initialize()
