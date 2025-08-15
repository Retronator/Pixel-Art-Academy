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
      
    @unlockedParts = new ComputedField =>
      return [] unless LOI.adventure
      
      currentSituation = new LOI.Adventure.Situation
        location: PAA.Publication.Part.Location
      
      currentSituation.things()
  
  unlockedClass: ->
    contentItem = @currentData()
    
    'unlocked' if contentItem.part.referenceId in @unlockedParts()
  
  unreadClass: ->
    contentItem = @currentData()
    
    partState = PAA.Publication.Part.getStateForReferenceId contentItem.part.referenceId
    
    'unread' unless partState 'read'

  part: ->
    contentItem = @currentData()
    PAA.Publication.Part.documents.findOne contentItem.part._id

  events: ->
    super(arguments...).concat
      'click .content-item': @onClickContentItem
  
  onClickContentItem: (event) ->
    contentItem = @currentData()
    return unless contentItem.part.referenceId in @unlockedParts()
  
    publicationComponent = @quillComponent().publicationComponent
    publicationComponent.goToPart contentItem.part._id
