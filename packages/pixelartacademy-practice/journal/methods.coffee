AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Practice.Journal.insert.method (characterId, design) ->
  check characterId, Match.DocumentId
  check design, journalDesignPattern

  # Make sure the user can perform this character action.
  LOI.Authorize.characterAction characterId

  # We create a new check-in for the given character.
  journal =
    design: design
    character:
      _id: characterId

  PAA.Practice.Journal.documents.insert journal

PAA.Practice.Journal.remove.method (journalId) ->
  check journalId, Match.DocumentId

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction journalId

  PAA.Practice.Journal.documents.remove journalId

PAA.Practice.Journal.updateTitle.method (journalId, title) ->
  check journalId, Match.DocumentId
  check title, String

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction journalId

  # Associate the artist with the character.
  PAA.Practice.Journal.documents.update journalId,
    $set: {title}

PAA.Practice.Journal.updateDefaultFont.method (journalId, defaultFont) ->
  check journalId, Match.DocumentId
  check defaultFont, String

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction journalId

  # Associate the artist with the character.
  PAA.Practice.Journal.documents.update journalId,
    $set: {defaultFont}

PAA.Practice.Journal.updateDesign.method (journalId, design) ->
  check journalId, Match.DocumentId
  check design, journalDesignPattern

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction journalId

  # Associate the artist with the character.
  PAA.Practice.Journal.documents.update journalId,
    $set: {design}

PAA.Practice.Journal.updateArchived.method (journalId, archived) ->
  check journalId, Match.DocumentId
  check archived, Boolean

  # Make sure the check-in belongs to the current user.
  authorizeJournalAction journalId

  # Associate the artist with the character.
  PAA.Practice.Journal.documents.update journalId,
    $set: {archived}

authorizeJournalAction = (journalId) ->
  journal = PAA.Practice.Journal.documents.findOne journalId
  throw new AE.ArgumentException "Journal not found." unless journal

  LOI.Authorize.characterAction journal.character._id

journalDesignPattern = Match.ObjectIncluding
  # We make all fields optional so we can use this structure for sparse updates.
  type: Match.Optional Match.Where (value) => value in _.values PAA.Practice.Journal.Design.Type
  size: Match.Optional Match.Where (value) => value in _.values PAA.Practice.Journal.Design.Size
  orientation: Match.Optional Match.Where (value) => value in _.values PAA.Practice.Journal.Design.Orientation
  bindingPosition: Match.Optional Match.Where (value) => value in _.values PAA.Practice.Journal.Design.BindingPosition
  writingSides: Match.Optional Match.Where (value) => value in _.values PAA.Practice.Journal.Design.WritingSides
  paper: Match.Optional
    type: Match.Optional Match.Where (value) => value in _.values PAA.Practice.Journal.Design.PaperType
    color: Match.Optional
      hue: Match.Optional Match.Where (value) => value in _.values LOI.Assets.Palette.Atari2600.hues
      shade: Match.IntegerRange 0, 7
  cover: Match.Optional
    color: Match.Optional
      hue: Match.Optional Match.Where (value) => value in _.values LOI.Assets.Palette.Atari2600.hues
      shade: Match.IntegerRange 0, 7
