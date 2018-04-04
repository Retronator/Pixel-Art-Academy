AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.Components.Mixins.PageTurner
  events: -> [
    'wheel': @onMouseWheel
  ]

  mixinParent: (@parent) ->

  onMouseWheel: (event) ->
    event.preventDefault()

    @_scroll ?= 0
    @_scroll += event.originalEvent.deltaX
    @_scroll += event.originalEvent.deltaY
    minimumHorizontalScroll = 20

    @parent.nextPage?() if @_scroll > minimumHorizontalScroll
    @parent.previousPage?() if @_scroll < -minimumHorizontalScroll

    # Reset scroll after page was turned.
    @_scroll = 0 if Math.abs(@_scroll) > minimumHorizontalScroll

    # Also reset scroll after the user pauses scrolling.
    @_debouncedReset ?= _.debounce =>
      @_scroll = 0
    ,
      1000

    @_debouncedReset()
