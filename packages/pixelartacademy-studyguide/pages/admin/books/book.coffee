AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Admin.Books.Book extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Books.Book'
  @register @id()

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
