AE = Artificial.Everywhere
LOI = LandsOfIllusions
RA = Retronator.Accounts

ignoreFields =
  events: false
  lastUpdated: false
  nextSimulateTime: false

LOI.GameState.forCurrentUser.publish ->
  return unless @userId

  # Before we send the document, simulate it to current time.
  gameState = LOI.GameState.documents.findOne 'user._id': @userId
  LOI.Simulation.Server.simulateGameState gameState
  
  LOI.GameState.documents.find
    'user._id': @userId
  ,
    fields: ignoreFields

LOI.GameState.forCharacter.publish (characterId) ->
  check characterId, Match.DocumentId
  return unless @userId

  # Make sure the character belongs to the user.
  character = LOI.Character.documents.findOne characterId

  unless character?.user._id is @userId
    throw new AE.UnauthorizedException "The character does not belong to the logged in user."

  # Before we send the document, simulate it to current time.
  gameState = LOI.GameState.documents.findOne 'character._id': characterId
  LOI.Simulation.Server.simulateGameState gameState

  LOI.GameState.documents.find
    'character._id': characterId
  ,
    fields: ignoreFields

