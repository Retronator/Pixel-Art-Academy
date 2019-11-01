LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.AdmissionsStudyGroup.A extends C1.Groups.AdmissionsStudyGroup
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.A'
  @location: -> HQ.ArtStudio

  # Note: We use the art studio class of Alexandra so that removing her from other scenes works.
  @coordinator: -> HQ.ArtStudio.Alexandra
  @npcMembers: -> [
    PAA.Actors.Ty
    PAA.Actors.Ace
  ]

  @initialize()
