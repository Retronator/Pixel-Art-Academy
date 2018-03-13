AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Delta = require 'quill-delta'

PAA.Practice.Journal.Entry.insert.method (entryId, journalId, contentDeltaOperations, order) ->
  check entryId, Match.DocumentId
  check journalId, Match.DocumentId
  check contentDeltaOperations, Array
  check order, Match.OptionalOrNull Number

  # Find the journal.
  journal = PAA.Practice.Journal.documents.findOne journalId
  throw new AE.ArgumentException "Journal does not exist." unless journal
  
  # Make sure the user can perform this character action.
  LOI.Authorize.characterAction journal.character._id

  # Create a delta object to catch any potential errors with the operations array.
  contentDelta = new Delta contentDeltaOperations
  
  # Place at the end of the journal if order is not specified.
  unless order?
    lastEntry = PAA.Practice.Journal.Entry.documents.findOne
      'journal._id': journalId
    ,
      sort:
        order: -1

    # Place it after the last entry (or at the start if it's the first entry).
    order = (lastEntry?.order + 1) or 0

  # We create a new check-in for the given character.
  entry =
    _id: entryId
    journal:
      _id: journalId
    time: new Date()
    order: order
    content: contentDelta.ops

  PAA.Practice.Journal.Entry.documents.insert entry

PAA.Practice.Journal.Entry.remove.method (entryId) ->
  check entryId, Match.DocumentId

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction entryId

  PAA.Practice.Journal.Entry.documents.remove entryId

PAA.Practice.Journal.Entry.updateOrder.method (entryId, order) ->
  check entryId, Match.DocumentId
  check order, Number

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction entryId

  # Associate the artist with the character.
  PAA.Practice.Journal.Entry.documents.update entryId, $set: {order}

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

PAA.Practice.Journal.Entry.replaceContent.method (entryId, contentDeltaOperations) ->
  check entryId, Match.DocumentId
  check contentDeltaOperations, Array

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction entryId

  # Create a delta object to catch any potential errors with the operations array.
  contentDelta = new Delta contentDeltaOperations

  # Update the text.
  PAA.Practice.Journal.Entry.documents.update entryId,
    $set:
      content: contentDelta.ops

PAA.Practice.Journal.Entry.newMemory.method (entryId, characterId) ->
  check entryId, Match.DocumentId
  check characterId, Match.DocumentId

  # Make sure the entry exists.
  entry = PAA.Practice.Journal.Entry.documents.findOne entryId
  throw new AE.ArgumentException "Entry not found." unless entry

  # Make sure the user controls the character that's starting the memory.
  LOI.Authorize.characterAction characterId

  # Create a new memory.
  memoryId = LOI.Memory.insert()

  # Associate the memory to this entry.
  PAA.Practice.Journal.Entry.documents.update entryId,
    $addToSet:
      memories:
        _id: memoryId

authorizeJournalAction = (entryId) ->
  entry = PAA.Practice.Journal.Entry.documents.findOne entryId
  throw new AE.ArgumentException "Entry does not exist." unless entry

  journal = PAA.Practice.Journal.documents.findOne entry.journal._id
  throw new AE.ArgumentException "Journal does not exist." unless journal

  LOI.Authorize.characterAction journal.character._id

  # Return entry.
  entry
