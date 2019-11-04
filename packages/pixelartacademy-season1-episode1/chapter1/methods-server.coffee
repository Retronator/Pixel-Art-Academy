AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.applyCharacter.method (characterId, contactEmail) ->
  check characterId, Match.DocumentId
  check contactEmail, String

  LOI.Authorize.player()
  {character, gameState} = LOI.Authorize.characterGameplayAction characterId

  # Change character's contact email.
  LOI.Character.updateContactEmail characterId, contactEmail

  # Set the applied field on the application state.
  _.nestedProperty gameState.readOnlyState, "things.#{C1.id()}.application.applied", true

  # Set the date.
  time = gameState.state.gameTime
  _.nestedProperty gameState.readOnlyState, "things.#{C1.id()}.application.applicationTime", time
  _.nestedProperty gameState.readOnlyState, "things.#{C1.id()}.application.applicationRealTime", Date.now()

  LOI.GameState.documents.update gameState._id,
    $set:
      readOnlyState: gameState.readOnlyState
      
  # Fetch the character again to get their contact email.
  character = LOI.Character.documents.findOne characterId

  # TODO: Add support for gating of applicants. Currently everyone gets accepted.

  # Send application email.
  C1.Items.ApplicationEmail.send character

  # Accept applications that meet chapter requirement.
  user = Retronator.user()
  meetsRequirements = user.hasItem C1.accessRequirement()

  C1.acceptCharacter characterId if meetsRequirements
