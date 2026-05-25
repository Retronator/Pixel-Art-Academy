AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

scrollbarArrowSize = 10
scrollbarPositionSize = 12
scrollDelta = 10
scrollDelay = 0.125

class PAA.Pixeltosh.OS.Interface.ScrollableArea extends AM.Component
  # horizontal: controls horizontal scrolling
  #   enabled: boolean whether scrolling should be possible
  #   visible: boolean whether the scrollbar should be visible, even if not enabled
  # vertical: controls vertical scrolling
  #   enabled: boolean whether scrolling should be possible
  #   visible: boolean whether the scrollbar should be visible, even if not enabled
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.ScrollableArea'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @scrollableAreaChangedListener = @ancestorComponentWith 'onScrollableAreaChanged'
    
    # Properties coming from the program view.
    
    @programViewData = new ComputedField =>
      return unless programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
      programView.data()
    
    # Have scroll left and top as normal fields so we can change them without going through program view's reactivity.
    @scrollTop = new ReactiveField 0
    @scrollLeft = new ReactiveField 0

    # Load initial values from program view.
    @autorun (computation) =>
      return unless programViewData = @programViewData()
      @scrollTop programViewData.value().scrollTop or 0
      @scrollLeft programViewData.value().scrollLeft or 0
      
    # Track size for calculating scrollbar dimensions.
    @contentAreaSize = new ReactiveField width: 0, height: 0
    @contentSize = new ReactiveField width: 0, height: 0
    
    @maxScroll = new ComputedField =>
      contentAreaSize = @contentAreaSize()
      contentSize = @contentSize()

      left: Math.max 0, contentSize.width - contentAreaSize.width
      top: Math.max 0,contentSize.height - contentAreaSize.height
    
    # Create the field for indicating changes.
    @scrollbarMoveDelta = new ReactiveField null

  onRendered: ->
    super arguments...
    
    # Observe content size.
    @$contentArea = @$('.content-area')
    updateContentAreaSize = =>
      scale = @os.display.scale()
      
      @contentAreaSize
        width: @$contentArea.outerWidth() / scale
        height: @$contentArea.outerHeight() / scale
    
    updateContentAreaSize()
    
    @_contentAreaResizeObserver = new ResizeObserver updateContentAreaSize
    @_contentAreaResizeObserver.observe @$contentArea[0]
    
    @$content = @$('.content')
    updateContentSize = =>
      scale = @os.display.scale()
      
      @contentSize
        width: @$content.outerWidth() / scale
        height: @$content.outerHeight() / scale
    
    updateContentSize()
    
    @_contentResizeObserver = new ResizeObserver updateContentSize
    @_contentResizeObserver.observe @$content[0]
    
  onDestroyed: ->
    super arguments...
    
    @_contentAreaResizeObserver?.disconnect()
    @_contentResizeObserver?.disconnect()
    
    Meteor.clearInterval @_scrollInterval
    @_endEvents()
    
  _endEvents: ->
    $(document).off '.pixelartacademy-pixeltosh-os-interface-window'
  
  programViewActive: ->
    programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
    programView.active()
    
  # Scrolling
  
  scrollInDirection: (vertical, sign, factor=1) ->
    if vertical
      @_setScrollTop @_clampedScrollTop() + Math.sign(sign) * scrollDelta * factor
      
    else
      @_setScrollLeft @_clampedScrollLeft() + Math.sign(sign) * scrollDelta * factor

  scrollToElement: (element, options = {}) ->
    options.padding ?= 20
    options.animate ?= false
    
    # Get positions relative to document
    scale = @os.display.scale()

    $element = $(element)
    elementOffset = $element.offset()
    elementOffset.top /= scale
    elementOffset.left /= scale

    elementWidth = $element.outerWidth() / scale
    elementHeight = $element.outerHeight() / scale

    contentAreaOffset = @$contentArea.offset()
    contentAreaOffset.top /= scale
    contentAreaOffset.left /= scale

    contentAreaSize = @contentAreaSize()
    
    # Calculate where to scroll to.
    scrollTop = null
    scrollLeft = null
    
    if elementOffset.top < contentAreaOffset.top + options.padding
      scrollDownBy = contentAreaOffset.top + options.padding - elementOffset.top
      scrollTop = @_clampedScrollTop() - scrollDownBy
      
    else if elementOffset.top + elementHeight > contentAreaOffset.top + contentAreaSize.height - options.padding
      scrollUpBy = elementOffset.top + elementHeight - (contentAreaOffset.top + contentAreaSize.height - options.padding)
      scrollTop = @_clampedScrollTop() + scrollUpBy
      
    if elementOffset.left < contentAreaOffset.left + options.padding
      scrollRightBy = contentAreaOffset.left - elementOffset.left + options.padding
      scrollLeft = @_clampedScrollLeft() - scrollRightBy
      
    else if elementOffset.left + elementWidth > contentAreaOffset.left + contentAreaSize.width - options.padding
      scrollLeftBy = elementOffset.left + elementWidth - (contentAreaOffset.left + contentAreaSize.width - options.padding)
      scrollLeft = @_clampedScrollLeft() + scrollLeftBy
      
    # If we're not animating, simply set the values.
    unless options.animate
      @_setScrollTop scrollTop if scrollTop?
      @_setScrollLeft scrollLeft if scrollLeft?
      return
      
    # Enable waiting for the end of animation.
    new Promise (resolve, reject) =>
      # Calculate how many times the scroll in direction should be called.
      scrollVerticalBy = -scrollDownBy if scrollDownBy
      scrollVerticalBy = scrollUpBy if scrollUpBy

      scrollHorizontalBy = -scrollRightBy if scrollRightBy
      scrollHorizontalBy = scrollLeftBy if scrollLeftBy
      
      scrollVerticalTimes = Math.ceil Math.abs scrollVerticalBy / scrollDelta if scrollVerticalBy
      scrollHorizontalTimes = Math.ceil Math.abs scrollHorizontalBy / scrollDelta if scrollHorizontalBy
      
      # Allow maximum of 5 scrolls.
      if scrollVerticalTimes > 5
        scrollVerticalFactor = scrollVerticalTimes / 5
        scrollVerticalTimes = 5
        
      if scrollHorizontalTimes > 5
        scrollHorizontalFactor = scrollHorizontalTimes / 5
        scrollHorizontalTimes = 5
      
      # Perform the scrolls.
      while scrollVerticalTimes or scrollHorizontalTimes
        break if options.skipAnimation?()
        
        if scrollVerticalTimes
          @scrollInDirection true, scrollVerticalBy, scrollVerticalFactor
          scrollVerticalTimes--
          @_setScrollTop scrollTop unless scrollVerticalTimes
          
        if scrollHorizontalTimes
          @scrollInDirection false, scrollHorizontalBy, scrollHorizontalFactor
          scrollHorizontalTimes--
          @_setScrollLeft scrollLeft unless scrollHorizontalTimes
          
        await _.waitForSeconds scrollDelay if scrollVerticalTimes or scrollHorizontalTimes
        
      # Set final values again in case we skip animation.
      @_setScrollTop scrollTop if scrollTop?
      @_setScrollLeft scrollLeft if scrollLeft?

      resolve()
      
  scrollToBottom: ->
    @_setScrollTop @maxScroll().top
  
  _clampedScrollTop: ->
    _.clamp @scrollTop(), 0, @maxScroll().top
    
  _clampedScrollLeft: ->
    _.clamp @scrollLeft(), 0, @maxScroll().left
    
  _setScrollTop: (scrollTop) ->
    @scrollTop scrollTop
    @scrollableAreaChangedListener?.onScrollableAreaChanged {scrollTop}
    
    # Perform a lazy set so that the interface doesn't rerender.
    @programViewData()?.lazySet 'scrollTop', @scrollTop()
    
  _setScrollLeft: (scrollLeft) ->
    @scrollLeft scrollLeft
    @scrollableAreaChangedListener?.onScrollableAreaChanged {scrollLeft}
    
    # Perform a lazy set so that the interface doesn't rerender.
    @programViewData()?.lazySet 'scrollLeft', @scrollLeft()
    
  # Content and scrollbars
    
  contentStyle: ->
    left: "-#{@_clampedScrollLeft()}rem"
    top: "-#{@_clampedScrollTop()}rem"
    
  verticalScrollbarActive: ->
    @contentSize().height > @contentAreaSize().height
    
  horizontalScrollbarActive: ->
    @contentSize().width > @contentAreaSize().width
  
  verticalScrollbarActiveClass: ->
    'active' if @verticalScrollbarActive() and @programViewActive()
    
  horizontalScrollbarActiveClass: ->
    'active' if @horizontalScrollbarActive() and @programViewActive()
  
  verticalScrollbarDraggingClass: ->
    'dragging' if @scrollbarMoveDelta()?.top?
  
  horizontalScrollbarDraggingClass: ->
    'dragging' if @scrollbarMoveDelta()?.left?

  verticalScrollbarArrowDisabledAttribute: ->
    disabled: true unless @verticalScrollbarActive()
    
  horizontalScrollbarArrowDisabledAttribute: ->
    disabled: true unless @horizontalScrollbarActive()
    
  verticalScrollbarVisible: ->
    options = @data()
    options.vertical?.visible or options.vertical?.enabled
    
  horizontalScrollbarVisible: ->
    options = @data()
    options.horizontal?.visible or options.horizontal?.enabled
    
  resizeControlVisible: ->
    (@verticalScrollbarVisible() or @horizontalScrollbarVisible()) and @programViewActive()
    
  verticalScrollbarEnabled: ->
    options = @data()
    options.vertical?.enabled and @programViewActive()
  
  horizontalScrollbarEnabled: ->
    options = @data()
    options.horizontal?.enabled and @programViewActive()
  
  verticalScrollbarPositionStyle: ->
    @_verticalScrollbarPositionStyle @scrollTop()
  
  verticalScrollbarPositionMoveIndicatorStyle: ->
    @_verticalScrollbarPositionStyle @_clampedScrollTop() + @scrollbarMoveDelta()?.top or 0
    
  _verticalScrollbarPositionStyle: (scrollTop) ->
    {scrollAreaSpan, contentSpan} = @_verticalScrollbarDimensions()
    
    scrollRatio = _.clamp scrollTop / contentSpan, 0, 1
    
    top: "#{Math.round scrollAreaSpan * scrollRatio + scrollbarArrowSize + 1}rem"
    
  _verticalScrollbarDimensions: ->
    contentAreaSizeHeight = @contentAreaSize().height
    
    scrollAreaHeight = contentAreaSizeHeight - 2 * (scrollbarArrowSize + 1)
    scrollAreaSpan = scrollAreaHeight - scrollbarPositionSize
    
    contentSpan = @contentSize().height - contentAreaSizeHeight
    
    {scrollAreaSpan, contentSpan}
  
  horizontalScrollbarPositionStyle: ->
    @_horizontalScrollbarPositionStyle @scrollLeft()
  
  horizontalScrollbarPositionMoveIndicatorStyle: ->
    @_horizontalScrollbarPositionStyle @_clampedScrollLeft() + @scrollbarMoveDelta()?.left or 0
  
  _horizontalScrollbarPositionStyle: (scrollLeft) ->
    {scrollAreaSpan, contentSpan} = @_horizontalScrollbarDimensions()
    
    scrollRatio = _.clamp scrollLeft / contentSpan, 0, 1
    
    left: "#{Math.round scrollAreaSpan * scrollRatio + scrollbarArrowSize + 1}rem"
  
  _horizontalScrollbarDimensions: ->
    contentAreaSizeWidth = @contentAreaSize().width
    
    scrollAreaWidth = contentAreaSizeWidth - 2 * (scrollbarArrowSize + 1)
    scrollAreaSpan = scrollAreaWidth - scrollbarPositionSize
    
    contentSpan = @contentSize().width - contentAreaSizeWidth
    
    {scrollAreaSpan, contentSpan}

  events: ->
    super(arguments...).concat
      'pointerdown .up.arrow': @onPointerDownUpArrow
      'pointerdown .down.arrow': @onPointerDownDownArrow
      'pointerdown .left.arrow': @onPointerDownLeftArrow
      'pointerdown .right.arrow': @onPointerDownRightArrow
      'pointerdown .vertical-scrollbar .position': @onPointerDownVerticalScrollbarPosition
      'pointerdown .horizontal-scrollbar .position': @onPointerDownHorizontalScrollbarPosition
      'wheel .content-area': @onWheelContentArea

  # Scrolling with arrows
  
  onPointerDownUpArrow: (event) ->
    @_startScrollingUntilPointerUp true, -1

  onPointerDownDownArrow: (event) ->
    @_startScrollingUntilPointerUp true, 1

  onPointerDownLeftArrow: (event) ->
    @_startScrollingUntilPointerUp false, -1
    
  onPointerDownRightArrow: (event) ->
    @_startScrollingUntilPointerUp false, 1
    
  _startScrollingUntilPointerUp: (vertical, sign) ->
    @scrollInDirection vertical, sign
    
    $document = $(document)
    
    Meteor.clearInterval @_scrollInterval
    
    @_scrollInterval = Meteor.setInterval =>
      @scrollInDirection vertical, sign
    ,
      scrollDelay * 1000
    
    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      $document.off '.pixelartacademy-pixeltosh-os-interface-window'
      
      Meteor.clearInterval @_scrollInterval

  # Scrolling by dragging the position indicator
  
  onPointerDownVerticalScrollbarPosition: (event) ->
    # Remember starting position of drag.
    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()

    # Wire dragging handlers.
    $document = $(document)
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window',  (event) =>
      return unless coordinates = cursor.coordinates()
      
      scrollAreaDelta = coordinates.y - dragStartCoordinates.y
      {scrollAreaSpan, contentSpan} = @_verticalScrollbarDimensions()
      
      @scrollbarMoveDelta
        top: Math.round scrollAreaDelta / scrollAreaSpan * contentSpan

    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()

      delta = @scrollbarMoveDelta()
      @scrollbarMoveDelta null
    
      @_setScrollTop @_clampedScrollTop() + delta.top

  onPointerDownHorizontalScrollbarPosition: (event) ->
    # Remember starting position of drag.
    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()
    
    # Wire dragging handlers.
    $document = $(document)
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      return unless coordinates = cursor.coordinates()
      
      scrollAreaDelta = coordinates.x - dragStartCoordinates.x
      {scrollAreaSpan, contentSpan} = @_horizontalScrollbarDimensions()
      
      @scrollbarMoveDelta
        left: Math.round scrollAreaDelta / scrollAreaSpan * contentSpan
    
    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()
      
      delta = @scrollbarMoveDelta()
      @scrollbarMoveDelta null
      
      @_setScrollLeft @_clampedScrollLeft() + delta.left
      
  # Scrolling with the mouse wheel
  
  onWheelContentArea: (event) ->
    # Accumulate wheel deltas.
    @_accumulatedWheelDelta ?= x: 0, y: 0

    @_accumulatedWheelDelta.x += event.originalEvent.deltaX
    @_accumulatedWheelDelta.y += event.originalEvent.deltaY
    
    if LOI.settings.graphics.slowCPUEmulation.value()
      # Throttle updates.
      @_throttledApply ?= _.throttle (event) =>
        @_applyWheelDelta()
      ,
        PAA.Pixeltosh.OS.Interface.slowCPUEmulationLargeFrameDelay * 1000
      
      @_throttledApply()
      
    else
      # Apply immediately.
      @_applyWheelDelta()

  _applyWheelDelta: ->
    scale = @os.display.scale()
  
    @_setScrollLeft Math.round @_clampedScrollLeft() + @_accumulatedWheelDelta.x / scale
    @_setScrollTop Math.round @_clampedScrollTop() + @_accumulatedWheelDelta.y / scale
    
    @_accumulatedWheelDelta.x = 0
    @_accumulatedWheelDelta.y = 0
