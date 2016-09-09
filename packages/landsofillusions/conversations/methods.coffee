LOI = LandsOfIllusions

Meteor.methods
  'LandsOfIllusions.Conversations.Conversation.insert': (conversationId) ->
    check conversationId, Match.OptionalOrNull Match.DocumentId

    # Only players can start conversations.
    LOI.Authorize.player()

    conversation = {}

    conversation._id = conversationId if conversationId

    LOI.Conversations.Conversation.documents.insert conversation

  'LandsOfIllusions.Conversations.Line.insert': (conversationId, characterId, text) ->
    check conversationId, Match.DocumentId
    check characterId, Match.DocumentId
    check text, String

    # Manipulating lines is a character action.
    LOI.Authorize.characterAction characterId

    # Conversation must exist.
    conversation = LOI.Conversations.Conversation.documents.findOne conversationId
    throw new Meteor.Error 'not-found', "Conversation not found." unless conversation

    LOI.Conversations.Line.documents.insert
      conversation:
        _id: conversationId
      character:
        _id: characterId
        # Insert name as well, to prevent "No Name" before de-normalization happens.
        name: LOI.Accounts.Character.documents.findOne(characterId).name
      text: text
      time: new Date()

  'LandsOfIllusions.Conversations.Line.changeText': (lineId, text) ->
    check lineId, Match.DocumentId
    check text, String

    # Make sure the user can change this line.
    authorizeLineAction lineId

    LOI.Conversations.Line.documents.update
      $set:
        text: text

authorizeLineAction = (lineId) ->
  # Line must exist.
  line = LOI.Conversations.Line.documents.findOne lineId
  throw new Meteor.Error 'not-found', "Line not found." unless line

  # Make sure the user controls the character of this line.
  LOI.Authorize.characterAction line.character._id
