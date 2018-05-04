AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Components.Narrative
  @ScrollStyle:
    None: 'None'
    Top: 'Top'
    Bottom: 'Bottom'
    RetainBottom: 'RetainBottom'

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

    if text.length > 0
      text += "\n" if options.addNewLine

    # Make sure new text doesn't have any new lines itself. We consider every call to add text to be one unit.
    newText = newText.replace /[\n\r]+/mg, ''

    # If the text is a background action, wrap it in the background class and don't scroll.
    if options.background
      newText = "%%html<div class='in-background'>#{newText}</div>html%%"
      options.scrollStyle = @constructor.ScrollStyle.RetainBottom

    text += newText
    @text text

    @onTextUpdated options

  onTextUpdated: (options = {}) ->
    unless options.scrollStyle is @constructor.ScrollStyle.None
      # Handle the style where we scroll to bottom only if we're already on bottom.
      if options.scrollStyle is @constructor.ScrollStyle.RetainBottom
        # Quit, so we don't scroll if we're not at bottom.
        return unless @options.textInterface.isNarrativeScrolledToBottom()
        
      Tracker.afterFlush =>
        @options.textInterface.resize()
        @scroll scrollStyle: options.scrollStyle

  removeLastCommand: ->
    lines = @lines()

    # Find the last line with the character '>' which signifies a command.
    lastCommandIndex = _.findLastIndex lines, (line) => line[0] is '>'

    newLines = lines[...lastCommandIndex]
    newText = newLines.join '\n'

    @text newText

  clear: (options = {}) ->
    @text ""
    @onTextUpdated options

  scroll: (options = {}) ->
    options.animate ?= true
    options.scrollMain ?= true
    options.scrollStyle ?= @constructor.ScrollStyle.Bottom

    $textInterface = $('.adventure .text-interface')
    return unless $textInterface.length

    $textDisplayContent = $textInterface.find('.text-display-content')
    $ui = $textInterface.find('.ui')

    displayContentHeight = $textDisplayContent.height()

    uiHeight = options.height or $ui.height()

    # If UI doesn't have at least some height, it's probably not rendered correctly yet.
    return unless uiHeight

    hiddenNarrative = Math.max 0, displayContentHeight - uiHeight

    switch options.scrollStyle
      when @constructor.ScrollStyle.Bottom, @constructor.ScrollStyle.RetainBottom
        # Make sure the latest narrative is visible by scrolling text display content to the bottom.
        newTextTop = -hiddenNarrative

      when @constructor.ScrollStyle.Top
        # Make sure the latest narrative is visible by scrolling text display content to the top.
        $lastNarrativeLine = $textDisplayContent.find('.narrative-line').last()
        position = $lastNarrativeLine.position()
        newTextTop = Math.max -position.top, -hiddenNarrative

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
