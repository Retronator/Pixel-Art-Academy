AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Book extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Book'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

    @visible = new ReactiveField false
    @loaded = new ReactiveField false
    @leftPageIndex = new ReactiveField 0
    @visiblePageIndex = new ReactiveField 1
    @pagesCount = new ReactiveField null

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
          @loaded true
        ,
          100

        # Make book visible after it has rendered and positioned outside the screen.
        Meteor.setTimeout =>
          @visible true
        ,
          500

      else
        @loaded false

      book

    @activities = new ComputedField =>
      return unless book = @book()

      sortedContents = _.orderBy book.contents, 'order'

      item.activity for item in sortedContents

    @activity = new ComputedField =>
      AB.Router.getParameter 'activity'

    @designConstants =
      pageMargins:
        left: 40
        right: 20
      moveButtonExtraWidth: 35

  onRendered: ->
    super arguments...

    # Reactively update pages count.
    @autorun (computation) =>
      return unless @book()
      return unless @visible()

      # Update when activity or page index changes.
      @activity()
      @visiblePageIndex()

      @updatePagesCount()

    # React to activity changes.
    @autorun (computation) =>
      activity = @activity()

      if activity
        # If we're coming from the table of contents, go to first page of the article.
        unless @_lastActivity
          @leftPageIndex 0
          @visiblePageIndex 0

      else
        # Remember which page on the table of contents we were.
        @_lastTableOfContentsVisiblePageIndex = @visiblePageIndex()

      @_lastActivity = activity

  close: ->
    @visible false

  goToTableOfContents: ->
    # Return to the page of the table of contents that we last saw.
    @visiblePageIndex @_lastTableOfContentsVisiblePageIndex
    @leftPageIndex Math.floor(@_lastTableOfContentsVisiblePageIndex / 2) * 2
    AB.Router.setParameter 'activity', null

    @scrollToTop()

  canMoveLeft: ->
    unless activity = @activity()
      # On table of contents we can't go further back than the first page.
      return @leftPageIndex()

    true

  canMoveRight: ->
    true

  previousPage: ->
    return unless @canMoveLeft()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()

    # Are we at the first page of the article?
    if @activity() and not visiblePageIndex
      # Go to previous article.

      # This is the first article, so go to the table of contents.
      @goToTableOfContents()
      return

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

  updatePagesCount: ->
    if @activity()
      @_updatePagesCountActivity()

    else
      # Depend on activities.
      @activities()

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

  loadedClass: ->
    'loaded' if @loaded()

  componentStyle: ->
    return unless book = @book()
    viewport = @display.viewport()
    scale = @display.scale()

    bookWidth = book.design.size.width
    viewportWidth = viewport.viewportBounds.width() / scale
    viewportHeight = viewport.viewportBounds.height() / scale

    horizontalGap = (viewportWidth - bookWidth) / 2
    verticalGap = (viewportHeight - viewport.safeArea.height() / scale) / 2

    fullWidth = (bookWidth + horizontalGap) * 2

    if @visible()
      if @leftPageIndex() is @visiblePageIndex()
        left = 0

      else
        left = viewportWidth - fullWidth

    else
      left = horizontalGap - fullWidth

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

  moveButtonLeftStyle: ->
    return unless horizontalGap = @_horizontalGap()

    width = horizontalGap
    width += @designConstants.moveButtonExtraWidth if @leftPageIndex() is @visiblePageIndex()

    width: "#{width}rem"

  moveButtonRightStyle: ->
    return unless horizontalGap = @_horizontalGap()

    width = horizontalGap
    width += @designConstants.moveButtonExtraWidth unless @leftPageIndex() is @visiblePageIndex()

    width: "#{width}rem"

  frontPageClass: ->
    'front' unless @activity() or @leftPageIndex()

  pageNumberLeft: ->
    pageNumber = @leftPageIndex() + 1
    pageNumber-- unless @activity()
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

    pageIndex = @leftPageIndex()

    # Table of contents starts on the right.
    pageIndex -= 1 unless @activity()

    left = -pageIndex * (columnProperties.columnWidth + columnProperties.columnGap)
    pagesCount = 100
    width = pagesCount * columnProperties.columnWidth + (pagesCount - 1) * columnProperties.columnGap

    left: "#{left}rem"
    width: "#{width}rem"
    columnWidth: "#{columnProperties.columnWidth}rem"
    columnGap: "#{columnProperties.columnGap}rem"

  events: ->
    super(arguments...).concat
      'click .move-button.left': @onClickMoveButtonLeft
      'click .move-button.right': @onClickMoveButtonRight

  onClickMoveButtonLeft: ->
    @previousPage()

  onClickMoveButtonRight: ->
    @nextPage()
