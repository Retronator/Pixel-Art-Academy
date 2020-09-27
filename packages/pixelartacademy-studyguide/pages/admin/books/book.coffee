AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Admin.Books.Book extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book'
  @register @id()

  onCreated: ->
    super arguments...

    @contentItems = new ComputedField =>
      book = @data()

      # Attach index to content items and sort them.
      contentItems = for contentItem, index in book.contents
        _.extend {index}, contentItem

      contentItems = _.sortBy contentItems, 'order'

      # Attach sorted index.
      for contentItem, index in contentItems
        contentItem.sortedIndex = index

      contentItems

  canMoveContentItemUp: ->
    contentItem = @currentData()
    contentItem.sortedIndex > 0

  canMoveContentItemDown: ->
    contentItem = @currentData()
    book = @data()
    contentItem.sortedIndex < book.contents.length - 1

  events: ->
    super(arguments...).concat
      'click .add-content-item-button': @onClickAddContentItemButton
      'click .content-items .move-up-button': @onClickContentItemsMoveUpButton
      'click .content-items .move-down-button': @onClickContentItemsMoveDownButton
      'click .content-items .remove-button': @onClickContentItemsRemoveButton

  onClickAddContentItemButton: (event) ->
    activityId = @$('.new-content-item select').val()
    book = @data()

    PAA.StudyGuide.Book.addContentItem book._id, activityId

  onClickContentItemsMoveUpButton: (event) ->
    contentItem = @currentData()
    contentItems = @contentItems()
    book = @data()

    # Place the item in between two items above.
    orderAbove = contentItems[contentItem.sortedIndex - 1].order
    orderTwoAbove = contentItems[contentItem.sortedIndex - 2]?.order or orderAbove - 2
    order = (orderAbove + orderTwoAbove) / 2

    PAA.StudyGuide.Book.updateContentItem book._id, contentItem.index, {order}

  onClickContentItemsMoveDownButton: (event) ->
    contentItem = @currentData()
    contentItems = @contentItems()
    book = @data()

    # Place the item in between two items below.
    orderBelow = contentItems[contentItem.sortedIndex + 1].order
    orderTwoBelow = contentItems[contentItem.sortedIndex + 2]?.order or orderBelow + 2
    order = (orderBelow + orderTwoBelow) / 2

    PAA.StudyGuide.Book.updateContentItem book._id, contentItem.index, {order}

  onClickContentItemsRemoveButton: (event) ->
    contentItem = @currentData()
    book = @data()

    PAA.StudyGuide.Book.removeContentItem book._id, contentItem.index

  class @Design
    class @Size
      class @Property extends AM.DataInputComponent
        constructor: ->
          super arguments...

          @type = AM.DataInputComponent.Types.Number
          @realtime = false

        load: -> @currentData()?.design?.size?[@property]
        save: (value) ->
          bookId = @currentData()._id
          PAA.StudyGuide.Book.update bookId, "design.size.#{@property}": value

      class @Width extends @Property
        @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book.Design.Size.Width'

        constructor: ->
          super arguments...

          @property = 'width'
          @customAttributes =
            max: 320

      class @Height extends @Property
        @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book.Design.Size.Height'

        constructor: ->
          super arguments...

          @property = 'height'

      class @Thickness extends @Property
        @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book.Design.Size.Thickness'

        constructor: ->
          super arguments...

          @property = 'thickness'
          @customAttributes =
            min: 25

    class @Class extends AM.DataInputComponent
      @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book.Design.Class'

      constructor: ->
        super arguments...

        @realtime = false

      load: -> @currentData()?.design?.class
      save: (value) ->
        bookId = @currentData()._id
        PAA.StudyGuide.Book.update bookId, "design.class": value

    class @ActivitySelect extends AM.DataInputComponent
      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.Select

      onCreated: ->
        super arguments...

        @bookComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Books.Book

      options: ->
        for goalId, goal of PAA.StudyGuide.Goals
          name: goalId
          value: goal.activity()._id

    class @Activity extends @ActivitySelect
      @register "PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book.Activity"

      load: ->
        contentItem = @data()
        contentItem.activity._id

      save: (value) ->
        contentItem = @data()
        book = @bookComponent.data()

        PAA.StudyGuide.Book.updateContentItem book._id, contentItem.index, 'activity._id': value

    class @NewContentItemActivity extends @ActivitySelect
      @register "PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book.NewContentItemActivity"

      options: ->
        options = super arguments...
        contents = @bookComponent.data().contents
        existingActivityIds = (contentItem.activity._id for contentItem in contents)

        _.filter options, (option) => option.value not in existingActivityIds

      load: -> null
      save: (value) -> # Empty since we only use this component for activity selection.
