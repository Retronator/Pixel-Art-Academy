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

    @entryEditors = new ComputedField =>
      # Get all the entries and only depend on their ID to minimize updates when data inside an entry changes.
      entries = PAA.Practice.Journal.Entry.documents.find(
        'journal._id': @journalDesign.journalId
      ,
        fields:
          _id: 1
        sort:
          time: 1
      ).fetch()
      
      entryEditors = []

      for entry in entries
        entryEditor = new PAA.PixelBoy.Apps.Journal.JournalView.EntryEditor @, entry._id
        entryEditors.push entryEditor
          
      # Add the new (empty) entry.
      entryEditors.push new PAA.PixelBoy.Apps.Journal.JournalView.EntryEditor @, null

      entryEditors

    # Start on the new entry.
    @currentEntryId = new ReactiveField null

    @currentEntryEditor = new ComputedField =>
      currentEntryId = @currentEntryId()
      _.find @entryEditors(), (entryEditor) => entryEditor.entryId is currentEntryId

    @currentEntryIndex = new ComputedField =>
      currentEntryId = @currentEntryId()
      index = _.findIndex @entryEditors(), (entryEditor) => entryEditor.entryId is currentEntryId

      # As a side effect of reaching a very low index, load earlier entries.
      if index < 5
        entriesLimit = @entriesLimit()
        displayedEntriesCount = @entryEditors().length - 1

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
    return unless currentEntryEditor = @currentEntryEditor()
    
    # First see if the entry itself can turn the page.
    return if currentEntryEditor.previousPage()

    # We must be at the start of the entry, so we need to go to the end of the previous entry.
    newEntryIndex = @currentEntryIndex() - 1
    return if newEntryIndex < 0

    # Update current entry ID.
    newEntryId = @entryEditors()[newEntryIndex].entryId
    @currentEntryId newEntryId
    
    # We should now have a new current editor. Go to last page of it.
    currentEntryEditor = @currentEntryEditor()
    currentEntryEditor.goToLastPage()

  nextPage: ->
    # Make sure the entry editor has already been created.
    return unless currentEntryEditor = @currentEntryEditor()

    # First see if the entry itself can turn the page.
    return if currentEntryEditor.nextPage()

    # We must be at the end of the entry, so we need to go to the start of the previous entry.
    newEntryIndex = @currentEntryIndex() + 1
    return if newEntryIndex < 0

    # Update current entry ID.
    newEntryId = @entryEditors()[newEntryIndex].entryId
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
      return unless currentEntryEditor = @currentEntryEditor()
      return unless currentEntryEditor.isRendered()
      computation.stop()

      currentEntryEditor.focus()

  entryVisibleClass: ->
    entryEditor = @currentData()
    'visible' if entryEditor.entryId is @currentEntryId()

  previousPageVisibleClass: ->
    # We can always go back unless we're at the first page of the first entry.
    'visible' unless @currentEntryIndex() is 0 and @currentEntryEditor().currentPageIndex() is 0

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
