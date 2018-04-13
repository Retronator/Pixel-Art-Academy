PAA = PixelArtAcademy
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class PAA.Practice.Journal.Entry.Action extends PAA.Practice.Journal.Entry.Action
  # Override the constructor for this type.
  @register @type, @

  constructor: ->
    super

    @avatar = new LOI.Adventure.Thing.Avatar PAA.Practice.Journal.Entry.Avatar

  onCommand: (person, commandResponse) ->
    # Looking at the entry enters into the context of the entry.
    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Read], possessive: person.avatar, @avatar]
      action: =>
        # Create the journal view context for this entry's journal
        context = new PAA.PixelBoy.Apps.Journal.JournalView.Context
          journalId: @content.journalEntry[0].journal._id
          # Start on the action's entry page.
          entryId: @content.journalEntry[0]._id

        LOI.adventure.enterContext context
