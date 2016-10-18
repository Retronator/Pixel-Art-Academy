AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Components.Narrative
  constructor: (@textInterface) ->
    @text = new ReactiveField ""

  lines: ->
    @text().split('\n')

  linesCount: ->
    @lines().length

  addText: (newText, addNewLine = true) ->
    text = @text()

    if text.length > 0
      text += "\n" if addNewLine

    text += newText
    @text text

  scroll: (options = {}) ->
    options.animate ?= true

    $textInterface = $('.adventure .text-interface')
    $ui = $textInterface.find('.ui')

    totalContentHeight = $textInterface.find('.text-display-content').height()
    uiHeight = options.height or $ui.height()

    hidden = Math.max 0, totalContentHeight - uiHeight

    # Make sure the latest narrative is visible, by scrolling text display content to the bottom.
    @textInterface.resizing._animateElement $textInterface.find('.text-display .scrollable-content'), options.animate,
      top: -hidden
