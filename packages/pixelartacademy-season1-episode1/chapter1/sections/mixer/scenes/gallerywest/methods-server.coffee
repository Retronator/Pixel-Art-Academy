AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.Mixer.GalleryWest.joinGroup.method (characterId, groupId) ->
  check characterId, Match.DocumentId
  check groupId, String

  LOI.Authorize.player()
  {gameState} = LOI.Authorize.characterGameplayAction characterId

  # Add membership to this group.
  LOI.Character.Membership.addMember characterId, groupId
  
  # Set study group in the game state.
  _.nestedProperty gameState.readOnlyState, "things.#{C1.id()}.studyGroupId", groupId

  LOI.GameState.documents.update gameState._id,
    $set:
      readOnlyState: gameState.readOnlyState
