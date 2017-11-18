LOI = LandsOfIllusions

LOI.Conversations.Line.forConversation.publish (conversationId) ->
  check conversationId, Match.DocumentId

  LOI.Conversations.Line.documents.find
    'conversation._id': conversationId
