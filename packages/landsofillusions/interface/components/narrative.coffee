AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Components.Narrative
  constructor: (@options) ->
    @text = new ReactiveField ""

  lines: ->
    text = @text()
    return [] unless text.length

    text.split('\n')

  linesCount: ->
    @lines().length

  addText: (newText, options = {}) ->
    text = @text()

    options.addNewLine ?= true
    options.scroll ?= true

    if text.length > 0
      text += "\n" if options.addNewLine

    text += newText
    @text text

    if options.scroll
      Tracker.afterFlush =>
        @options.textInterface.resize()
        @scroll()

  clear: ->
    @text ""

  scroll: (options = {}) ->
    options.animate ?= true
    options.scrollMain ?= true

    $textInterface = $('.adventure .text-interface')
    return unless $textInterface.length

    $textDisplayContent = $textInterface.find('.text-display-content')
    $ui = $textInterface.find('.ui')

    displayContentHeight = $textDisplayContent.height()

    uiHeight = options.height or $ui.height()

    # If UI doesn't have at least some height, it's probably not rendered correctly yet.
    return unless uiHeight

    hiddenNarrative = Math.max 0, displayContentHeight - uiHeight

    # Make sure the latest narrative is visible by scrolling text display content to the bottom.
    newTextTop = -hiddenNarrative

    @options.textInterface.animateElement
      $element: $textDisplayContent
      animate: options.animate
      properties:
        translateY: "#{newTextTop}px"

    if options.scrollMain
      @options.textInterface.scroll
        position: @options.textInterface.maxScrollTop()
        animate: options.animate
        slow: options.slow
