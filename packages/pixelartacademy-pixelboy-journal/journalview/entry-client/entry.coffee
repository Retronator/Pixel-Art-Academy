AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = require 'quill'
Block = Quill.import 'blots/block'

class PAA.PixelBoy.Apps.Journal.JournalView.Entry extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry'
  @register @id()

  @version: -> '0.1.0'

  @debug = false

  constructor: (@entries, @entryId) ->
    super

    @journalDesign = @entries.journalDesign

  onCreated: ->
    super

    @quill = new AE.ReactiveWrapper null

    @display = LOI.adventure.interface.display

    # TODO: When page is being recreated, we should preserve page index instead of setting it to 0.
    @currentPageIndex = new ReactiveField 0
    @pagesCount = new ReactiveField 0
    
    @entry = new ComputedField =>
      PAA.Practice.Journal.Entry.documents.findOne @entryId

    @objectsAreaExpanded = new ReactiveField false

    @_mouseUpWindowHandler = (event) => @onMouseUpWindow event
    $(window).on 'mouseup', @_mouseUpWindowHandler

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
        'list'
        'timestamp'
        'picture'
        'task'
        'language'
      ]
      readOnly: @journalDesign.options.readOnly

    @quill quill

    # Insert the starting template on a new entry.
    @insertTimestamp 0, Quill.sources.API unless @entryId

    quill.on 'text-change', (delta, oldDelta, source) =>
      console.log "Text change", @entryId, delta, oldDelta, source if @constructor.debug

      unless @entryId
        # This is an empty entry, so start it, but not if we have any pictures still uploading.
        delta = @quill().getContents()

        for operation in delta.ops
          return if operation.insert?.picture?.file

        console.log "Starting entry.", @entryId if @constructor.debug

        @options.startEntry delta
        return

      # Update the entry if this was a user update.
      if source is Quill.sources.USER
        console.log "Updating entry", @entryId if @constructor.debug
        PAA.Practice.Journal.Entry.updateContent @entryId, delta.ops

    quill.on 'editor-change', =>
      # Trigger reactive updates.
      @quill.updated()

    # Reactively update total pages count.
    @autorun (computation) =>
      @updatePagesCount()

    # Update quill content.
    @autorun (computation) =>
      return unless entry = @entry()

      console.log "Updating entry from database", entry if @constructor.debug

      # See if we already have the correct content.
      currentContent = quill.getContents().ops

      if EJSON.equals entry.content, currentContent
        console.log "Current content matches." if @constructor.debug
        return

      console.log "Updating content." if @constructor.debug

      # The content is new, update.
      quill.setContents entry.content, Quill.sources.API

      # Move the cursor to the end.
      @moveCursorToEnd()

  onDestroyed: ->
    super

    $(window).off 'mouseup', @_mouseUpWindowHandler

  updatePagesCount: ->
    # See how far the last character in the editor appears.
    quill = @quill.withUpdates()

    length = quill.getLength()
    bounds = quill.getBounds length

    scale = @display.scale()
    lastLeft = bounds.left / scale

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

  insertTimestamp: (index, source = Quill.sources.USER) ->
    quill = @quill()

    # Create an empty timestamp so it gets initialized with current time.
    time = new Date()

    value =
      time: time
      timezoneOffset: time.getTimezoneOffset()

    quill.insertEmbed index, 'timestamp', value, source
    quill.formatText index, 1, 'language', AB.currentLanguage(), source

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

  objectsStyle: ->
    objectsCount = @objects().length
    width = if @objectsAreaExpanded() then objectsCount * 21 + 13 else 0

    width: "#{width}rem"

  objects: ->
    objects = [
      type: 'picture'
      name: "Picture"
    ,
      type: 'task'
      name: "Learning task"
    ]

    # Add timestamp if it's not already in the post.
    if delta = @quill.withUpdates()?.getContents()
      for operation in delta.ops
        if operation.insert?.timestamp
          timestampFound = true
          break

    unless timestampFound
      objects.push
        type: 'timestamp'
        name: "Timestamp"

    objects
    
  readOnlyClass: ->
    'read-only' if @journalDesign.options.readOnly

  events: ->
    super.concat
      'scroll .pixelartacademy-pixelboy-apps-journal-journalview-entry': @onScrollEntry
      'click .writing-area': @onClickWritingArea
      'click .toggle-objects-button': @onClickToggleObjectsButton
      'click .picture .insert-object-button': @onClickInsertObjectButtonPicture
      'click .task .insert-object-button': @onClickInsertObjectButtonTask
      'click .timestamp .insert-object-button': @onClickInsertObjectButtonTimestamp

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

  onClickInsertObjectButtonPicture: (event) ->
    quill = @quill()
    range = quill.getSelection()

    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      value = {file}
      quill.insertEmbed range.index, 'picture', value, Quill.sources.USER

    $fileInput.click()

  onClickInsertObjectButtonTask: (event) ->
    quill = @quill()
    range = quill.getSelection()

    quill.insertEmbed range.index, 'task', {}, Quill.sources.USER

  onClickInsertObjectButtonTimestamp: (event) ->
    quill = @quill()
    range = quill.getSelection()

    @insertTimestamp range.index
