AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Subscribe to an entry and its journal
PAA.Practice.Journal.Entry.forId.publish (entryId) ->
  check entryId, Match.DocumentId

  entryCursor = PAA.Practice.Journal.Entry.documents.find
    _id: entryId

  entry = entryCursor.fetch()[0]
  return unless entry

  # Return both the entry and its journal since we almost always need them together.
  [
    entryCursor
    PAA.Practice.Journal.documents.find _id: entry.journal._id
  ]

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
