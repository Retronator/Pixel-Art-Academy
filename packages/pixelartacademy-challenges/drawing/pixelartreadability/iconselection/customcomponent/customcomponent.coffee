AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
PAA = PixelArtAcademy
LOI = LandsOfIllusions

IconSelection = PAA.Challenges.Drawing.PixelArtReadability.IconSelection

class IconSelection.CustomComponent extends LOI.Component
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection.CustomComponent'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      bookPan: AEc.ValueTypes.Number
      bookDrag: AEc.ValueTypes.Boolean
      bookOpen: AEc.ValueTypes.Trigger
      bookClose: AEc.ValueTypes.Trigger
      turnPage: AEc.ValueTypes.Trigger
      turnPages: AEc.ValueTypes.Trigger
      
  constructor: (@iconSelection) ->
    super arguments...
  
  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
    
    @_dragTimeLeft = 0
    
    # Controls whether the book is visible anywhere in the screen.
    @bookVisible = new ReactiveField false
    
    # Controls whether the book should be displayed in the center of the table.
    @bookDisplayed = new ReactiveField false
    
    @_wasActive = false
    @active = new ReactiveField false
    
    @drawingApp = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
    
    @currentPage = new ReactiveField 0
    
    # Go to the right page based on the current asset.
    @activeLabel = new ComputedField =>
      return unless parameter = AB.Router.getParameter 'parameter3'
      return if parameter is @iconSelection.constructor.defaultUrl()
      
      return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'
      
      for label, labelEntry of icons
        for size, icon of labelEntry.sizes
          if icon.bitmapId is parameter
            return label
            
      null
    
    @autorun (computation) =>
      return unless activeLabel = @activeLabel()
      
      # Find the right page number for this icon.
      return unless pages = @drawingApp.portfolio().activeAsset()?.asset.pages
      
      for page in pages when page
        if page.label is activeLabel
          @goToPage page.pageNumber
    
  onRendered: ->
    super arguments...
    
    @audio.bookDrag false
    
    @autorun (computation) =>
      if @bookVisible()
        Tracker.afterFlush =>
          return unless @isRendered()
          @_bookOpen = @$('.book-open')[0]
        
      else
        @_bookOpen = null
        
    # Note: We have to limit reactivity for the bookDrag to trigger
    # correctly, so we precalculate editorActive to a boolean.
    @editorActive = new ComputedField =>
      return unless editor = @drawingApp.editor()
      return unless editor.isCreated()
      editor.active()

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
          
          @_dragWhenActiveAutorun?.stop()
          @_dragWhenActiveAutorun = Tracker.autorun (computation) =>
            editorActive = @editorActive()
            Tracker.nonreactive =>
              @audio.bookDrag not editorActive
              @_dragTimeLeft = 1.5
        ,
          600
      
      else if @_wasActive and not shouldBeActive
        # Stop controlling the book drag variable.
        @_dragWhenActiveAutorun?.stop()
      
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
      
  onDestroyed: ->
    super arguments...
    
    @app.removeComponent @
    @_dragWhenActiveAutorun?.stop()
    
  _resetActivateTimers: ->
    Meteor.clearTimeout @_activeTimeout
    Meteor.clearTimeout @_deactivateTimeout
    Meteor.clearTimeout @_bookDragTimeout
    Meteor.clearTimeout @_hideTimeout
  
  _selectIcon: (label, size) ->
    # See if we need to create the bitmap for this icon.
    unless bitmapId = @_getBitmapIdForIcon label, size
      PAA.Challenges.Drawing.PixelArtReadability.addIcon label, size
    
    # Find out the icon's bitmap ID and go to the asset.
    Tracker.autorun (computation) =>
      return unless bitmapId = @_getBitmapIdForIcon label, size
      computation.stop()

      # Select the correct bitmap.
      AB.Router.changeParameters
        parameter3: bitmapId
        
      # Enter the editor after preview asset scale has been applied. Flushing waits for recomputation of the property.
      Tracker.afterFlush =>
        # Additionally wait for the URL to change before adding the edit parameter.
        Meteor.setTimeout =>
          AB.Router.changeParameters
            parameter3: bitmapId
            parameter4: 'edit'
  
  setPixelPadSize: (drawingApp) ->
    drawingApp.setMaximumPixelPadSize fullscreen: true
  
  onBackButton: ->
    # Remove selected icon if needed.
    if @activeLabel()
      AB.Router.changeParameters
        parameter3: @iconSelection.constructor.defaultUrl()
        parameter4: null
      
      # Inform that we've handled the back button.
      return true
    
    return unless currentPage = @currentPage()
    
    @goToPage if currentPage > 1 then 1 else 0

    # Inform that we've handled the back button.
    true
    
  goToPage: (pageNumber) ->
    previousPageNumber = @currentPage()

    # Current page refers to the page number on the left spread (or 0 on the cover), so we need to round it down.
    newPageNumber = Math.max 0, (pageNumber - 1) // 2 * 2 + 1
    return if newPageNumber is previousPageNumber

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
    
  editorActiveClass: -> @drawingApp.editorActiveClass()
  
  onCoverClass: ->
    'on-cover' unless @currentPage()
    
  bookDisplayedClass: ->
    'displayed' if @bookDisplayed()
    
  bookOpenClass: ->
    'open' if @currentPage() > 0
  
  volumeNumber: -> @iconSelection.constructor.volumeNumber()
  
  icons8: -> @icons 8
  
  icons16: -> @icons 16
  
  icons32: -> @icons 32

  icons: (size) ->
    count = @iconSelection.constructor.coverIconsCounts()[size]
  
    for number in [1..count]
      number: number
      imageUrl: @versionedUrl "/pixelartacademy/challenges/drawing/pixelartreadability/book-icon-#{size}-#{number}.png"
    
  onTableOfContents: -> @currentPage() <= 3
  
  tableOfContentsPagesStyle: ->
    left: "#{-(145 + 18) * (@currentPage() - 1)}rem"
  
  tableOfContentsParts: ->
    return unless contents = @drawingApp.portfolio().activeAsset()?.asset.contents
    _.values contents
  
  iconEntrySizes: -> [{size: 8}, {size: 16}, {size: 32}]
  
  iconStatusClass: ->
    return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'

    {label, size} = @_getLabelAndSize()
    return unless iconData = icons[label]?.sizes[size]

    return 'completed' if iconData.completed
    return 'started' if iconData.started
  
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
    
  iconSection8: -> @iconSection 8
  iconSection16: -> @iconSection 16
  iconSection32: -> @iconSection 32
  iconSection: (size) -> {size}
    
  binaryData: (joinWithNewLine) ->
    bytes = (byte.toString(2).padStart(8, '0') for byte in @_getBytes())
    @_joinBytes bytes, joinWithNewLine
    
  decimalData: (joinWithNewLine) ->
    @_joinBytes @_getBytes(), joinWithNewLine
    
  hexadecimalData: (joinWithNewLine) ->
    bytes = (byte.toString(16).padStart(2, '0') for byte in @_getBytes())
    @_joinBytes bytes, joinWithNewLine
    
  _getBytes: ->
    if bitmap = @_getBitmapForCurrentIcon()
      bytesPerRow = bitmap.bounds.width / 8
      bytes = []
      
      for y in [0...bitmap.bounds.height]
        for byteIndex in [0...bytesPerRow]
          xStart = byteIndex * 8
          byte = 0

          for xOffset in [0...8]
            x = xStart + xOffset
            byte += 2 ** (7 - xOffset) if bitmap.getPixelForLayerAtCoordinates 0, x, y
            
          bytes.push byte
          
      bytes
    
    else
      {size} = @_getLabelAndSize()
      bytesCount = (size ** 2) / 8

      (0 for i in [0...bytesCount])
  
  _joinBytes: (bytes, joinWithNewLine) ->
    bytes.join if joinWithNewLine then '<br/>' else ',<wbr>'
    
  _getBitmapForCurrentIcon: ->
    {label, size} = @_getLabelAndSize()
    
    @_getBitmapForIcon label, size
  
  _getBitmapForIcon: (label, size) ->
    return unless bitmapId = @_getBitmapIdForIcon label, size
    LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
  
  _getBitmapIdForIcon: (label, size) ->
    return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'
    icons[label]?.sizes[size]?.bitmapId
    
  _getLabelAndSize: ->
    iconSection = @currentData()
    iconEntry = @parentDataWith 'label'
    
    label: iconEntry.label
    size: iconSection.size
  
  pageNumberLeft: -> @currentPage()
  pageNumberRight: -> @currentPage() + 1
  
  canMoveBack: ->
    @currentPage() > 0
  
  canMoveForward: ->
    return unless pages = @drawingApp.portfolio().activeAsset()?.asset.pages
    @currentPage() < pages.length - 1
  
  update: (appTime) ->
    return unless @_bookOpen and @_dragTimeLeft > 0
    @_dragTimeLeft -= appTime.elapsedAppTime
    
    @audio.bookPan PAA.PixelPad.Apps.Drawing.Editor.Desktop.compressPan AEc.getPanForElement @_bookOpen
  
  events: ->
    super(arguments...).concat
      'click .book-closed': @onClickBookClosed
      'click .next-page': @onClickNextPage
      'click .previous-page': @onClickPreviousPage
      'click .contents-part .title': @onClickContentsPartTitle
      'click .icon-entry': @onClickIconEntry
      'click .icon-section': @onClickIconSection
  
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
    
  onClickIconSection: (event) ->
    return if @drawingApp.editor().active()
    
    {label, size} = @_getLabelAndSize()

    @_selectIcon label, size
