AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class PAA.Season1.Episode1.Chapter1 extends PAA.Season1.Episode1.Chapter1
  # This is a server method to accept a character. No further checks are performed.
  @acceptCharacter: (characterId) ->
    characterGameState = LOI.GameState.documents.findOne 'character._id': characterId

    # Acceptance letter should come at 9 AM the next day.
    currentTime = new LOI.GameDate characterGameState.state.gameTime
    acceptanceTime = currentTime.next hours: 9

    # Add acceptance event (this call saves directly to database).
    characterGameState.addEvent
      type: @Events.ApplicationAccepted.type()
      gameTime: acceptanceTime.getTime()
