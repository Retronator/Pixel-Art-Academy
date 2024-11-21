AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Publication.Article.TableOfContents extends AM.Quill.BlotComponent
  @id: -> 'PixelArtAcademy.Publication.Article.TableOfContents'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'publication-tableofcontents'
    tag: 'div'
    class: 'pixelartacademy-publication-article-tableofcontents'

  onCreated: ->
    super arguments...
    
    @publication = new ComputedField =>
      @quillComponent()?.publication?()

    @contentItems = new ComputedField =>
      return unless publication = @publication()
      _.sortBy publication.contents, 'order'

  part: ->
    contentItem = @currentData()
    PAA.Publication.Part.documents.findOne contentItem.part._id

  events: ->
    super(arguments...).concat
      'click .content-item': @onClickContentItem
  
  onClickContentItem: (event) ->
    publicationComponent = @quillComponent().publicationComponent
    
    contentItem = @currentData()
    publicationComponent.activePartId contentItem.part._id
    publicationComponent.scrollToTop()
