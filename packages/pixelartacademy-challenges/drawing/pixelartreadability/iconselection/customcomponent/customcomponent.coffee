AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection.CustomComponent extends LOI.Component
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection.CustomComponent'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      bookDrag: AEc.ValueTypes.Boolean
      bookOpen: AEc.ValueTypes.Trigger
      bookClose: AEc.ValueTypes.Trigger
      turnPage: AEc.ValueTypes.Trigger
      turnPages: AEc.ValueTypes.Trigger
      
  onCreated: ->
    super arguments...
    
    # Controls whether the book is visible anywhere in the screen.
    @bookVisible = new ReactiveField false
    
    # Controls whether the book should be displayed in the center of the table.
    @bookDisplayed = new ReactiveField false
    
    @_wasActive = false
    @active = new ReactiveField false
    
    @drawingApp = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
    
    @currentPage = new ReactiveField 0
    
  onRendered: ->
    super arguments...
    
    @audio.bookDrag false

    @autorun (computation) =>
      shouldBeActive = @drawingApp.activeAsset()?
  
      if shouldBeActive and not @_wasActive
        # Start rendering the book in closed state.
        @currentPage 0
        @bookVisible true
        
        @_resetActivateTimers()
        @_activeTimeout = Meteor.setTimeout =>
          # Fade in the component.
          @active true

          # Move the book to the center of the table.
          @bookDisplayed true
        ,
          100
        
        @_bookDragTimeout = Meteor.setTimeout =>
          @audio.bookDrag true
        ,
          600
      
      else if @_wasActive and not shouldBeActive
        # End any animation for selecting a reference.
        Meteor.clearTimeout @_switchToBitmapTimeout
        Meteor.clearTimeout @_closeBookTimeout

        # Close the book and move it from the table.
        @currentPage 0
        @bookDisplayed false
        @audio.bookDrag false

        # Fade out the component.
        @_resetActivateTimers()
        @_deactivateTimeout = Meteor.setTimeout =>
          @active false
        ,
          500
        
        # Stop rendering the book.
        @_hideTimeout = Meteor.setTimeout =>
          @bookVisible false
        ,
          1000
  
      @_wasActive = shouldBeActive
      
  _resetActivateTimers: ->
    Meteor.clearTimeout @_activeTimeout
    Meteor.clearTimeout @_deactivateTimeout
    Meteor.clearTimeout @_bookDragTimeout
    Meteor.clearTimeout @_hideTimeout
  
  setPixelPadSize: (drawingApp) ->
    drawingApp.setMaximumPixelPadSize fullscreen: true
  
  onBackButton: ->
    return unless currentPage = @currentPage()
    
    @currentPage if currentPage > 1 then 1 else 0
    
    switch currentPage
      when 1 then @audio.bookClose()
      when 3 then @audio.turnPage()
      else @audio.turnPages()

    # Inform that we've handled the back button.
    true
    
  goToPage: (pageNumber) ->
    @currentPage (pageNumber - 1) // 2 * 2 + 1
  
  activeClass: ->
    'active' if @active()
  
  onCoverClass: ->
    'on-cover' unless @currentPage()
    
  bookDisplayedClass: ->
    'displayed' if @bookDisplayed()
    
  bookOpenClass: ->
    'open' if @currentPage() > 0
  
  canMoveBack: ->
    @currentPage() > 0
    
  canMoveForward: ->
    true
  
  icons8: -> @icons 8, 4
  
  icons16: -> @icons 16, 9

  icons32: -> @icons 32, 2
  
  icons: (size, count) ->
    for number in [1..count]
      number: number
      imageUrl: @versionedUrl "/pixelartacademy/challenges/drawing/pixelartreadability/book-icon-#{size}-#{number}.png"
    
  onTableOfContents: -> @currentPage() is 1
  
  tableOfContentsParts: ->
    return unless contents = @drawingApp.portfolio().activeAsset()?.asset.contents
    _.values contents
  
  pageDataLeft: -> @pageData @pageNumberLeft()
  pageDataRight: -> @pageData @pageNumberRight()
  
  pageData: (pageNumber) ->
    return unless pages = @drawingApp.portfolio().activeAsset()?.asset.pages
    pages[pageNumber]
  
  onPartTitle: ->
    pageData = @currentData()
    pageData.number and pageData.title
  
  pageNumberLeft: -> @currentPage()
  pageNumberRight: -> @currentPage() + 1
    
  events: ->
    super(arguments...).concat
      'click .book-closed': @onClickBookClosed
      'click .next-page': @onClickNextPage
      'click .previous-page': @onClickPreviousPage
      'click .contents-part .title': @onClickContentsPartTitle
  
  onClickBookClosed: (event) ->
    @currentPage 1
    
    @audio.turnPage()
  
  onClickNextPage: (event) ->
    currentPage = @currentPage()
    
    if currentPage
      @audio.turnPage()
      
    else
      @audio.bookOpen()

    @currentPage if currentPage then currentPage + 2 else 1
  
  onClickPreviousPage: (event) ->
    currentPage = @currentPage()
    
    if currentPage is 1
      @audio.bookClose()
      
    else
      @audio.turnPage()
    
    @currentPage if currentPage is 1 then 0 else currentPage - 2
  
  onClickContentsPartTitle: (event) ->
    contentsPart = @currentData()
    
    @goToPage contentsPart.titlePageNumber
    
    if contentsPart.number is 1
      @audio.turnPage()
    
    else
      @audio.turnPages()
