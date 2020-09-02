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
      290

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

  activitiesStyle: ->
    left: "#{@left()}rem"
    bottom: "#{@home.safeHeightGap() + @home.heightConstants.tableSafeArea}rem"
    width: "#{@width()}rem"
    height: "#{@home.contentSafeHeight() - @home.heightConstants.tableSafeArea}rem"

  bookStyle: ->
    book = @currentData()
    size = book.design?.size
    width = Math.round (size?.height or 500) / 3.75
    height = Math.round (size?.thickness or 25) / 3.75

    width: "#{width}rem"
    height: "#{height}rem"
    lineHeight: "#{height}rem"

  pagesStyle: ->
    book = @currentData()
    size = book.design?.size

    width: "#{1 + Math.round (size?.width or 320) / 100}rem"
