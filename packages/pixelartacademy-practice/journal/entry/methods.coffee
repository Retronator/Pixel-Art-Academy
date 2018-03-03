AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Delta = require 'quill-delta'

PAA.Practice.Journal.Entry.insert.method (entryId, journalId, time, timezoneOffset, language, contentDeltaOperations) ->
  check entryId, Match.DocumentId
  check journalId, Match.DocumentId
  check time, Date
  check timezoneOffset, Match.Integer
  check language, String
  check contentDeltaOperations, Array

  # Find the journal.
  journal = PAA.Practice.Journal.documents.findOne journalId
  throw new AE.ArgumentException "Journal does not exist." unless journal
  
  # Make sure the user can perform this character action.
  LOI.Authorize.characterAction journal.character._id

  # Create a delta object to catch any potential errors with the operations array.
  contentDelta = new Delta contentDeltaOperations

  # We create a new check-in for the given character.
  entry =
    _id: entryId
    time: time
    timezoneOffset: timezoneOffset
    language: language
    journal:
      _id: journalId
    content: contentDelta.ops

  PAA.Practice.Journal.Entry.documents.insert entry

PAA.Practice.Journal.Entry.remove.method (entryId) ->
  check entryId, Match.DocumentId

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction entryId

  PAA.Practice.Journal.Entry.documents.remove entryId

PAA.Practice.Journal.Entry.updateTime.method (entryId, time, timezone) ->
  check entryId, Match.DocumentId
  check time, Date
  check timezoneOffset, Match.Integer

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction entryId

  # Associate the artist with the character.
  PAA.Practice.Journal.Entry.documents.update entryId, $set: {time, timezoneOffset}

PAA.Practice.Journal.Entry.updateLanguage.method (entryId, language) ->
  check entryId, Match.DocumentId
  check language, String

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction entryId

  # Associate the artist with the character.
  PAA.Practice.Journal.Entry.documents.update entryId, $set: {language}
      
PAA.Practice.Journal.Entry.updateContent.method (entryId, updateDeltaOperations) ->
  check entryId, Match.DocumentId
  check updateDeltaOperations, Array

  # Make sure the check-in belongs to the current user.
  entry = authorizeJournalAction entryId

  contentDelta = new Delta entry.content
  updateDelta = new Delta updateDeltaOperations
  newContentDelta = contentDelta.compose updateDelta

  # Update the text.
  PAA.Practice.Journal.Entry.documents.update entryId,
    $set:
      content: newContentDelta.ops

PAA.Practice.Journal.Entry.newConversation.method (entryId, characterId, firstLineText) ->
  check entryId, Match.DocumentId
  check characterId, Match.DocumentId
  check firstLineText, Match.Optional String

  # Make sure the entry exists.
  entry = PAA.Practice.Journal.Entry.documents.findOne entryId
  throw new AE.ArgumentException "Entry not found." unless entry

  # Make sure the user controls the character that's starting the conversation.
  LOI.Authorize.characterAction characterId

  # Create a new conversation.
  conversationId = LOI.Conversations.Conversation.insert()

  # Associate the conversation to this entry.
  PAA.Practice.Journal.Entry.documents.update entryId,
    $addToSet:
      conversations: conversationId

  # Create the first line of conversation.
  LOI.Conversations.Line.insert conversationId, characterId, firstLineText

authorizeJournalAction = (entryId) ->
  entry = PAA.Practice.Journal.Entry.documents.findOne entryId
  throw new AE.ArgumentException "Entry does not exist." unless entry

  journal = PAA.Practice.Journal.documents.findOne entry.journal._id
  throw new AE.ArgumentException "Journal does not exist." unless journal

  LOI.Authorize.characterAction journal.character._id

  # Return entry.
  entry
