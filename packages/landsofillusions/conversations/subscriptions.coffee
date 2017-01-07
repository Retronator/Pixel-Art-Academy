LOI = LandsOfIllusions

Meteor.publish 'LandsOfIllusions.Conversations.Conversation', (conversationId) ->
  LOI.Conversations.Conversation.documents.findOne conversationId

Meteor.publish 'LandsOfIllusions.Conversations.Line.linesForConversation', (conversationId) ->
  LOI.Conversations.Line.documents.find
    'conversation._id': conversationId
