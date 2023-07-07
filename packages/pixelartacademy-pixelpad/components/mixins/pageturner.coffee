AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelPad.Components.Mixins.PageTurner
  events: -> [
    'wheel': @onMouseWheel
  ]

  mixinParent: (@parent) ->

  onMouseWheel: (event) ->
    event.preventDefault()

    @_resetScroll() unless @_scroll?

    @_scroll += event.originalEvent.deltaX
    @_verticalScroll += event.originalEvent.deltaY

    minimumScroll = 20

    # Make sure we didn't move more vertically than horizontally, by resetting horizontal scroll when we do.
    @_resetScroll() if Math.abs(@_verticalScroll) > minimumScroll

    @parent.nextPage?() if @_scroll > minimumScroll
    @parent.previousPage?() if @_scroll < -minimumScroll

    # Reset scroll after page was turned.
    @_resetScroll() if Math.abs(@_scroll) > minimumScroll

    # Also reset scroll after the user pauses scrolling.
    @_debouncedReset ?= _.debounce =>
      @_resetScroll()
    ,
      1000

    @_debouncedReset()

  _resetScroll: ->
    @_scroll = 0
    @_verticalScroll = 0
