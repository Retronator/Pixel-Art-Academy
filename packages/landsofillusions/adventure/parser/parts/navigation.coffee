AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseNavigation: (command) ->
    exits = @location.state().exits
    return unless exits

    # See if any of the words is a direction of one of the exits. Go over all directions.
    for directionKey, locationId of exits when locationId
      # Find words that describe this direction.
      directionWords = @vocabulary.getWords directionKey
  
      # Did the user say this word?
      if command.has directionWords
        # Yes, the user is trying to go to this direction!
        LOI.Adventure.goToLocation locationId
        return true
  
    # See if we have any of the verbs to go to a location.
    goWords = @vocabulary.getWords @Vocabulary.Keys.Verbs.Go

    console.log "We are searching for 'go' words, which for the current language are", goWords, "and we have the command", command if LOI.debug

    if command.has goWords
      console.log "We found the 'go' word." if LOI.debug

      # Yes, the user is trying to go somewhere. Did they name any of the locations?
      for directionKey, locationId of exits when locationId
        translationHandle = @location.exitsTranslationSubscriptions()[locationId]

        console.log "For direction", directionKey, "that points to location with ID", locationId, "we have translation handle", translationHandle, "which is ready?", translationHandle.ready() if LOI.debug

        shortName = AB.translate(translationHandle, LOI.Avatar.translationKeys.shortName).text

        console.log "Short name for this location is", shortName if LOI.debug
  
        if command.has shortName
          # We found the name of this location! Let's go there.
          LOI.Adventure.goToLocation locationId
          return true
