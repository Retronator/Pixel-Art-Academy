RA = Retronator.Accounts
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.publish (characterId) ->
  check characterId, Match.DocumentId

  C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.query characterId

C1.CoordinatorAddress.CharacterIntroduction.all.publish ->
  RA.authorizeAdmin()

  LOI.Memory.Action.documents.find type: C1.CoordinatorAddress.CharacterIntroduction.type
