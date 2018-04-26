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
    options = entryId: memory.journalEntry[0]._id

    # Show the whole journal unless we're in a memory.
    options.journalId = memory.journalEntry[0].journal._id unless LOI.adventure.currentMemory()

    context = new @ options

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
    @_entrySubscription = PAA.Practice.Journal.Entry.forId.subscribe @options.entryId if @options.entryId

    # Get journal ID from the entry if necessary.
    @journalId = new ComputedField =>
      # To prevent flicker, wait until our own subscription has kicked in,
      # since entry from outside subscriptions might get lost before we get it back.
      return if @_entrySubscription? and not @_entrySubscription.ready()

      journalId = @options.journalId

      unless journalId
        return unless entry = PAA.Practice.Journal.Entry.documents.findOne @options.entryId

        journalId = entry.journal._id

      journalId

    # Subscribe to the journal.
    @autorun (computation) =>
      return unless journalId = @journalId()

      PAA.Practice.Journal.forId.subscribe journalId

    @journalDesign = new ComputedField =>
      return unless journalId = @journalId()

      journalDocument = PAA.Practice.Journal.documents.findOne journalId,
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

    # Reset displayed memory on entry change.
    @autorun (computation) =>
      # Depend on entry ID changes.
      return unless @entryId()

      # Don't reset memory on initial run.
      unless @_entryIdInitialized
        @_entryIdInitialized = true
        return

      @displayMemory null
      LOI.adventure.interface.narrative.clear scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.None

    # Provide available memories to the memory context.
    @memoryIds = new ComputedField =>
      return unless entryId = @entryId()
      return unless entry = PAA.Practice.Journal.Entry.documents.findOne entryId

      # Return an empty array to indicate that we've created memory IDs and not just waiting on the entry.
      return [] unless entry.memories

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

  ready: ->
    conditions = [
      super
      @memoryIds()
      @description()
    ]

    _.every conditions

  createNewMemory: ->
    memoryId = super

    PAA.Practice.Journal.Entry.addMemory @entryId(), memoryId

    # Return the memory ID so the caller can add actions to it.
    memoryId

  description: ->
    return '' unless @isCreated()
    return '' unless journal = PAA.Practice.Journal.documents.findOne @journalId()

    fullNameTranslation = AB.translate journal.character.avatar.fullName

    # TODO: Localize possessive form.
    possessiveName = AB.Rules.English.createPossessive fullNameTranslation.text

    if @options.entryId
      "You look at #{possessiveName} journal entry."

    else
      "You look at #{possessiveName} journal."

  illustrationHeight: ->
    return unless @isCreated()
    return unless journalDesign = @journalDesign()

    # We use a padding of 10.
    journalDesign.size().height + 20

  onScroll: (scrollTop) ->
    return unless @isRendered()

    @$context.css transform: "translate3d(0, #{-scrollTop}px, 0)"
