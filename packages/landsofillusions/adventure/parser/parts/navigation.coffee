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
      if command.is directionWords
        # Yes, the user is trying to go to this direction!
        LOI.Adventure.goToLocation locationId
        return true
  
    # No direction was named. See if we can go to location by name.
    goWords = @vocabulary.getWords @Vocabulary.Keys.Verbs.Go
    hasGoWords = command.has goWords

    console.log "We are searching for 'go' words, which for the current language are", goWords, "and we have the command", command if LOI.debug

    # Did they name any of the locations?
    for directionKey, locationId of exits when locationId
      translationHandle = @location.exitsTranslationSubscriptions()[locationId]

      console.log "For direction", directionKey, "that points to location with ID", locationId, "we have translation handle", translationHandle, "which is ready?", translationHandle.ready() if LOI.debug

      shortName = AB.translate(translationHandle, LOI.Avatar.translationKeys.shortName).text

      console.log "Short name for this location is", shortName if LOI.debug

      if command.has shortName
        # We found the name of this location! It can either be named without anything else, or with the go words.
        justLocation = command.is shortName

        if hasGoWords or justLocation
          # Let's go there.
          LOI.Adventure.goToLocation locationId
          return true
