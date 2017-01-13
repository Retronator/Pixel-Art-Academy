AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class LOI.Parser.NavigationListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    location = LOI.adventure.currentLocation()
    exits = location.exits()
    return unless exits

    # Register possible direction phrases as phrase actions.
    presentDirectionKeys = []

    for directionKey, location of exits when location
      presentDirectionKeys.push directionKey

      do (directionKey, location) =>
        commandResponse.onExactPhrase
          phraseKey: directionKey
          idealForm: =>
            commandResponse.options.parser.vocabulary.getPhrases(directionKey)[0]
          action: =>
            LOI.adventure.goToLocation location.id()

    # Register the rest of the directions to give negative feedback.
    allDirectionKeys = _.values Vocabulary.Keys.Directions

    absentDirectionKeys = _.difference allDirectionKeys, presentDirectionKeys

    for directionKey in absentDirectionKeys
      do (directionKey) =>
        directionTranslation = LOI.adventure.parser.vocabulary.getPhrases(directionKey)[0]

        commandResponse.onExactPhrase
          phraseKey: directionKey
          idealForm: => directionTranslation
          action: =>
            line = "You cannot go #{directionTranslation}."

            # Special line if you're trying to go inside, but can't, and the way to get here was to go inside.
            if directionKey is Vocabulary.Keys.Directions.In and Vocabulary.Keys.Directions.Out in presentDirectionKeys
              line = "You are already inside."

            # Same for outside.
            if directionKey is Vocabulary.Keys.Directions.Out and Vocabulary.Keys.Directions.In in presentDirectionKeys
              line = "You are already outside."

            LOI.adventure.director.startNode new Nodes.InterfaceLine line: line

    return

    # TODO

    # No direction was named. See if we can go to location by name.
    goPhrases = commandResponse.options.parser.vocabulary.getPhrases Vocabulary.Keys.Verbs.Go
    hasGoPhrases = command.has goPhrases

    console.log "We are searching for 'go' phrases, which for the current language are", goPhrases, "and we have the command", command if LOI.debug

    # Did they name any of the locations?
    for directionKey, locationId of exits when locationId
      translationHandle = @location.exitsTranslationSubscriptions()[locationId]

      console.log "For direction", directionKey, "that points to location with ID", locationId, "we have translation handle", translationHandle, "which is ready?", translationHandle.ready() if LOI.debug

      shortName = AB.translate(translationHandle, LOI.Avatar.translationKeys.shortName).text

      console.log "Short name for this location is", shortName if LOI.debug

      if command.has shortName
        # We found the name of this location! It can either be named without anything else, or with the go phrases.
        justLocation = command.is shortName

        if hasGoPhrases or justLocation
          # Let's go there.
          LOI.adventure.goToLocation locationId
          return true
