LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

class C1.Groups.AdmissionsStudyGroup.A extends C1.Groups.AdmissionsStudyGroup
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.A'
  @location: -> HQ.ArtStudio

  @coordinator: -> HQ.Actors.Alexandra
  @npcMembers: -> [
    PAA.Actors.Ty
    PAA.Actors.Ace
  ]

  @initialize()
