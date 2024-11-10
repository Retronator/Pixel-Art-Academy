AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Publication.Article.Figure.Image extends AM.Component
  @id: -> 'PixelArtAcademy.Publication.Article.Figure.Image'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @figure = @ancestorComponentOfType PAA.Publication.Article.Figure

  imageSource: ->
    element = @data()
    element.image.url

  events: ->
    super(arguments...).concat
      'load img': @onLoadImage
      'click img': @onClickImage

  onLoadImage: (event) ->
    image = event.target

    # Make image fit perfectly into the row.
    $(image).parents('.element').eq(0).css
      flexGrow: image.naturalWidth / image.naturalHeight

    # Inform figure that content has updated so that the surrounding article can recalculate the number of pages.
    @figure.contentUpdated()

  onClickImage: (event) ->
    artworks = [
      image: event.target
    ]

    article = @figure.quillComponent()
    article.publicationComponent.home.focusArtworks artworks
