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
    @visiblePageIndex = new ReactiveField 0

    @book = new ComputedField =>
      return unless @home.activities.isCreated()

      bookId = @home.activities.activeBookId()
      book = PAA.StudyGuide.Book.documents.findOne bookId

      if book
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
      1

    @designConstants =
      pageMargins:
        left: 40
        right: 20
      moveButtonExtraWidth: 35

  close: ->
    @visible false

  canMoveLeft: ->
    true

  canMoveRight: ->
    true

  previousPage: ->
    return unless @canMoveLeft()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()

    leftPageIndex -= 2 if leftPageIndex is visiblePageIndex
    visiblePageIndex--

    @leftPageIndex leftPageIndex
    @visiblePageIndex visiblePageIndex

  nextPage: ->
    return unless @canMoveRight()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()

    leftPageIndex += 2 unless leftPageIndex is visiblePageIndex
    visiblePageIndex++

    @leftPageIndex leftPageIndex
    @visiblePageIndex visiblePageIndex

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

  columnProperties: ->
    return unless book = @book()
    margins = @designConstants.pageMargins

    columnWidth: book.design.size.width - margins.left - margins.right
    columnGap: 2 * margins.right

  contentsStyle: ->
    return unless columnProperties = @columnProperties()

    left = -@leftPageIndex() * (columnProperties.columnWidth + columnProperties.columnGap)
    pagesCount = 10
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
