AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.ConversationListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    # Only characters can have conversations.
    return unless characterId = LOI.characterId()

    timelineId = LOI.adventure.currentTimelineId()
    locationId = LOI.adventure.currentLocationId()
    
    sayAction = (likelyAction) =>
      # Remove text from narrative since it will be displayed from the script.
      LOI.adventure.interface.narrative.removeLastCommand()

      message = _.trim _.last(likelyAction.translatedForm), '"'

      # See if we're in a memory context or one is advertised.
      context = LOI.adventure.currentContext()
      advertisedContext = LOI.adventure.advertisedContext()

      if context instanceof LOI.Memory.Context
        # Place action into the context's memory.
        memoryId = context.memoryId
        contextId = context.id()

      else if advertisedContext instanceof LOI.Memory.Context
        # Place action into advertised context's memory.
        memoryId = advertisedContext.memoryId
        contextId = advertisedContext.id()

        # Enter advertised context as well.
        LOI.adventure.enterContext advertisedContext

      else
        # We're not in a memory context yet. Create a new memory and enter its context.
        memoryId = Random.id()
        LOI.Memory.insert memoryId, timelineId, locationId

        context = new LOI.Memory.Contexts.Conversation memoryId
        contextId = context.id()
        LOI.adventure.enterContext context

      # Add the Say action.
      situation = {timelineId, locationId, contextId}

      content =
        say:
          text: message
          
      LOI.Memory.Action.do LOI.Memory.Actions.Say.type, characterId, situation, content, memoryId

    # Create a quoted phrase to catch anything included with the say command.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Say, '""']
      action: sayAction

    # Allow also just quotes.
    commandResponse.onPhrase
      form: ['""']
      action: sayAction

    # Listening enters you into the currently advertised context.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Listen]
      action: =>
        # See if a memory context is advertised and enter it.
        advertisedContext = LOI.adventure.advertisedContext()

        if advertisedContext instanceof LOI.Memory.Context
          LOI.adventure.enterContext advertisedContext

        else
          LOI.adventure.interface.narrative.addText "Listen to who?"
