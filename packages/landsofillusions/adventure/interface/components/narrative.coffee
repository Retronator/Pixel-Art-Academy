AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Components.Narrative
  constructor: (@options) ->
    @text = new ReactiveField ""

  lines: ->
    text = @text()
    return [] unless text.length

    text.split('\n')

  linesCount: ->
    @lines().length

  addText: (newText, addNewLine = true) ->
    text = @text()

    if text.length > 0
      text += "\n" if addNewLine

    text += newText
    @text text

    Tracker.afterFlush => @scroll()

  clear: ->
    @text ""

  scroll: (options = {}) ->
    options.animate ?= true
    options.scrollMain ?= true

    $textInterface = $('.adventure .text-interface')
    $textDisplayContent = $textInterface.find('.text-display-content')
    $textInterfaceContent = $textInterface.find('.text-interface-content')
    $ui = $textInterface.find('.ui')

    displayContentHeight = $textDisplayContent.height()

    uiHeight = options.height or $ui.height()

    hiddenNarrative = Math.max 0, displayContentHeight - uiHeight

    # Make sure the latest narrative is visible by scrolling text display content to the bottom.
    @options.textInterface.resizing?._animateElement $textInterface.find('.text-display .scrollable-content'), options.animate,
      top: -hiddenNarrative

    uiTop = $ui.position().top
    hiddenTotal = uiTop + Math.min(uiHeight, displayContentHeight) - $(window).height()

    if options.scrollMain
      # Now also scroll the main content to bring the bottom into view, but only if scrolling down.
      currentTop = $textInterfaceContent.position().top
      newTop = -hiddenTotal

      if newTop < currentTop
        @options.textInterface.resizing?._animateElement $textInterfaceContent, options.animate,
          top: newTop
