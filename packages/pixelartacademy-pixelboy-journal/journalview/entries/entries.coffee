AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.Entries extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entries'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  constructor: (@journalDesign) ->
    super arguments...
    
  mixins: -> [
    PAA.PixelBoy.Components.Mixins.PageTurner
  ]
    
  onCreated: ->
    super arguments...

    @entriesLimit = new ReactiveField 0

    # We delay loading journal entries until animations have done playing.
    @startLoading = new ReactiveField false

    @firstLoadDone = false

    @autorun (computation) =>
      return unless @startLoading()

      # Subscribe to all entries of the journal, if we're displaying a journal and not just one entry.
      if @journalDesign.options.journalId
        @_journalEntriesSubscription = PAA.Practice.Journal.Entry.forJournalId.subscribe @, @journalDesign.options.journalId, @entriesLimit()

    # Start on the requested entry or default to the last entry.
    @currentEntryId = new ReactiveField @journalDesign.options.entryId or null

    @_entries = {}

    @entries = new ComputedField =>
      # If we have a journal ID, we load the whole journal, even if we also have a specific entry to show first.
      if @journalDesign.options.journalId
        # Get all the entries.
        query = 'journal._id': @journalDesign.options.journalId

      else
        # Get just the one entry.
        query = @journalDesign.options.entryId

      # Only depend on the entry IDs to minimize updates when data inside an entry changes.
      entryDocuments = PAA.Practice.Journal.Entry.documents.find(query,
        fields:
          _id: 1
        sort:
          order: 1
      ).fetch()
      
      entries = []

      for entryDocument in entryDocuments
        @_entries[entryDocument._id] ?= new PAA.PixelBoy.Apps.Journal.JournalView.Entry @, entryDocument._id
        entries.push @_entries[entryDocument._id]

      # Go to the last page on first load.
      unless @firstLoadDone
        # Wait till subscription is ready, or we have obtained entries through other means.
        if @startLoading() and @_journalEntriesSubscription?.ready() or entries.length
          # Mark that we've seen the first batch of entries.
          @firstLoadDone = true

          # Only change ID if we haven't got it yet.
          @currentEntryId _.last(entries).entryId if entries.length and not @currentEntryId()

      # Add the new (empty) entry if this is a journal, it is not read-only, and first load is done.
      if @journalDesign.options.journalId and not @journalDesign.options.readOnly and @firstLoadDone
        entries.push new PAA.PixelBoy.Apps.Journal.JournalView.Entry @, null

      entries

    @currentEntry = new ComputedField =>
      currentEntryId = @currentEntryId()
      _.find @entries(), (entry) => entry.entryId is currentEntryId

    @currentEntryIndex = new ComputedField =>
      currentEntryId = @currentEntryId()
      entries = @entries()
      index = _.findIndex entries, (entry) => entry.entryId is currentEntryId

      # As a side effect of reaching a very low index, load earlier entries.
      if index < 5
        entriesLimit = @entriesLimit()
        displayedEntriesCount = _.filter(entries, (entry) => entry.entryId).length

        # If all entries have been loaded, see if we should display some more. Note that we might be above
        # the entries limit if a specific journal entry is requested and comes from its own subscription.
        if displayedEntriesCount >= entriesLimit
          entriesCount = @journalDesign.journalDocument().entries?.length or 0

          if entriesCount > displayedEntriesCount
            # Show 10 more entries, but not more than available. We need to show exact
            # number because otherwise we would think some haven't been loaded yet.
            @entriesLimit Math.min entriesCount, entriesLimit + 10

      index

  onRendered: ->
    super arguments...

    Meteor.setTimeout =>
      @startLoading true
    ,
      1000

  previousPage: ->
    # Make sure the entry editor has already been created.
    currentEntry = @currentEntry()
    return unless currentEntry?.isCreated()
    
    # First see if the entry itself can turn the page.
    return if currentEntry.previousPage()

    # We must be at the start of the entry, so we need to go to the end of the previous entry.
    newEntryIndex = @currentEntryIndex() - 1
    return if newEntryIndex < 0

    # Update current entry ID.
    newEntryId = @entries()[newEntryIndex].entryId
    @currentEntryId newEntryId

    # Wait for the entry to be created.
    Tracker.autorun (computation) =>
      currentEntry = @currentEntry()
      return unless currentEntry?.isCreated()
      computation.stop()

      # We should now have a new current editor. Go to last page of it.
      currentEntry.goToLastPage()

  nextPage: ->
    # Make sure the entry editor has already been created.
    currentEntry = @currentEntry()
    return unless currentEntry?.isCreated()

    # First see if the entry itself can turn the page.
    return if currentEntry.nextPage()

    # We must be at the end of the entry, so we need to go to the start of the next entry.
    newEntryIndex = @currentEntryIndex() + 1

    entries = @entries()
    return if newEntryIndex > entries.length - 1

    # Update current entry ID.
    newEntryId = entries[newEntryIndex].entryId
    @currentEntryId newEntryId

    # Wait for the entry to be changed.
    Tracker.autorun (computation) =>
      currentEntry = @currentEntry()
      return unless currentEntry?.isCreated()
      computation.stop()

      # We should now have a new current editor. Go to first page of it.
      currentEntry.currentPageIndex 0

  startEntry: (delta) ->
    entryId = Random.id()

    # Update the entry ID of the currently edited new page, so that it stays visible until it gets replaced.
    @currentEntry().entryId = entryId

    journalId = @journalDesign.options.journalId
    PAA.Practice.Journal.Entry.insert entryId, journalId, delta.ops, null, LOI.adventure.currentSituationParameters()

    @currentEntryId entryId

    # Return focus to the editor once it has re-rendered.
    @autorun (computation) =>
      return unless currentEntry = @currentEntry()
      return unless currentEntry.isRendered()
      computation.stop()

      currentEntry.focus()
      currentEntry.moveCursorToEnd()

  entryVisibleClass: ->
    entry = @currentData()
    'visible' if entry.entryId is @currentEntryId()

  previousPageVisibleClass: ->
    return unless currentEntry = @currentEntry()
    return unless currentEntry.isCreated()

    # We can always go back unless we're at the first page of the first entry.
    'visible' unless @currentEntryIndex() is 0 and currentEntry.currentPageIndex() is 0

  nextPageVisibleClass: ->
    # We can go forward until we're on the last page of the last entry.
    return unless currentEntry = @currentEntry()
    return unless currentEntry.isCreated()
    return unless entries = @entries()

    # We need to see if the viewport includes the end of the entry.
    lastPageVisibleIndex = currentEntry.currentPageIndex() - 1 + @journalDesign.writingAreaOptions().pagesPerViewport

    'visible' unless @currentEntryIndex() >= entries.length - 1 and lastPageVisibleIndex >= currentEntry.pagesCount() - 1

  nextPageIsNew: ->
    return unless currentEntry = @currentEntry()
    return unless currentEntry?.isCreated()
    return unless entries = @entries()

    # Make sure the last entry is new (it doesn't have an ID).
    return if _.last(entries)?.entryId

    # We should be on the second to last entry.
    return unless @currentEntryIndex() is entries.length - 2

    # We need to see if the viewport includes the end of the entry.
    lastPageVisibleIndex = currentEntry.currentPageIndex() - 1 + @journalDesign.writingAreaOptions().pagesPerViewport
    lastPageVisibleIndex >= currentEntry.pagesCount() - 1

  newPageClass: ->
    'new-page' if @nextPageIsNew()

  events: ->
    super(arguments...).concat
      'click .previous.page-button': @onClickPreviousPageButton
      'click .next.page-button': @onClickNextPageButton

  onClickPreviousPageButton: (event) ->
    @previousPage()

  onClickNextPageButton: (event) ->
    @nextPage()
