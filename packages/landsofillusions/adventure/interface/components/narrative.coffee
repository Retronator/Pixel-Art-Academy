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
    return unless $textInterface.length

    $textDisplayContent = $textInterface.find('.text-display-content')
    $uiArea = $textInterface.find('.ui-area')
    $ui = $textInterface.find('.ui')

    displayContentHeight = $textDisplayContent.height()

    uiHeight = options.height or $ui.height()

    hiddenNarrative = Math.max 0, displayContentHeight - uiHeight

    # Make sure the latest narrative is visible by scrolling text display content to the bottom.
    newTextTop = -hiddenNarrative

    @options.textInterface.resizing?._animateElement
      $element: $textDisplayContent
      animate: options.animate
      properties:
        translateY: "#{newTextTop}px"

    uiTop = $ui.position().top
    hiddenTotal = uiTop + Math.min(uiHeight, displayContentHeight) - $(window).height()

    if options.scrollMain
      # Now also scroll the main content to bring the bottom into view, but only if scrolling down.
      currentTop = parseInt $.Velocity.hook($uiArea, 'translateY') or 0
      newTop = -hiddenTotal

      if newTop < currentTop
        duration = _.clamp (currentTop - newTop), 150, 1000

        $window = $(window)

        @options.textInterface.resizing?._animateElement
          $element: $uiArea
          animate: options.animate
          duration: duration
          properties:
            translateY: "#{newTop}px"
            tween: [newTop, currentTop]

          progress: (elements, complete, remaining, start, tweenValue) =>
            $window.scrollTop -tweenValue
