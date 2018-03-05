AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get entries for a certain journal.
PAA.Practice.Journal.Entry.forJournalId.publish (journalId, limit) ->
  check journalId, Match.DocumentId
  check limit, Match.Integer

  PAA.Practice.Journal.Entry.documents.find
    'journal._id': journalId
  ,
    limit: limit
    sort:
      order: -1

PAA.Practice.Journal.Entry.conversationsForEntryId.publish (entryId) ->
  check entryId, Match.DocumentId

  @autorun =>
    entry = PAA.Practice.Journal.Entry.documents.findOne entryId,
      fields:
        conversations: 1

    return LOI.Conversations.Conversation.documents.find
      _id:
        $in: entry?.conversations or []
