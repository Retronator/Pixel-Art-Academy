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

    directionActions = {}

    for directionKey, locationClass of exits when locationClass
      presentDirectionKeys.push directionKey

      do (directionKey, locationClass) =>
        action = => LOI.adventure.goToLocation locationClass

        # Store action so that other alternatives can use it. Our parser will remove options that use the same action.
        directionActions[_.thingId locationClass] = action

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.GoToDirection, directionKey]
          action: action

        # Also do an exact phrase with the go verb to avoid ignoring
        # direction keys that are also prepositions (such as 'in').
        commandResponse.onExactPhrase
          form: [Vocabulary.Keys.Verbs.GoToDirection, directionKey]
          action: action
          priority: 1

        commandResponse.onExactPhrase
          form: [directionKey]
          action: action
          priority: 1

    # Register the rest of the directions to give negative feedback.
    allDirectionKeys = _.values Vocabulary.Keys.Directions

    absentDirectionKeys = _.difference allDirectionKeys, presentDirectionKeys

    for directionKey in absentDirectionKeys
      do (directionKey) =>
        directionTranslation = LOI.adventure.parser.vocabulary.getPhrases(directionKey)[0]

        # Prepare the feedback action.
        action = =>
          line = "You cannot go #{directionTranslation}."

          # Special line if you're trying to go inside, but can't, and the way to get here was to go inside.
          if directionKey is Vocabulary.Keys.Directions.In and Vocabulary.Keys.Directions.Out in presentDirectionKeys
            line = "You are already inside."

          # Same for outside.
          if directionKey is Vocabulary.Keys.Directions.Out and Vocabulary.Keys.Directions.In in presentDirectionKeys
            line = "You are already outside."

          LOI.adventure.director.startNode new Nodes.InterfaceLine line: line

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.GoToDirection, directionKey]
          action: action

        commandResponse.onExactPhrase
          form: [directionKey]
          action: action

    # Next up wire going to the location by name.
    for locationId, avatar of location.exitAvatarsByLocationId()
      do (locationId, avatar) =>
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.GoToLocationName, avatar]
          action: directionActions[locationId]

    # If there is only one way out of the location, wire exiting the location.
    locationClasses = _.uniq _.map presentDirectionKeys, (directionKey) -> exits[directionKey]
    onlyExitLocation = if locationClasses.length is 1 then locationClasses[0] else null

    if onlyExitLocation
      action = directionActions[_.thingId onlyExitLocation]

      commandResponse.onExactPhrase
        form: [Vocabulary.Keys.Verbs.ExitLocation]
        action: action
        priority: 1

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.ExitLocation, location.avatar]
        action: action
