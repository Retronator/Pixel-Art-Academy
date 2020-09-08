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
    @onRightPage = new ReactiveField false

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

    @designConstants =
      pageMargin: 10

  close: ->
    @visible false

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
      if @onRightPage()
        left = viewportWidth - fullWidth

      else
        left = 0

    else
      left = horizontalGap - fullWidth

    left: "#{left}rem"
    padding: "#{verticalGap}rem #{horizontalGap}rem"

  bookStyle: ->
    return unless book = @book()

    width: "#{book.design.size.width * 2}rem"
    height: "#{book.design.size.height}rem"

  contentsStyle: ->
    return unless book = @book()
    pageMargin = @designConstants.pageMargin

    margin: "#{pageMargin}rem"
    columnWidth: "#{book.design.size.width - 2 * pageMargin}rem"
    columnGap: "#{2 * pageMargin}rem"
    height: "#{book.design.size.height - 2 * pageMargin}rem"
