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

# Get practice check-ins for a certain date range.
PAA.Practice.Journal.Entry.activityForCharacter.publish (characterId, dateRange) ->
  check characterId, Match.DocumentId
  check dateRange, AE.DateRange

  query =
    'journal.character._id': characterId

  dateRange.addToMongoQuery query, 'time'

  PAA.Practice.Journal.Entry.documents.find query,
    fields:
      journal: true
      time: true

PAA.Practice.Journal.Entry.memoriesForEntryId.publish (entryId) ->
  check entryId, Match.DocumentId

  @autorun =>
    entry = PAA.Practice.Journal.Entry.documents.findOne entryId,
      fields:
        memories: 1

    return LOI.Memory.documents.find
      _id:
        $in: entry?.memories or []
