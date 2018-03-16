AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.Entry.Context extends LOI.Memory.Context
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Context'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  @initialize()
  
  @illustrationHeight: -> 240

  @isOwnMemory: (memory) -> memory.journalEntry
    
  onCreated: ->
    super

    @entry = new ComputedField =>
      return unless memory = LOI.adventure.currentMemory()
      entryId = memory.journalEntry[0]._id

      # Subscribe and retrieve the entry .
      PAA.Practice.Journal.Entry.forId.subscribe @, entryId
      PAA.Practice.Journal.Entry.documents.findOne entryId

    @journalDesign = new ComputedField =>
      return unless entry = @entry()
      journalId = entry.journal._id

      # React only to id and type changes.
      journalDocument = PAA.Practice.Journal.documents.findOne journalId,
        fields:
          'design.type': true

      return unless journalDocument

      # Put the interface in intro mode to focus on the journal.
      LOI.adventure.interface.inIntro true

      new PAA.PixelBoy.Apps.Journal.JournalView.JournalDesign[journalDocument.design.type]
        entryId: entry._id
        readOnly: true

  onRendered: ->
    super

    @$context = @$('.pixelartacademy-pixelboy-apps-journal-journalview-entry-context')

  description: ->
    return '' unless @isCreated()
    return '' unless entry = @entry()

    fullNameTranslation = AB.translate entry.journal.character.avatar.fullName

    # TODO: Localize possessive form.
    possessiveName = AB.Rules.English.createPossessive fullNameTranslation.text

    "You look at #{possessiveName} journal entry."

  illustrationHeight: ->
    return unless @isCreated()
    return unless journalDesign = @journalDesign()

    # We use a padding of 10.
    journalDesign.size().height + 20

  onScroll: (scrollTop) ->
    return unless @isRendered()

    @$context.css transform: "translate3d(0, #{-scrollTop}px, 0)"
