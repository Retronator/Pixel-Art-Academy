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
      new @constructor.DescriptionListener
      new @constructor.LookLocationListener
    ]

  destroy: ->
    @vocabulary.destroy()

  ready: ->
    @vocabulary.ready()

  parse: (command) ->
    # Create a rich command object.
    command = new LOI.Parser.Command command

    # Report this command to analytics. Use command text as action and location ID as label.
    eventCategory = 'Adventure Command'
    eventAction = command.normalizedCommand
    eventLabel = LOI.adventure.currentLocationId()

    ga? 'send', 'event', eventCategory, eventAction, eventLabel
    
    # Get all possible likely actions from all the listeners.
    likelyActions = for listener in LOI.adventure.currentListeners()
      # Create the command response object.
      commandResponse = new @constructor.CommandResponse
        command: command
        parser: @

      # Ask the listener to set its response.
      listener.onCommand commandResponse

      # Process the response and command so that it creates possible candidate
      commandResponse.generateActions()

    # Pull all actions into one array.
    likelyActions = _.flatten likelyActions

    # We only have uncertain possibilities.
    @chooseLikelyAction likelyActions

  # Creates a node that performs the action of the likely command
  _createCallbackNode: (phraseAction) ->
    new Nodes.Callback
      callback: (complete) =>
        # First complete the callback so that it doesn't get handled again while action is running.
        complete()

        # Start the chosen action.
        result = phraseAction.action()

        if result is true
          LOI.adventure.interface.narrative.addText "OK."

  # Creates a node sequence that outputs the likely command to narrative and performs its action.
  _createCommandNodeSequence: (likelyAction) ->
    new Nodes.CommandLine
      replaceLastCommand: true
      line: _.capitalize @_createIdealForm likelyAction
      next: @_createCallbackNode likelyAction.phraseAction

  _createIdealForm: (likelyAction) ->
    # See if phrase action provides a method to generate the ideal form.
    return likelyAction.phraseAction.idealForm likelyAction if likelyAction.phraseAction.idealForm?

    # Otherwise we use the default which is just all form parts joined in order.
    # But we should auto-correct avatars if they require it.
    for formPart, index in likelyAction.phraseAction.form
      if formPart instanceof LOI.Avatar
        avatar = formPart

        switch avatar.nameAutoCorrectStyle()
          when LOI.Avatar.NameAutoCorrectStyle.Name
            # We need to auto-correct to at least short name, but full name if any of the non-short name words are used.
            formWords = _.words likelyAction.translatedForm
            shortNameWords = _.words avatar.shortName()

            allFormWordsAreInShortName = _.difference(shortNameWords, formWords).length is 0

            if allFormWordsAreInShortName
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
