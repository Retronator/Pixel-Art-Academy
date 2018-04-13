AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.Context extends LOI.Memory.Context
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Context'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  @initialize()
  
  @illustrationHeight: -> 240

  @tryCreateContext: (memory) ->
    return unless memory.journalEntry

    # Create the context for this entry.
    context = new @
      journalId: memory.journalEntry[0].journal._id
      entryId: memory.journalEntry[0]._id
    
    # Start in the provided memory.
    context.displayMemory memory._id

    # Return the context.
    context

  constructor: (@options) ->
    super
    
  onCreated: ->
    # Start with a clear interface when viewing a journal.
    LOI.adventure.interface.narrative.clear()

    # Subscribe to the selected entry so it loads up quicker.
    PAA.Practice.Journal.Entry.forId.subscribe @options.entryId if @options.entryId

    # Subscribe to the journal.
    PAA.Practice.Journal.forId.subscribe @options.journalId

    @journalDesign = new ComputedField =>
      # React only to id and type changes.
      journalDocument = PAA.Practice.Journal.documents.findOne @options.journalId,
        fields:
          'design.type': true

      return unless journalDocument
      
      Tracker.nonreactive =>
        # Put the interface in intro mode to focus on the journal.
        LOI.adventure.interface.inIntro true
  
        new PAA.PixelBoy.Apps.Journal.JournalView.JournalDesign[journalDocument.design.type]
          journalId: @options.journalId
          entryId: @options.entryId
          readOnly: true

    @entryId = new ComputedField =>
      return unless journalDesign = @journalDesign()
      return unless entries = journalDesign.entries()
      entries.currentEntryId()

    # Provide available memories to the memory context.
    @memoryIds = new ComputedField =>
      return unless entryId = @entryId()
      return unless entry = PAA.Practice.Journal.Entry.documents.findOne entryId
      return unless entry.memories

      memory._id for memory in entry.memories

    # Call super last because Memory Context relies on our computed fields.
    super

  onRendered: ->
    super

    @$context = @$('.pixelartacademy-pixelboy-apps-journal-journalview-context')

  onDestroyed: ->
    super

    @journalDesign.stop()
    @entryId.stop()
    @memoryIds.stop()

  createNewMemory: ->
    memoryId = super

    PAA.Practice.Journal.Entry.addMemory @entryId(), memoryId

    # Return the memory ID so the caller can add actions to it.
    memoryId

  description: ->
    return '' unless journal = PAA.Practice.Journal.documents.findOne @options.journalId

    fullNameTranslation = AB.translate journal.character.avatar.fullName

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
