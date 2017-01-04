AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Text extends LOI.Adventure.Interface.Text
  initializeScrolling: ->
    # We try to detect scrolling with the wheel so that we can hide scroll bars (for example, when not on mobile).
    @wheelDetected = false

    @$textInterface = $('.text-interface')
    @textInterfaceElement = @$textInterface[0]
    @$window = $(window)
    @$uiArea = $('.ui-area')

    # Listen to scroll events so that we can sync transform-based scrolling to it.
    @$window.on 'scroll.text-interface', =>
      return if @wheelDetected

      scrollTop = @$window.scrollTop()
      $.Velocity.hook @$uiArea, 'translateY', "#{-scrollTop}px"

  # The current full height of the text interface (non-reactive).
  height: ->
    @$uiArea.height()

  # The position in the UI at which we've scrolled to the bottom of the UI.
  maxScrollTop: ->
    containerHeight = @$textInterface.height()

    Math.max 0, @height() - containerHeight

  # Returns the current scroll position of the text interface.
  scrollTop: ->
    parseInt $.Velocity.hook(@$uiArea, 'translateY') or 0

  # Scroll the UI to put the position at the top of the viewport.
  scroll: (options) ->
    options.animate ?= false

    currentTop = @scrollTop()
    
    newTop = -options.position

    duration = _.clamp Math.abs(currentTop - newTop), 150, 700

    @animateElement
      $element: @$uiArea
      animate: options.animate
      duration: duration
      properties:
        translateY: "#{newTop}px"
        tween: [newTop, currentTop]
      progress: (elements, complete, remaining, start, tweenValue) =>
        @onScroll -tweenValue if tweenValue?
        
    # If we're not animating, progress won't be called so handle scrollTop here.
    unless options.animate
      @onScroll options.position
      
  onScroll: (position) ->
    # Let the location know we're scrolling so that it can do any super-smooth scrolling animations.
    @options.adventure.currentLocation().onScroll?()

    # Also scroll the main slider.
    @$window.scrollTop position unless @wheelDetected
    
  onWheel: (event) ->
    @onWheelEvent()

    # If scrolling is locked to a container, don't let the native browser slider scroll.
    if @_scrollLockTarget and @_scrollLockTarget isnt event.currentTarget
      event.preventDefault()

  onWheelScrollable: (event) ->
    @onWheelEvent()
    $scrollable = $(event.currentTarget)

    # If scrolling is locked to a container, only continue if it's locked on us.
    return if @_scrollLockTarget and @_scrollLockTarget isnt $scrollable[0]

    $scrollableContent = $scrollable.find('.scrollable-content').eq(0)

    delta = event.originalEvent.deltaY
    top = parseInt $.Velocity.hook($scrollableContent, 'translateY') or 0
    newTop = top - delta
    
    # Limit scrolling to the amount of content.
    amountHidden = Math.max 0, $scrollableContent.height() - $scrollable.height()
    newTop = _.clamp newTop, -amountHidden, 0

    # See if we need to do anything at all.
    if newTop is top
      # If we scrolled to the bottom, immediately stop scroll lock. This makes scroll lock only work when scrolling up.
      if newTop is -amountHidden
        @_scrollLockTarget = null

      return

    # We've scrolled in this container so lock scrolling to it.
    @_scrollLockTarget = $scrollable[0]
    event.preventDefault()

    @_unlockScrollAfterAWhile ?= _.debounce =>
      @_scrollLockTarget = null
    ,
      1000

    @_unlockScrollAfterAWhile()

    $.Velocity.hook $scrollableContent, 'translateY', "#{newTop}px"

    # When scrolling the main text adventure also trigger onScroll.
    if event.currentTarget is @textInterfaceElement
      @onScroll -newTop

  onWheelEvent: ->
    @wheelDetected = true

    # Disable non-wheel scrolling.
    $('html').css
      overflow: 'hidden'

  clampScrollableAreas: ->
    # Clamp scrollable areas to content size.
    @$('.scrollable').each (index, element) =>
      $scrollable = $(element)
      $scrollableContent = $scrollable.find('.scrollable-content').eq(0)

      top = parseInt $.Velocity.hook($scrollableContent, 'translateY') or 0

      amountHidden = Math.max 0, $scrollableContent.height() - $scrollable.height()
      newTop = _.clamp top, -amountHidden, 0

      $.Velocity.hook $scrollableContent, 'translateY', "#{newTop}px"

      # When scrolling the main text adventure also trigger onScroll.
      if element is @textInterfaceElement
        @onScroll -newTop
