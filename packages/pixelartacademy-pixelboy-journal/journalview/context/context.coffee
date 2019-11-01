AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.PixelBoy.Apps.Journal.JournalView.Context extends LOI.Memory.Context
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Context'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  @initialize()
  
  @illustration: -> height: 240

  @canHandleMemory: (memory) ->
    memory.journalEntry?

  @tryCreateContext: (memory) ->
    return unless @canHandleMemory memory

    # Create the context for this entry.
    options = entryId: memory.journalEntry[0]._id

    # Show the whole journal unless we're in a memory.
    options.journalId = memory.journalEntry[0].journal._id unless LOI.adventure.currentMemory()

    context = new @ options

    # Start in the provided memory.
    context.displayMemory memory._id

    # Return the context.
    context

  @translations: ->
    introDescription: "_people_ _are_ talking to _author_ about _their_ journal entry."
    introDescriptionJustAuthor: "_author_ is commenting on _their_ journal entry."

  @createIntroDescriptionScript: (memory, people, nextNode, nodeOptions) ->
    # Don't include the author in people since they will already be mentioned.
    author = LOI.Character.getAgent memory.journalEntry[0].journal.character._id
    people = _.without people, author

    translationKey = if people.length then 'introDescription' else 'introDescriptionJustAuthor'
    description = AB.translate(@translationHandle, translationKey).text

    # Format people into the description. We need to do it here first (instead of letting
    # createDescriptionScript do it) because _are_ should refer to people, not the author.
    description = LOI.Character.Agents.formatText description, 'people', people if people.length

    # Format entry author into the description.
    description = LOI.Character.formatText description, 'author', author

    @_createDescriptionScript people, description, nextNode, nodeOptions

  @getPeopleForMemory: (memory) ->
    people = super arguments...

    # Add the author if not already part of the conversation.
    author = LOI.Character.getAgent memory.journalEntry[0].journal.character._id
    people.push author unless author in people

    people

  constructor: (@options) ->
    super arguments...

    @journalEntryAvatar = new LOI.Adventure.Thing.Avatar PAA.Practice.Journal.Entry.Avatar
    
  destroy: ->
    super arguments...

    @journalEntryAvatar.destroy()

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
    super arguments...

  onRendered: ->
    super arguments...

    @$context = @$('.pixelartacademy-pixelboy-apps-journal-journalview-context')

  onDestroyed: ->
    super arguments...

    @journalDesign.stop()
    @entryId.stop()
    @memoryIds.stop()

  ready: ->
    conditions = [
      super arguments...
      @memoryIds()
      @description()
    ]

    _.every conditions

  createNewMemory: ->
    memoryId = super arguments...

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

  illustration: ->
    return unless @isCreated()
    return unless journalDesign = @journalDesign()
    
    illustration = super(arguments...) or {}

    _.extend illustration,
      # We use a padding of 10.
      height: journalDesign.size().height + 20

  onScroll: (scrollTop) ->
    return unless @isRendered()

    @$context.css transform: "translate3d(0, #{-scrollTop}px, 0)"

  onCommandWhileAdvertised: (commandResponse) ->
    return unless memory = LOI.Memory.documents.findOne @memoryId()
    author = LOI.Character.getAgent memory.journalEntry[0].journal.character._id
    
    # Looking at the entry enters into the context of the entry.
    action = => LOI.adventure.enterContext @

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Read], possessive: author.avatar, @journalEntryAvatar]
      action: action

    # Allow the form without author's name.
    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Read], @journalEntryAvatar]
      action: action
