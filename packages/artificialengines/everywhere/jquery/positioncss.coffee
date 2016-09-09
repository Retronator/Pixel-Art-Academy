(($) ->

  # A cross-browser way to read position css properties (left/right/top/bottom).
  $.fn.positionCss = (property) ->
    oldDisplay = @css('display')

    # Hide element.
    @css(display: 'none')

    # Css should now work properly in FF.
    value = @css(property)

    # Restore display style.
    @css(display: oldDisplay)

    value

)(jQuery)
