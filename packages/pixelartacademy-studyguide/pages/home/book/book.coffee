AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Book extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Book'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

    # Visible tells if the book is anywhere in the viewport (even when transitioning).
    @visible = new ReactiveField false

    # Opened tells if the book is open or transitioning to open.
    @opened = new ReactiveField false

    @leftPageIndex = new ReactiveField 0
    @visiblePageIndex = new ReactiveField 1
    @pagesCount = new ReactiveField null
    @manualContentUpdatedDependency = new Tracker.Dependency

    @book = new ComputedField =>
      return unless @home.activities.isCreated()

      bookId = @home.activities.activeBookId()
      book = PAA.StudyGuide.Book.documents.findOne bookId

      if book
        # Start on first page.
        @leftPageIndex 0
        @visiblePageIndex 1
        
        # Mark book as loaded for transitions to start.
        Meteor.setTimeout =>
          @visible true
        ,
          100

        # Make book visible after it has rendered and positioned outside the screen.
        Meteor.setTimeout =>
          @open()
        ,
          500

      else
        @visible false

      book

    @_goals = {}

    @contentItems = new ComputedField =>
      return [] unless book = @book()

      sortedContents = _.orderBy book.contents, 'order'

      for item in sortedContents
        # Create goal if needed.
        goalId = item.activity.goalId
        goalClass = PAA.StudyGuide.Goals[goalId]
        @_goals[goalId] ?= new goalClass

        # Generate activity slug.
        goal = @_goals[goalId]
        slug = _.kebabCase goal.displayName()

        activity: item.activity
        goal: goal
        slug: slug

    @activeContentItem = new ComputedField =>
      slug = @home.layout.router.getParameter 'activity'

      _.find @contentItems(), (contentItem) => contentItem.slug is slug

    @designConstants =
      pageMargins:
        left: 45
        right: 25
      moveButtonExtraWidth: 23
      frontPageLeftOffset: 5

    # Since the left and right borders are not equal, we need to additionally offset the book to focus on the center.
    @designConstants.focusOffset = (@designConstants.pageMargins.right - @designConstants.pageMargins.left) / 2

  onRendered: ->
    super arguments...

    # Reactively update pages count.
    @autorun (computation) =>
      return unless @book()
      return unless @opened()

      # Update when active content item or page index changes.
      @activeContentItem()
      @visiblePageIndex()

      @updatePagesCount()

    # React to active content item changes.
    @autorun (computation) =>
      activeContentItem = @activeContentItem()

      if activeContentItem
        # If we're coming from the table of contents, go to first page of the article.
        unless @_lastActiveContentItem
          @leftPageIndex 0
          @visiblePageIndex 0

      else
        # Remember which page on the table of contents we were.
        @_lastTableOfContentsVisiblePageIndex = @visiblePageIndex()

      @_lastActiveContentItem = activeContentItem

  onDestroyed: ->
    super arguments...

    goal.destroy() for goal in @_goals

  open: ->
    # Mark book as visible for transitions to start.
    @visible true

    # Make book opened after it has positioned outside the screen.
    Meteor.setTimeout =>
      @opened true
    ,
      100

  close: ->
    @opened false

    Meteor.setTimeout =>
      @visible false
    ,
      500

  goToTableOfContents: ->
    # Return to the page of the table of contents that we last saw.
    @visiblePageIndex @_lastTableOfContentsVisiblePageIndex
    @leftPageIndex Math.floor(@_lastTableOfContentsVisiblePageIndex / 2) * 2
    @home.layout.router.setParameter 'activity', null

    @scrollToTop()

  canMoveLeft: ->
    if @activeContentItem()
      # On articles, we can move left if we're not on the first page.
      @visiblePageIndex()

    else
      # Table of contents starts on the right, so we can move back only on second spread.
      @leftPageIndex()

  canMoveRight: ->
    # Are we on the last page of the section?
    if @activeContentItem()
      @visiblePageIndex() + 1 < @pagesCount()

    else
      @visiblePageIndex() < @pagesCount()

  previousPage: ->
    return unless @canMoveLeft()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()

    leftPageIndex -= 2 if leftPageIndex is visiblePageIndex
    visiblePageIndex--

    @leftPageIndex leftPageIndex
    @visiblePageIndex visiblePageIndex

    @scrollToTop()

  nextPage: ->
    return unless @canMoveRight()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()

    leftPageIndex += 2 unless leftPageIndex is visiblePageIndex
    visiblePageIndex++

    @leftPageIndex leftPageIndex
    @visiblePageIndex visiblePageIndex

    @scrollToTop()

  scrollToTop: ->
    html = $("html")[0]
    return unless currentScrollTop = html.scrollTop

    targetScrollTop = 0

    $(".pixelartacademy-studyguide-pages-home-book").velocity
      tween: [targetScrollTop, currentScrollTop]
    ,
      duration: 500
      easing: 'ease-in-out'
      progress: (elements, complete, remaining, start, tweenValue) =>
        html.scrollTop = tweenValue

  contentUpdated: ->
    @manualContentUpdatedDependency.changed()

  updatePagesCount: ->
    # Depend on manual update events.
    @manualContentUpdatedDependency.depend()
    
    if @activeContentItem()
      @_updatePagesCountActivity()

    else
      # Depend on content items.
      @contentItems()

      @_updatePagesCountTableOfContents()

  _updatePagesCountActivity: ->
    @_updatePagesCountViaEndPage()

  _updatePagesCountTableOfContents: ->
    @_updatePagesCountViaEndPage()

  _updatePagesCountViaEndPage: ->
    return unless columnProperties = @columnProperties()

    scale = @display.scale()
    pageWidth = (columnProperties.columnWidth + columnProperties.columnGap) * scale

    Meteor.setTimeout =>
      # Search for the new end page.
      endPageLeft = @$('.end-page').position().left
      pagesCount = Math.ceil (endPageLeft + 1) / pageWidth

      @pagesCount pagesCount
    ,
      100

  visibleClass: ->
    'visible' if @visible()

  componentStyle: ->
    return unless book = @book()
    viewport = @display.viewport()
    scale = @display.scale()

    bookWidth = book.design.size.width
    viewportWidth = viewport.viewportBounds.width() / scale
    viewportHeight = viewport.viewportBounds.height() / scale

    horizontalGap = (viewportWidth - bookWidth) / 2
    verticalGap = (viewportHeight - viewport.safeArea.height() / scale) / 2
    verticalGap = _.clamp verticalGap, 10, 30

    fullWidth = (bookWidth + horizontalGap) * 2

    if @opened()
      if @leftPageIndex() is @visiblePageIndex()
        left = @designConstants.focusOffset

      else
        left = viewportWidth - fullWidth - @designConstants.focusOffset

    else
      left = horizontalGap - fullWidth - 1

    left: "#{Math.round left}rem"
    padding: "#{Math.round verticalGap}rem #{Math.round horizontalGap}rem"

  bookStyle: ->
    return unless book = @book()

    width: "#{book.design.size.width * 2}rem"
    height: "#{book.design.size.height}rem"

  _horizontalGap: ->
    return unless book = @book()
    viewport = @display.viewport()
    scale = @display.scale()

    bookWidth = book.design.size.width
    viewportWidth = viewport.viewportBounds.width() / scale

    (viewportWidth - bookWidth) / 2

  moveButtonStyle: ->
    horizontalGap = @_horizontalGap()
    return unless horizontalGap?

    width = horizontalGap + @designConstants.moveButtonExtraWidth
    width: "#{width}rem"

  frontPageClass: ->
    'front' unless @activeContentItem() or @leftPageIndex()

  rightPageHasContent: ->
    @leftPageIndex() + 1 < @pagesCount()

  pageNumberLeft: ->
    pageNumber = @leftPageIndex() + 1
    pageNumber-- unless @activeContentItem()
    pageNumber

  showPageNumberRight: ->
    @pageNumberRight() <= @pagesCount()

  pageNumberRight: ->
    @pageNumberLeft() + 1

  columnProperties: ->
    return unless book = @book()
    margins = @designConstants.pageMargins

    columnWidth: book.design.size.width - margins.left - margins.right
    columnGap: 2 * margins.right

  contentsStyle: ->
    return unless columnProperties = @columnProperties()

    leftPageIndex = @leftPageIndex()
    pageIndex = leftPageIndex

    # Table of contents starts on the right.
    onTableOfContents = not @activeContentItem()
    pageIndex -= 1 if onTableOfContents

    left = -pageIndex * (columnProperties.columnWidth + columnProperties.columnGap)
    pagesCount = 100
    width = pagesCount * columnProperties.columnWidth + (pagesCount - 1) * columnProperties.columnGap

    # On the front page, we have extra left offset.
    left += @designConstants.frontPageLeftOffset if onTableOfContents and not leftPageIndex

    left: "#{left}rem"
    width: "#{width}rem"
    columnWidth: "#{columnProperties.columnWidth}rem"
    columnGap: "#{columnProperties.columnGap}rem"

  events: ->
    super(arguments...).concat
      'click .move-button.left': @onClickMoveButtonLeft
      'click .move-button.right': @onClickMoveButtonRight

  onClickMoveButtonLeft: (event) ->
    @previousPage()

  onClickMoveButtonRight: (event) ->
    @nextPage()

  class @TableOfContentsItem extends AM.Component
    @register "PixelArtAcademy.StudyGuide.Pages.Home.Book.TableOfContentsItem"

    onCreated: ->
      super arguments...

      @bookComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Home.Book
      @book = new ComputedField => @bookComponent.book()

    started: ->
      {goal} = @data()

      # At least one task needs to be completed.
      return true for task in goal.tasks() when task.completed()

      false

    allTasksCompleted: ->
      {goal} = @data()

      # All tasks need to be completed.
      return for task in goal.tasks() when not task.completed()

      true
