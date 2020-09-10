AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Activities extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Activities'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    @left = new ComputedField => @home.safeWidthGap()

    @width = new ComputedField =>
      295

    PAA.StudyGuide.Book.all.subscribe @

    @bookGroups = new ComputedField =>
      bookGroups = []
      books = PAA.StudyGuide.Book.documents.fetch {},
        fields:
          contents: 0

      for book in books
        groupIndex = book.position?.groupIndex or 0
        bookGroups[groupIndex] ?=
          books: []

        bookGroups[groupIndex].books.push book

      for bookGroup in bookGroups
        bookGroup.books = _.sortBy bookGroup.books, 'position.groupOrder'

      bookGroups

    @activeBookId = new ComputedField =>
      return unless slug = AB.Router.getParameter 'pageOrBook'
      book = PAA.StudyGuide.Book.documents.findOne {slug}
      book?._id

  activitiesStyle: ->
    left: "#{@left()}rem"
    bottom: "#{@home.safeHeightGap() + @home.heightConstants.tableSafeArea}rem"
    width: "#{@width()}rem"
    height: "#{@home.contentSafeHeight() - @home.heightConstants.tableSafeArea}rem"

  bookActiveClass: ->
    book = @currentData()
    'active' if book._id is @activeBookId()

  bookStyle: ->
    book = @currentData()
    size = book.design?.size
    width = Math.round (size?.height or 500) / 3.75
    height = Math.round (size?.thickness or 25) / 3.75

    marginTop = if book._id is @activeBookId() then -height else 0
    marginLeft = Math.floor Math.random() * 10

    width: "#{width}rem"
    height: "#{height}rem"
    marginTop: "#{marginTop}rem"
    marginLeft: "#{marginLeft}rem"
    lineHeight: "#{height}rem"

  pagesStyle: ->
    book = @currentData()
    size = book.design?.size

    width: "#{1 + Math.round (size?.width or 320) / 100}rem"

  events: ->
    super(arguments...).concat
      'click .book': @onClickBook

  onClickBook: (event) ->
    book = @currentData()
    AB.Router.setParameter 'pageOrBook', book.slug
