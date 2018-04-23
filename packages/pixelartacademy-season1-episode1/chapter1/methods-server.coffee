AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.applyCharacter.method (characterId, contactEmail) ->
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

  # Set the applied field on the application state.
  _.nestedProperty characterGameState.readOnlyState, "things.#{C1.id()}.application.applied", true

  # Set the date.
  time = characterGameState.state.gameTime
  _.nestedProperty characterGameState.readOnlyState, "things.#{C1.id()}.application.applicationTime", time
  _.nestedProperty characterGameState.readOnlyState, "things.#{C1.id()}.application.applicationRealTime", Date.now()

  LOI.GameState.documents.update characterGameState._id,
    $set:
      readOnlyState: characterGameState.readOnlyState
      
  # Fetch the character again to get their contact email.
  character = LOI.Character.documents.findOne characterId

  # TODO: Add support for gating of applicants. Currently anyone with alpha access gets accepted.

  # Send application email. Contents will depend on whether user meets Chapter 1 access requirements.
  C1.Items.ApplicationEmail.send character

  # Accept applications that meet chapter requirement.
  user = Retronator.user()
  meetsRequirements = user.hasItem C1.accessRequirement()

  C1.acceptCharacter characterId if meetsRequirements
