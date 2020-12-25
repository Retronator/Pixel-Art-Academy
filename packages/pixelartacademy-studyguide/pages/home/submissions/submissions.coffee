AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
ABs = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Submissions extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Submissions'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

    @taskId = new ReactiveField null

    @taskClass = new ComputedField =>
      return unless taskId = @taskId()
      PAA.Learning.Task.getClassForId taskId

    @task = new ComputedField =>
      return unless taskClass = @taskClass()
      new taskClass

    @entries = new ComputedField =>
      return unless taskId = @taskId()

      PAA.Learning.Task.Entry.documents.fetch
        taskId: taskId
      ,
        sort:
          time: 1

    @reversedEntries = new ComputedField =>
      return unless entries = @entries()

      _.reverse _.clone entries

    @displayedEntries = new ComputedField =>
      return unless entries = @entries()

      startIndex = @entriesPerPage * @currentPageIndex()
      endIndex = Math.min startIndex + @entriesPerPage - 1, entries.length

      entries[startIndex..endIndex]

    @entriesPerPage = 18

    @currentPageIndex = new ReactiveField 0
    @hoveredEntry = new ReactiveField null

    @setHoveredEntry = _.debounce (entry) =>
      @hoveredEntry entry
    ,
      50

    @pagesCount = new ComputedField =>
      return 1 unless entries = @entries()
      Math.ceil entries.length / @entriesPerPage

    # Reactively subscribe to task submissions.
    @submissionsSubscription = new ComputedField =>
      return unless taskId = @taskId()
      PAA.Learning.Task.Entry.forTaskId.subscribe @, taskId

    @loaded = new ComputedField =>
      @submissionsSubscription()?.ready()

    @opened = new ReactiveField false
    @entriesSheetDisplayed = new ReactiveField false

  open: (taskId) ->
    @taskId taskId
    @opened true

    # After the submissions have loaded and the folder has finished animating, display the entries sheet.
    @autorun (computation) =>
      return unless @loaded()
      computation.stop()
      
      Meteor.setTimeout =>
        @entriesSheetDisplayed true
      ,
        500

  close: ->
    # Store back the entries sheet.
    @entriesSheetDisplayed false
    
    # After the sheet has been stored, close the sheet.
    Meteor.setTimeout =>
      @opened false
  
      Meteor.setTimeout =>
        @taskId null
      ,
        500
    ,
      500
    
  loadedClass: ->
    'loaded' if @loaded()

  submissionsStyle: ->
    left = @home.safeWidthGap()

    if @loaded() and @opened()
      top = @home.safeHeightGap()

    else
      top = @home.viewportHeight() + 1

    left: "#{left}rem"
    top: "#{top}rem"

  entriesSheetDisplayedClass: ->
    'displayed' if @entriesSheetDisplayed()

  emptyEntries: ->
    entriesCount = @displayedEntries()?.length or 0

    null for emptyEntry in [0...@entriesPerPage - entriesCount]

  entryName: ->
    entry = @currentData()

    if entry.user
      name = entry.user.publicName

    else
      name = entry.character.avatar?.fullName.translate().text

    name or 'Anonymous'

  entryDateText: ->
    entry = @currentData()
    languagePreference = AB.languagePreference()

    entry.time.toLocaleDateString languagePreference, dateStyle: 'short'

  currentPageNumber: ->
    @currentPageIndex() + 1

  events: ->
    super(arguments...).concat
      'mouseenter .entry': @onMouseEnterEntry
      'mouseleave .entry': @onMouseLeaveEntry
      'click .previous .page-button': @onClickPreviousPageButton
      'click .next .page-button': @onClickNextPageButton

  onMouseEnterEntry: (event) ->
    entry = @currentData()
    @setHoveredEntry entry

  onMouseLeaveEntry: (event) ->
    @setHoveredEntry null

  onClickPreviousPageButton: (event) ->
    @currentPageIndex @currentPageIndex() - 1

  onClickNextPageButton: (event) ->
    @currentPageIndex @currentPageIndex() + 1
