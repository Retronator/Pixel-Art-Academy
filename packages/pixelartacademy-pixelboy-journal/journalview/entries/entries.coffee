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
    super

  onCreated: ->
    super

    @entriesLimit = new ReactiveField 0

    @autorun (computation) =>
      PAA.Practice.Journal.Entry.forJournalId.subscribe @journalDesign.journalId, @entriesLimit()

    @entries = new ComputedField =>
      # Get all the entries and only depend on their ID to minimize updates when data inside an entry changes.
      entryDocuments = PAA.Practice.Journal.Entry.documents.find(
        'journal._id': @journalDesign.journalId
      ,
        fields:
          _id: 1
        sort:
          time: 1
      ).fetch()
      
      entries = []

      for entryDocument in entryDocuments
        entry = new PAA.PixelBoy.Apps.Journal.JournalView.Entry @, entryDocument._id
        entries.push entry
          
      # Add the new (empty) entry.
      entries.push new PAA.PixelBoy.Apps.Journal.JournalView.Entry @, null

      entries

    # Start on the new entry.
    @currentEntryId = new ReactiveField null

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
        displayedEntriesCount = entries.length - 1

        # If all entries have been loaded, see if we should display some more.
        if displayedEntriesCount is entriesLimit
          entriesCount = @journalDesign.journalDocument().entries?.length or 0

          if entriesCount > displayedEntriesCount
            # Show 10 more entries, but not more than available. We need to show exact
            # number because otherwise we would think some haven't been loaded yet.
            @entriesLimit Math.min entriesCount, entriesLimit + 10

      index
      
  previousPage: ->
    # Make sure the entry editor has already been created.
    return unless currentEntry = @currentEntry()
    
    # First see if the entry itself can turn the page.
    return if currentEntry.previousPage()

    # We must be at the start of the entry, so we need to go to the end of the previous entry.
    newEntryIndex = @currentEntryIndex() - 1
    return if newEntryIndex < 0

    # Update current entry ID.
    newEntryId = @entries()[newEntryIndex].entryId
    @currentEntryId newEntryId
    
    # We should now have a new current editor. Go to last page of it.
    currentEntry = @currentEntry()
    currentEntry.goToLastPage()

  nextPage: ->
    # Make sure the entry editor has already been created.
    return unless currentEntry = @currentEntry()

    # First see if the entry itself can turn the page.
    return if currentEntry.nextPage()

    # We must be at the end of the entry, so we need to go to the start of the previous entry.
    newEntryIndex = @currentEntryIndex() + 1
    return if newEntryIndex < 0

    # Update current entry ID.
    newEntryId = @entries()[newEntryIndex].entryId
    @currentEntryId newEntryId

  startEntry: (delta) ->
    entryId = Random.id()
    journalId = @journalDesign.journalId
    time = new Date()
    timezoneOffset = time.getTimezoneOffset()
    language = AB.currentLanguage()

    PAA.Practice.Journal.Entry.insert entryId, journalId, time, timezoneOffset, language, delta.ops

    @currentEntryId entryId

    # Return focus to the editor once it has re-rendered.
    @autorun (computation) =>
      return unless currentEntry = @currentEntry()
      return unless currentEntry.isRendered()
      computation.stop()

      currentEntry.focus()

  entryVisibleClass: ->
    entry = @currentData()
    'visible' if entry.entryId is @currentEntryId()

  previousPageVisibleClass: ->
    return unless currentEntry = @currentEntry()
    return unless currentEntry.isCreated()

    # We can always go back unless we're at the first page of the first entry.
    'visible' unless @currentEntryIndex() is 0 and currentEntry.currentPageIndex() is 0

  nextPageVisibleClass: ->
    # We can always go forward except when we're on the new entry page.
    'visible' if @currentEntryId()

  events: ->
    super.concat
      'click .previous.page-button': @onClickPreviousPageButton
      'click .next.page-button': @onClickNextPageButton

  onClickPreviousPageButton: (event) ->
    @previousPage()

  onClickNextPageButton: (event) ->
    @nextPage()
