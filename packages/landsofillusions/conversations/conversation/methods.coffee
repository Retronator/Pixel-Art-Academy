LOI = LandsOfIllusions

LOI.Conversations.Conversation.insert.method ->
  # Only players can start conversations.
  LOI.Authorize.player()

  LOI.Conversations.Conversation.documents.insert {}
