AE = Artificial.Everywhere
LOI = LandsOfIllusions
RA = Retronator.Accounts

ignoreFields =
  events: false
  lastUpdated: false
  nextSimulateTime: false

LOI.GameState.forProfile.publish (profileId) ->
  check profileId, Match.DocumentId
  return unless @userId

  # Make sure the profile belongs to the user or a user's character.
  character = LOI.Character.documents.findOne profileId
  
  userId = character?.user._id or profileId
  
  unless userId is @userId
    throw new AE.UnauthorizedException "The profile does not belong to the logged in user."

  # Before we send the document, simulate it to current time.
  gameState = LOI.GameState.documents.findOne 'profileId': profileId
  throw new AE.InvalidOperationException "Profile does not have a game state." unless gameState

  LOI.Simulation.Server.simulateGameState gameState

  LOI.GameState.documents.find
    'profileId': profileId
  ,
    fields: ignoreFields
