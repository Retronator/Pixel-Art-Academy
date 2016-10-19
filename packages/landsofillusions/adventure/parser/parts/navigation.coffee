AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseNavigation: (command) ->
    # See if any of the words is a direction of one of the exits. Go over all directions.
    for directionKey, locationId of @location.exits()
      # Find words that describe this direction.
      directionWords = @vocabulary.getWords directionKey
  
      # Did the user say this word?
      if command.has directionWords
        # Yes, the user is trying to go to this direction!
        LOI.Adventure.goToLocation locationId
        return true
  
    # See if we have any of the verbs to go to a location.
    goWords = @vocabulary.getWords @Vocabulary.Keys.Verbs.Go
  
    if command.has goWords
      # Yes, the user is trying to go somewhere. Did they name any of the locations?
      for directionKey, locationId of @location.exits()
        translationHandle = @location.exitsTranslationSubscribtions[locationId]
        shortName = AB.translate(translationHandle, LOI.Adventure.Location.translationKeys.shortName).text
  
        if command.has shortName
          # We found the name of this location! Let's go there.
          LOI.Adventure.goToLocation locationId
          return true
