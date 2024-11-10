AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
PAA = PixelArtAcademy

class PAA.Publication.Component extends AM.Component
  @register 'PixelArtAcademy.Publication.Component'

  constructor: (@publicationId) ->
    super arguments...
    
    @enabled = new ReactiveField false
    @opened = new ReactiveField false
    @activePartId = new ReactiveField null
  
  onCreated: ->
    super arguments...
    
    @autorun (computation) =>
      PAA.Publication.Part.forPublication.subscribeContent @, @publicationId
      PAA.Publication.Part.forPublication.subscribe @, @publicationId
    
    @leftPageIndex = new ReactiveField 0
    @visiblePageIndex = new ReactiveField 1
    @pagesCount = new ReactiveField null
    @manualContentUpdatedDependency = new Tracker.Dependency
    
    @publication = new ComputedField =>
      PAA.Publication.documents.findOne @publicationId
      
    @coverPart = new ComputedField =>
      return unless publication = @publication()
      
      PAA.Publication.Part.documents.findOne publication.coverPart?._id
    
    @spreadPagesCount = new ComputedField =>
      @publication()?.design?.spreadPagesCount or 1
      
    @contentItems = new ComputedField =>
      return [] unless publication = @publication()

      _.sortBy publication.contents, 'order'
      
    @activePart = new ComputedField =>
      PAA.Publication.Part.documents.findOne @activePartId()
      
    # Automatically activate the only part if there is no cover.
    @autorun (computation) =>
      return unless publication = @publication()
      return unless publication.contents.length is 1
      return if publication.coverPart

      @activePartId publication.contents[0].part._id
  
  onRendered: ->
    super arguments...

    # Reactively update pages count.
    @autorun (computation) =>
      return unless @publication()
      return unless @opened()

      # Update when active content item or page index changes.
      @activePart()
      @visiblePageIndex()

      @updatePagesCount()

    # React to active content item changes.
    @autorun (computation) =>
      activePart = @activePart()

      if activePart
        # If we're coming from the table of contents, go to first page of the article.
        unless @_lastActivePart
          @leftPageIndex 0
          @visiblePageIndex 0

      else
        # Remember which page on the table of contents we were.
        @_lastTableOfContentsVisiblePageIndex = @visiblePageIndex()

      @_lastActivePart = activePart
      
  enable: ->
    @enabled true
  
  disable: ->
    @enabled false
    @opened false
    
    @scrollToTop()
    
  open: ->
    @opened true
    
    return unless publication = @publication()

    if publication.contents.length is 1
      @activePartId publication.contents[0].part._id
      
    else
      @activePartId null
      
    @leftPageIndex 0
    @visiblePageIndex 0
    @scrollToTop()
      
  close: ->
    @opened false
    
    @scrollToTop()
    
  back: ->
    # You can't go back if you're not opened.
    return unless @opened()

    # You can't go back if you're on a single part.
    return unless publication = @publication()
    return if publication.contents.length is 1 and not publication.coverPart
    
    # Return to the table of contents or close the publication.
    if @activePartId()
      @goToTableOfContents()
    
    else
      @close()
      
    # Inform that we could perform a back action.
    true
    
  goToTableOfContents: ->
    spreadPagesCount = @spreadPagesCount()
    
    # Return to the page of the table of contents that we last saw.
    @visiblePageIndex @_lastTableOfContentsVisiblePageIndex
    @leftPageIndex Math.floor(@_lastTableOfContentsVisiblePageIndex / spreadPagesCount) * spreadPagesCount
    @activePartId null

    @scrollToTop()

  canMoveLeft: ->
    # We can move left if we're not on the first page.
    @visiblePageIndex()

  canMoveRight: ->
    # Are we on the last page of the section?
    @visiblePageIndex() + 1 < @pagesCount()

  previousPage: ->
    return unless @canMoveLeft()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()
    
    spreadPagesCount = @spreadPagesCount()
    leftPageIndex -= spreadPagesCount if leftPageIndex is visiblePageIndex
    visiblePageIndex--

    @leftPageIndex leftPageIndex
    @visiblePageIndex visiblePageIndex

    @scrollToTop()

  nextPage: ->
    return unless @canMoveRight()

    leftPageIndex = @leftPageIndex()
    visiblePageIndex = @visiblePageIndex()
    
    spreadPagesCount = @spreadPagesCount()
    leftPageIndex += spreadPagesCount unless leftPageIndex is visiblePageIndex
    visiblePageIndex++

    @leftPageIndex leftPageIndex
    @visiblePageIndex visiblePageIndex

    @scrollToTop()

  scrollToTop: ->
    return unless @isRendered()
    
    scrollArea = @$(".scroll-area")[0]
    return unless currentScrollTop = scrollArea.scrollTop

    targetScrollTop = 0

    $(".pixelartacademy-publication-component").velocity
      tween: [targetScrollTop, currentScrollTop]
    ,
      duration: 500
      easing: 'ease-in-out'
      progress: (elements, complete, remaining, start, tweenValue) =>
        scrollArea.scrollTop = tweenValue

  contentUpdated: ->
    @manualContentUpdatedDependency.changed()

  updatePagesCount: ->
    # Depend on manual update events.
    @manualContentUpdatedDependency.depend()
    
    if @activePartId()
      @_updatePagesCountActivity()

    else
      # Depend on content items.
      @contentItems()

      @_updatePagesCountTableOfContents()

  _updatePagesCountActivity: ->
    @_updatePagesCountViaEndPage()

  _updatePagesCountTableOfContents: ->
    @_updatePagesCountViaEndPage()

  _updatePagesCountViaEndPage: ->
    return # TODO
    return unless publication = @publication()

    scale = @display.scale()
    pageWidth = publication.design.size.width * scale

    Meteor.setTimeout =>
      # Search for the new end page.
      endPageLeft = @$('.end-page').position().left
      pagesCount = Math.ceil (endPageLeft + 1) / pageWidth

      @pagesCount pagesCount
    ,
      100
  
  enabledClass: ->
    'enabled' if @enabled()
  
  pageClass: ->
    if @activePartId()
      'content-part'
      
    else
      if @opened()
        'table-of-contents'
        
      else
        'cover'
  
  showArticle: ->
    @activePartId() or not @opened()
  
  hasTableOfContents: ->
    return unless publication = @publication()
    
    publication.contents.length > 1
  
  publicationAreaStyle: ->
    return unless publication = @publication()
    
    if @opened() and @leftPageIndex() is @visiblePageIndex()
      left = publication.design.size.width
      
    else
      left = 0
    
    left: "#{left}rem"
    width: "#{publication.design.size.width}rem"
    height: "#{publication.design.size.height}rem"
  
  publicationStyle: ->
    return unless publication = @publication()
    
    left: "#{if @opened() then -publication.design.size.width else 0}rem"
    
  events: ->
    super(arguments...).concat
      'click .cover': @onClickCover
      'click .content-item': @onClickContentItem
      
  onClickCover: ->
    return unless @enabled()
    
    @open()
    
  onClickContentItem: (event) ->
    contentItem = @currentData()
    @activePartId contentItem.part._id
    @scrollToTop()
