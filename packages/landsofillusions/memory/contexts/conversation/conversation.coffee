AB = Artificial.Babel
LOI = LandsOfIllusions

# Just a dummy class to semantically represent a plain conversation.
class LOI.Memory.Contexts.Conversation extends LOI.Memory.Context
  @id: -> 'LandsOfIllusions.Memory.Contexts.Conversation'

  @initialize()

  @description: -> "You engage in a conversation."

  @translations: ->
    startingAConversation: "_people_ _are_ starting a conversation."
    inTheMiddleOfConversation: "_people_ _are_ in the middle of a conversation."

  @createIntroDescriptionScript: (memory, people, nextNode, nodeOptions) ->
    # We know that a flashback of a memory will show only the last 5 actions.
    translationKey = if memory.actions.length > 5 then 'inTheMiddleOfConversation' else 'startingAConversation'

    description = AB.translate(@translationHandle, translationKey).text
    @_createDescriptionScript people, description, nextNode, nodeOptions
