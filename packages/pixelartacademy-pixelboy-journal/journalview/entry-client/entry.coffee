AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = require 'quill'
Block = Quill.import 'blots/block'

class PAA.PixelBoy.Apps.Journal.JournalView.Entry extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  constructor: (@entries, @entryId) ->
    super

    @journalDesign = @entries.journalDesign

  onCreated: ->
    super

    @quill = new AE.ReactiveWrapper null

    @display = LOI.adventure.interface.display

    @currentPageIndex = new ReactiveField 0
    @pagesCount = new ReactiveField 0
    
    @entry = new ComputedField =>
      PAA.Practice.Journal.Entry.documents.findOne @entryId

    @objectsAreaExpanded = new ReactiveField false

    $(window).on 'mouseup.pixelartacademy-pixelboy-apps-journal-journalview-entry', (event) => @onMouseUpWindow event

  onRendered: ->
    super

    @$entry = @$('.pixelartacademy-pixelboy-apps-journal-journalview-entry')

    # Reactively display the correct page.
    @autorun (computation) =>
      @_updateEntryScrollLeft()

    # Initialize quill.
    quill = new Quill @$('.writing-area')[0],
      formats: [
        'bold'
        'italic'
        'link'
        'strike'
        'list'
        'timestamp'
        'image'
      ]

    @quill quill

    # Insert the starting template on a new entry.
    quill.insertEmbed 0, 'timestamp', {}, Quill.sources.API unless @entryId

    quill.on 'text-change', (delta, oldDelta, source) =>
      unless @entryId
        # This is an empty entry, so start it, but not if we have any images still uploading.
        delta = @quill().getContents()

        for operation in delta.ops
          return if operation.insert?.image?.file

        @entries.startEntry delta
        return

      # Update the entry if this was a user update.
      PAA.Practice.Journal.Entry.updateContent @entryId, delta.ops if source is Quill.sources.USER

    quill.on 'editor-change', =>
      # Update total pages count.
      @updatePagesCount()

      # Trigger reactive updates.
      @quill.updated()

    # Update quill content.
    @autorun (computation) =>
      return unless entry = @entry()

      # See if we already have the correct content.
      currentContent = quill.getContents().ops
      return if EJSON.equals entry.content, currentContent

      # The content is new, update.
      quill.setContents entry.content, Quill.sources.API
      
      # HACK: Make sure the new contents match what we set. If they're not, we have some unsupported formats included 
      # in our content. In that case we should completely replace the saved content (instead of just passing the delta).
      currentContent = quill.getContents().ops

      unless EJSON.equals entry.content, currentContent
        PAA.Practice.Journal.Entry.replaceContent @entryId, currentContent

      # Move the cursor to the end.
      @moveCursorToEnd()

  onDestroyed: ->
    super

    $(window).off '.pixelartacademy-pixelboy-apps-journal-journalview-entry'

  updatePagesCount: ->
    # See how far the last item in the editor appears.
    lastChild = @$('.ql-editor > *:last-child')

    unless lastChild?.length
      # We have no elements yet.
      @pagesCount 0
      return

    scale = @display.scale()
    lastLeft = lastChild.position().left / scale

    options = @journalDesign.writingAreaOptions()
    pageWidth = options.width + options.gap

    lastPageLocation = lastLeft / pageWidth
    lastPageIndex = Math.floor lastPageLocation

    @pagesCount lastPageIndex + 1

  previousPage: ->
    # Deselect when changing pages.
    @quill().setSelection null

    # We can't go back if we're at the first page.
    currentPageIndex = @currentPageIndex()
    return false if currentPageIndex is 0

    options = @journalDesign.writingAreaOptions()
    @currentPageIndex currentPageIndex - options.pagesPerViewport

    true

  nextPage: ->
    # Deselect when changing pages.
    @quill().setSelection null

    # We can't go forward if we're on the last viewport.
    options = @journalDesign.writingAreaOptions()

    currentPageIndex = @currentPageIndex()
    currentViewportIndex = Math.floor currentPageIndex / options.pagesPerViewport

    pagesCount = @pagesCount()
    viewportsCount = Math.ceil pagesCount / options.pagesPerViewport

    # Note: Viewport counts could be 0 if there are no pages.
    return false if currentViewportIndex >= viewportsCount - 1

    @currentPageIndex currentPageIndex + options.pagesPerViewport

    true

  goToLastPage: ->
    return unless pagesCount = @pagesCount()

    options = @journalDesign.writingAreaOptions()
    viewportsCount = Math.ceil pagesCount / options.pagesPerViewport

    lastViewportIndex = viewportsCount - 1
    pageIndex = lastViewportIndex * options.pagesPerViewport
    
    @currentPageIndex pageIndex

  focus: ->
    @quill().focus()

  moveCursorToEnd: ->
    end = @quill().getLength()
    @quill().setSelection end, 0

  _updateEntryScrollLeft: ->
    pageIndex = @currentPageIndex()
    scale = @display.scale()
    options = @journalDesign.writingAreaOptions()

    viewportWidth = options.pagesPerViewport * (options.width + options.gap)
    viewportIndex = pageIndex / options.pagesPerViewport

    @$entry.scrollLeft viewportWidth * viewportIndex * scale

  writingAreaStyle: ->
    options = @journalDesign.writingAreaOptions()

    # Always show two additional viewport worth of pages, so that there is enough content for scrolling to reach its
    # desired place, especially when browser automatically changes it on text cursor movement.
    displayedPages = @pagesCount() + 2 * options.pagesPerViewport
    width = displayedPages * options.width + (displayedPages - 1) * options.gap

    left: "#{options.left}rem"
    top: "#{options.top}rem"
    width: "#{width}rem"
    height: "#{options.height}rem"
    columnCount: displayedPages
    columnGap: "#{options.gap}rem"

  objectsAreaStyle: ->
    return unless quill = @quill.withUpdates()

    # Objects interface is shown when the cursor is on an empty line.
    return unless range = quill.getSelection()
    return if range.length

    [block, offset] = quill.scroll.descendant Block, range.index
    return unless block?.domNode.firstChild instanceof HTMLBRElement

    lineBounds = quill.getBounds range
    scale = @display.scale()
    options = @journalDesign.writingAreaOptions()

    left: lineBounds.left + options.left * scale
    width: options.width * scale
    top: lineBounds.top + lineBounds.height * 0.5 + options.top * scale
    display: 'block'

  objectsAreaExpandedClass: ->
    'expanded' if @objectsAreaExpanded()

  objects: ->
    [
      type: 'image'
      name: "Image"
    ,
      type: 'todo'
      name: "To-do task"
    ]

  events: ->
    super.concat
      'scroll .pixelartacademy-pixelboy-apps-journal-journalview-entry': @onScrollEntry
      'click .writing-area': @onClickWritingArea
      'click .toggle-objects-button': @onClickToggleObjectsButton
      'click .image .insert-object-button': @onClickInsertObjectButtonImage
      'click .todo .insert-object-button': @onClickInsertObjectButtonToDo

  onScrollEntry: (event) ->
    # Calculate which page we should be on.
    scrollLeft = event.target.scrollLeft
    scale = @display.scale()

    options = @journalDesign.writingAreaOptions()
    viewportWidth = options.pagesPerViewport * (options.width + options.gap)

    newViewportLocation = scrollLeft / scale

    # See if we need to turn pages backwards or forward.
    currentViewportIndex = @currentPageIndex() / options.pagesPerViewport
    currentViewportLocation = currentViewportIndex * viewportWidth

    if newViewportLocation > currentViewportLocation
      # Move the page forward.
      newViewportIndex = Math.ceil newViewportLocation / viewportWidth

    else if newViewportLocation < currentViewportLocation
      # Move the page backward.
      newViewportIndex = Math.floor newViewportLocation / viewportWidth

    else
      # We're already at the correct location.
      return

    # Update page index.
    @currentPageIndex newViewportIndex * options.pagesPerViewport

    # Immediately update scroll left as well to prevent blinking.
    @_updateEntryScrollLeft()

  onClickWritingArea: (event) ->
    # If we're clicking inside the editor, there's nothing to do.
    return if $(event.target).closest('.ql-editor').length

    # Otherwise we assume we're trying to move to the end.
    @moveCursorToEnd()

    # HACK: moving the cursor resets scroll to 0 so we need to manually update it again.
    @_updateEntryScrollLeft()

  onClickToggleObjectsButton: (event) ->
    @objectsAreaExpanded not @objectsAreaExpanded()

  onMouseUpWindow: (event) ->
    return if $(event.target).closest('.toggle-objects-button').length

    @objectsAreaExpanded false

  onClickInsertObjectButtonImage: (event) ->
    quill = @quill()
    range = quill.getSelection()

    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless imageFile = $fileInput[0]?.files[0]

      value = file: imageFile
      quill.insertEmbed range.index, 'image', value, Quill.sources.USER

    $fileInput.click()
