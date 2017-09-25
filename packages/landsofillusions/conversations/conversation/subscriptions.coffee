LOI = LandsOfIllusions

LOI.Conversations.Conversation.forId.publish (conversationId) ->
  check conversationId, Match.DocumentId
  
  LOI.Conversations.Conversation.documents.find conversationId
