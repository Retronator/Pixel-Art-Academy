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
    
    @goToPage if currentPage > 1 then 1 else 0

    # Inform that we've handled the back button.
    true
    
  goToPage: (pageNumber) ->
    previousPageNumber = @currentPage()

    # Current page refers to the page number on the left spread (or 0 on the cover), so we need to round it down.
    newPageNumber = Math.max 0, (pageNumber - 1) // 2 * 2 + 1

    @currentPage newPageNumber
    
    if previousPageNumber is 0 and pageNumber is 1
      @audio.bookOpen()
    
    else if previousPageNumber is 1 and pageNumber is 0
      @audio.bookClose()
    
    else
      pagesTurned = Math.abs newPageNumber - previousPageNumber
      
      if pagesTurned > 2
        @audio.turnPages()
        
      else
        @audio.turnPage()
  
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
    return unless pages = @drawingApp.portfolio().activeAsset()?.asset.pages
    @currentPage() < pages.length - 1
  
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
  
  onIconEntry: ->
    pageData = @currentData()
    pageData.iconNumber
    
  binaryData: (size) ->
    iconEntry = @currentData()
    bytesCount = (size ** 2) / 8
    
    if bitmap = @getBitmapForIcon iconEntry.label, size
      ("00000000" for i in [0...bytesCount])
      
    else
      ("00000000" for i in [0...bytesCount])
    
  decimalData: (size) ->
    iconEntry = @currentData()
    bytesCount = (size ** 2) / 8
    
    if bitmap = @getBitmapForIcon iconEntry.label, size
      (0 for i in [0...bytesCount])
    
    else
      (0 for i in [0...bytesCount])
  
  hexadecimalData: (size) ->
    iconEntry = @currentData()
    bytesCount = (size ** 2) / 8
    
    if bitmap = @getBitmapForIcon iconEntry.label, size
      ("00" for i in [0...bytesCount])
    
    else
      ("00" for i in [0...bytesCount])
  
  getBitmapForIcon: (label, size) ->
    return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'
    return unless bitmapId = icons[label]?.sizes[size]?.bitmapId
    LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
  
  pageNumberLeft: -> @currentPage()
  pageNumberRight: -> @currentPage() + 1
    
  events: ->
    super(arguments...).concat
      'click .book-closed': @onClickBookClosed
      'click .next-page': @onClickNextPage
      'click .previous-page': @onClickPreviousPage
      'click .contents-part .title': @onClickContentsPartTitle
      'click .icon-entry': @onClickIconEntry
  
  onClickBookClosed: (event) ->
    @goToPage 1
  
  onClickNextPage: (event) ->
    currentPage = @currentPage()
    
    @goToPage if currentPage then currentPage + 2 else 1
  
  onClickPreviousPage: (event) ->
    currentPage = @currentPage()
    
    @goToPage if currentPage is 1 then 0 else currentPage - 2
  
  onClickContentsPartTitle: (event) ->
    contentsPart = @currentData()
    
    @goToPage contentsPart.titlePageNumber
  
  onClickIconEntry: (event) ->
    iconEntry = @currentData()
    
    @goToPage iconEntry.pageNumber
