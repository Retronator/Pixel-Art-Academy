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

      # See if we're in a memory context.
      context = LOI.adventure.currentContext()

      if context instanceof LOI.Memory.Context
        # Place action into the context's memory.
        memoryId = context.memoryId
        contextId = context.id()

      else
        # We're not in a memory context yet. Create a new memory and enter its context.
        memoryId = Random.id()
        LOI.Memory.insert memoryId, timelineId, locationId

        # We use the plain memory which is just a conversation.
        context = new LOI.Memory.Context memoryId
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
