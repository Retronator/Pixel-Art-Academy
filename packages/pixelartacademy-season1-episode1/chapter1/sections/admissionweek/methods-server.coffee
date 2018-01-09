AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.AdmissionWeek.applyCharacter.method (characterId, contactEmail) ->
  check characterId, Match.DocumentId
  check contactEmail, String

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  # Character must be activated.
  character = LOI.Character.documents.findOne characterId
  throw new AE.InvalidOperationException "Character is not activated." unless character.activated

  characterGameState = LOI.GameState.documents.findOne 'character._id': characterId
  throw new AE.InvalidOperationException "Character does not have a game state." unless characterGameState

  # Change character's contact email.
  LOI.Character.updateContactEmail characterId, contactEmail

  # Set the applied field on the AdmissionWeek state.
  _.nestedProperty characterGameState.state, "things.#{C1.AdmissionWeek.id()}.applied", true

  LOI.GameState.documents.update characterGameState._id,
    $set:
      state: characterGameState.state
