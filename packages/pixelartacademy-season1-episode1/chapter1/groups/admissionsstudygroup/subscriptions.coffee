LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.Groups.AdmissionsStudyGroup.groupMembers.publish (characterId, groupId) ->
  check characterId, Match.DocumentId
  check groupId, String

  LOI.Authorize.player()

  C1.Groups.AdmissionsStudyGroup.groupMembers.query characterId, groupId
