AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Quill can only exists on the client.
Quill = require 'quill' if Meteor.isClient

class PAA.PixelBoy.Apps.Journal.JournalView.EntryEditor extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.EntryEditor'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  constructor: (@journalDesign) ->
    super

  onCreated: ->
    super

    @currentPageIndex = new ReactiveField 0
  
  onRendered: ->
    super

    @$entryEditor = @$('.pixelartacademy-pixelboy-apps-journal-journalview-entryeditor')

    # Reactively display the correct page.
    @autorun (computation) =>
      @_updateEntryEditorScrollLeft()

    # Initialize quill.
    @quill = new Quill @$('.writing-area')[0]

  previousPage: ->
    options = @journalDesign.writingAreaOptions()
    @currentPageIndex Math.max 0, @currentPageIndex() - options.pagesPerViewport

  nextPage: ->
    options = @journalDesign.writingAreaOptions()
    @currentPageIndex @currentPageIndex() + options.pagesPerViewport

  _updateEntryEditorScrollLeft: ->
    pageIndex = @currentPageIndex()
    scale = LOI.adventure.interface.display.scale()
    options = @journalDesign.writingAreaOptions()

    viewportWidth = options.pagesPerViewport * (options.width + options.gap)
    viewportIndex = pageIndex / options.pagesPerViewport

    @$entryEditor.scrollLeft viewportWidth * viewportIndex * scale

  writingAreaStyle: ->
    options = @journalDesign.writingAreaOptions()

    # Always show two additional viewport worth of pages, so that
    # there is enough content for scrolling to reach its desired place.
    displayedPages = @currentPageIndex() + 3 * options.pagesPerViewport
    width = displayedPages * options.width + (displayedPages - 1) * options.gap

    left: "#{options.left}rem"
    top: "#{options.top}rem"
    width: "#{width}rem"
    height: "#{options.height}rem"
    columnCount: displayedPages
    columnGap: "#{options.gap}rem"
    
  events: ->
    super.concat
      'scroll .pixelartacademy-pixelboy-apps-journal-journalview-entryeditor': @onScrollEntryEditor

  onScrollEntryEditor: (event) ->
    # Calculate which page we should be on.
    scrollLeft = event.target.scrollLeft
    scale = LOI.adventure.interface.display.scale()

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
    @_updateEntryEditorScrollLeft()
