AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Publication.Pages.Admin.Publications.Publication extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication'
  @register @id()

  onCreated: ->
    super arguments...

    @contentItems = new ComputedField =>
      publication = @data()

      # Attach index to content items and sort them.
      contentItems = for contentItem, index in publication.contents
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
    publication = @data()
    contentItem.sortedIndex < publication.contents.length - 1

  events: ->
    super(arguments...).concat
      'click .add-content-item-button': @onClickAddContentItemButton
      'click .content-items .move-up-button': @onClickContentItemsMoveUpButton
      'click .content-items .move-down-button': @onClickContentItemsMoveDownButton
      'click .content-items .remove-button': @onClickContentItemsRemoveButton

  onClickAddContentItemButton: (event) ->
    partId = @$('.new-content-item select').val()
    publication = @data()

    PAA.Publication.addContentItem publication._id, partId

  onClickContentItemsMoveUpButton: (event) ->
    contentItem = @currentData()
    contentItems = @contentItems()
    publication = @data()

    # Place the item in between two items above.
    orderAbove = contentItems[contentItem.sortedIndex - 1].order
    orderTwoAbove = contentItems[contentItem.sortedIndex - 2]?.order or orderAbove - 2
    order = (orderAbove + orderTwoAbove) / 2

    PAA.Publication.updateContentItem publication._id, contentItem.index, {order}

  onClickContentItemsMoveDownButton: (event) ->
    contentItem = @currentData()
    contentItems = @contentItems()
    publication = @data()

    # Place the item in between two items below.
    orderBelow = contentItems[contentItem.sortedIndex + 1].order
    orderTwoBelow = contentItems[contentItem.sortedIndex + 2]?.order or orderBelow + 2
    order = (orderBelow + orderTwoBelow) / 2

    PAA.Publication.updateContentItem publication._id, contentItem.index, {order}

  onClickContentItemsRemoveButton: (event) ->
    contentItem = @currentData()
    publication = @data()

    PAA.Publication.removeContentItem publication._id, contentItem.index
    
  Parent = @
  
  class @ReferenceId extends AM.DataInputComponent
    @register 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.ReferenceId'
    
    constructor: ->
      super arguments...
      
      @realtime = false
    
    load: -> @data()?.referenceId
    save: (value) ->
      publicationId = @data()._id
      PAA.Publication.update publicationId, "referenceId": value

  class @PartSelect extends AM.DataInputComponent
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @publicationComponent = @ancestorComponentOfType PAA.Publication.Pages.Admin.Publications.Publication

    options: ->
      parts = PAA.Publication.Part.documents.fetch()
      
      for part in parts
        name: part.referenceId
        value: part._id

  class @MainPart extends @PartSelect
    @partPropertyName: -> throw new AE.NotImplementedException "Main part selection needs to provide the property name."
    @removePartFunctionName: -> throw new AE.NotImplementedException "Main part selection needs to provide the function name for removing the property."
    
    options: ->
      options = super arguments...
      options.unshift name: '', value: null
      options
    
    load: -> @data()?[@constructor.partPropertyName()]?._id
    save: (value) ->
      publicationId = @data()._id

      if value
        PAA.Publication.update publicationId, "#{@constructor.partPropertyName()}._id": value
        
      else
        PAA.Publication[@constructor.removePartFunctionName()] publicationId

  class @CoverPart extends @MainPart
    @register "PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.CoverPart"
    @partPropertyName: -> 'coverPart'
    @removePartFunctionName: -> 'removeCover'
  
  class @TableOfContentsPart extends @MainPart
    @register "PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.TableOfContentsPart"
    @partPropertyName: -> 'tableOfContentsPart'
    @removePartFunctionName: -> 'removeTableOfContents'

  class @Design
    class @Size
      class @Property extends AM.DataInputComponent
        constructor: ->
          super arguments...

          @type = AM.DataInputComponent.Types.Number
          @realtime = false

        load: -> @data()?.design?.size?[@property]
        save: (value) ->
          publicationId = @data()._id
          PAA.Publication.update publicationId, "design.size.#{@property}": value

      class @Width extends @Property
        @register 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.Design.Size.Width'

        constructor: ->
          super arguments...

          @property = 'width'
          @customAttributes =
            max: 320

      class @Height extends @Property
        @register 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.Design.Size.Height'

        constructor: ->
          super arguments...

          @property = 'height'

    class @SpreadPagesCount extends AM.DataInputComponent
      @register 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.Design.SpreadPagesCount'

      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.Number
        @realtime = false
        @customAttributes =
          min: 1

      load: -> @data()?.design?.spreadPagesCount
      save: (value) ->
        publicationId = @data()._id
        PAA.Publication.update publicationId, "design.spreadPagesCount": value

    class @Class extends AM.DataInputComponent
      @register 'PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.Design.Class'

      constructor: ->
        super arguments...

        @realtime = false

      load: -> @data()?.design?.class
      save: (value) ->
        publicationId = @data()._id
        PAA.Publication.update publicationId, "design.class": value

    class @Part extends Parent.PartSelect
      @register "PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.Part"

      load: ->
        contentItem = @data()
        contentItem.part._id

      save: (value) ->
        contentItem = @data()
        publication = @publicationComponent.data()

        PAA.Publication.updateContentItem publication._id, contentItem.index, 'part._id': value

    class @NewContentItemPart extends Parent.PartSelect
      @register "PixelArtAcademy.Publication.Pages.Admin.Publications.Publication.NewContentItemPart"

      options: ->
        options = super arguments...
        contents = @publicationComponent.data().contents
        existingPartIds = (contentItem.part._id for contentItem in contents)

        _.filter options, (option) => option.value not in existingPartIds

      load: -> null
      save: (value) -> # Empty since we only use this component for part selection.
