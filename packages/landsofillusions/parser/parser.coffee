AB = Artificial.Babel
LOI = LandsOfIllusions

Nodes = null

class LOI.Parser
  constructor: (@options) ->
    # Nodes are not yet available when parser is defined, so we need to access them here.
    Nodes = LOI.Adventure.Script.Nodes

    # Set Vocabulary shorthand.
    @Vocabulary = LOI.Parser.Vocabulary

    # Make a new vocabulary instance.
    @vocabulary = new @Vocabulary
    
    # Create parser listeners.
    @listeners = [
      new @constructor.DebugListener
      new @constructor.NavigationListener
      new @constructor.ThingListener
      new @constructor.LookLocationListener
      new @constructor.ConversationListener
      new @constructor.AdvertisedContextListener
      new @constructor.HelpListener
      new @constructor.TalkingListener
      new @constructor.InteractionListener
    ]

  destroy: ->
    @vocabulary.destroy()

  ready: ->
    @vocabulary.ready()

  parse: (command) ->
    # Create a rich command object.
    command = new LOI.Parser.Command command

    # Get all command responses from all the listeners.
    commandResponses = for listener in LOI.adventure.currentListeners()
      # Create the command response object.
      commandResponse = new @constructor.CommandResponse
        command: command
        parser: @

      # Ask the listener to set its response.
      listener.onCommand commandResponse

      commandResponse

    # Get all possible likely actions from all the listeners.
    likelyActions = for commandResponse in commandResponses
      # Process the response and command so that it creates possible candidate actions.
      commandResponse.generateActions()

    # Pull all actions into one array.
    likelyActions = _.flatten likelyActions

    # Determine which action to perform.
    return if @chooseLikelyAction likelyActions

    # Seems we couldn't find a likely action. Try to see if we have an avatar match at least.
    likelyActions = for commandResponse in commandResponses
      # Process the response and command so that it creates possible candidate actions.
      commandResponse.generateAvatarActions()

    # Pull all actions into one array.
    likelyActions = _.flatten likelyActions

    # Determine which action to perform.
    return if @chooseLikelyAction likelyActions

    LOI.adventure.interface.narrative.addText "I can't do that."

  # Creates a node that performs the action of the likely command
  _createCallbackNode: (likelyAction) ->
    new Nodes.Callback
      callback: (complete) =>
        # First complete the callback so that it doesn't get handled again while action is running.
        complete()

        # Start the chosen action.
        result = likelyAction.phraseAction.action likelyAction

        if result is true
          LOI.adventure.interface.narrative.addText "OK."

        # Inform listeners that the action was executed.
        listener.onCommandExecuted likelyAction for listener in LOI.adventure.currentListeners()

  # Creates a node sequence that outputs the likely command to narrative and performs its action.
  _createCommandNodeSequence: (likelyAction) ->
    new Nodes.CommandLine
      replaceLastCommand: true
      line: _.upperFirst @_createIdealForm likelyAction
      next: @_createCallbackNode likelyAction

  _createIdealForm: (likelyAction, options = {}) ->
    # See if phrase action provides a method to generate the ideal form.
    return likelyAction.phraseAction.idealForm likelyAction if likelyAction.phraseAction.idealForm?

    # Otherwise we use the default which is just all form parts joined in order.
    # But we should auto-correct avatars if they require it.
    for formPart, index in likelyAction.phraseAction.form
      if formPart instanceof LOI.Avatar or formPart instanceof LOI.Adventure.Thing
        avatar = formPart

        if avatar.nameAutoCorrectStyle() is LOI.Avatar.NameAutoCorrectStyle.Name or options.fullNames
          # We need to auto-correct to at least short name, but full name if any of the non-short name words are used.
          formWords = _.words likelyAction.translatedForm
          shortNameWords = _.words _.toLower _.deburr avatar.shortName()

          allFormWordsAreInShortName = _.difference(shortNameWords, formWords).length is 0

          # TODO: Do not replace in translated form, because this messes up further calls if avatars use uppercase letters.
          if allFormWordsAreInShortName and not options.fullNames
            likelyAction.translatedForm[index] = avatar.shortName()

          else
            likelyAction.translatedForm[index] = avatar.fullName()

    # Add form parts together into the sentence, doing any word order substitutions if necessary.
    words = []

    i = 0
    while i < likelyAction.translatedForm.length
      formPart = likelyAction.translatedForm[i]
      partWords = formPart.split ' '

      # Replace underscore with the following form part.
      for word, j in partWords when word is '_'
        partWords[j] = likelyAction.translatedForm[i + 1]

        # Mark that we've used another part.
        i++

      # We're done with this part.
      words = words.concat partWords
      i++

    words.join ' '
